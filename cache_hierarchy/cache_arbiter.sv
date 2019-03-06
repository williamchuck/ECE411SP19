module cache_arbiter #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask
)
(
    input logic clk,
    input logic l2_icache_read,
    input logic l2_icache_write,
    input logic [31:0] l2_icache_address,
    input logic [s_line-1:0] l2_icache_wdata,
    output logic l2_icache_resp,
    output logic [s_line-1:0] l2_icache_rdata,

    input logic l2_dcache_read,
    input logic l2_dcache_write,
    input logic [31:0] l2_dcache_address,
    input logic [s_line-1:0] l2_dcache_wdata,
    output logic l2_dcache_resp,
    output logic [s_line-1:0] l2_dcache_rdata,

    input logic l2_resp,
    input logic [s_line-1:0] l2_rdata,
    output logic l2_read,
    output logic l2_write,
    output logic [31:0] l2_address,
    output logic [s_line-1:0] l2_wdata
);

logic icache_sel, dcache_sel;
assign icache_sel = l2_icache_read | l2_icache_write;
assign dcache_sel = l2_dcache_read | l2_dcache_write;

logic muxsel, new_muxsel;

enum int unsigned {
    INSN, DATA
} state, next_state;

assign l2_read = muxsel ? l2_dcache_read : l2_icache_read;
assign l2_write = muxsel ? l2_dcache_write : l2_icache_write;
assign l2_address = muxsel ? l2_dcache_address : l2_icache_address;
assign l2_wdata = muxsel ? l2_dcache_wdata : l2_icache_wdata;
assign l2_icache_rdata = muxsel ? {s_line{1'bX}} : l2_rdata;
assign l2_dcache_rdata = muxsel ? l2_rdata : {s_line{1'bX}};
assign l2_icache_resp = muxsel ? 1'b0 : l2_resp;
assign l2_dcache_resp = muxsel ? l2_resp : 1'b0;

// assign muxsel = 1'b1;

always_comb begin : state_action
    case({dcache_sel, icache_sel})
        2'b00: new_muxsel = muxsel;
        2'b01: new_muxsel = 0;
        2'b10: new_muxsel = 1;
        2'b11: begin
            case(state)
                INSN: new_muxsel = 0;
                DATA: new_muxsel = 1;
            endcase
        end
        default: ;
    endcase
end

always_comb begin : next_state_logic
    next_state = state;
    if (l2_resp) begin
        case({dcache_sel, icache_sel})
            2'b00: next_state = state;
            2'b01: next_state = DATA;
            2'b10: next_state = INSN;
            2'b11: begin
              if(l2_resp) begin
                case(state)
                    INSN: next_state = DATA;
                    DATA: next_state = INSN;
                endcase
              end
            end
        endcase
    end
end

always_ff @( posedge clk ) begin : state_update
    state <= next_state;
    muxsel <= new_muxsel;
end

endmodule
