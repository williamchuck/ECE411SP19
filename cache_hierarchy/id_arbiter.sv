module cache_arbiter #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
)
(
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
assign dcache_sel = l2_dcache_read | l2_dcache_write

enum int unsigned {
    INSN, DATA
} state, next_state;

mux2 readmux
(
    .sel(muxsel),
    .a(l2_icache_read),
    .b(l2_dcache_read),
    .f(l2_read)
);

mux2 writemux
(
    .sel(muxsel),
    .a(l2_icache_write),
    .b(l2_dcache_write),
    .f(l2_write)
);

mux2 addressmux
(
    .sel(muxsel),
    .a(l2_icache_address),
    .b(l2_dcache_address),
    .f(l2_address)
);

mux2 wdatamux
(
    .sel(muxsel),
    .a(l2_icache_wdata),
    .b(l2_dcache_wdata),
    .f(l2_wdata)
);

mux2 icache_respmux
(
    .sel(muxsel),
    .a(l2_resp),
    .b(1'b0),
    .f(l2_icache_resp)
);

mux2 dcache_respmux
(
    .sel(muxsel),
    .a(1'b0),
    .b(l2_resp),
    .f(l2_dcache_resp)
);

always_comb begin : state_action
    case({dcache_sel, icache_sel})
        2'b00: muxsel = 0;
        2'b01: muxsel = 0;
        2'b10: muxsel = 1;
        2'b11: begin
            case(state)
                INSN: muxsel = 0;
                DATA: muxsel = 1;
            endcase
        end
        default:
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
                case(state)
                    INSN: next_state = DATA;
                    DATA: next_state = INSN;
                endcase
            end
        endcase
    end
end

always_ff @( posedge clk ) begin : state_update
    state <= next_state;
end

endmodule