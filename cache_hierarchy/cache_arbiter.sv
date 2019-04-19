`define INSN 0
`define DATA 1

module cache_arbiter #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask
)
(
    input logic clk,
    input logic imem_read,
    input logic dmem_read,
    input logic dmem_write,
    output logic icache_read,
    output logic dcache_read,
    output logic dcache_write,

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

// logic [s_line-1:0] rdata_buffer_out;
// logic pending_resp, next_pending_resp;
logic icache_enable, dcache_enable;
logic icache_sel, dcache_sel;

enum integer { IDLE, ICACHE, DCACHE } state, next_state;

assign icache_sel = l2_icache_read | l2_icache_write;
assign dcache_sel = l2_dcache_read | l2_dcache_write;

assign icache_read = icache_enable & imem_read;
assign dcache_read = dcache_enable & dmem_read;
assign dcache_write = dcache_enable & dmem_write;

initial begin
    state = IDLE;
    // pending_resp = 1'b0;
end

always_comb begin
    l2_read = 1'b0;
    l2_write = 1'b0;
    l2_address = 32'b0;
    l2_wdata = {s_line{1'bX}};
    l2_icache_rdata = {s_line{1'bX}};
    l2_dcache_rdata = {s_line{1'bX}};
    l2_icache_resp = 1'b0;
    l2_dcache_resp = 1'b0;
    // next_pending_resp = 1'b0;
    icache_enable = 1'b1;
    dcache_enable = 1'b1;

    case(state)
        IDLE: begin
            if (icache_sel & ~dcache_sel) begin
                l2_read = l2_icache_read;
                l2_write = l2_icache_write;
                l2_address = l2_icache_address;
                l2_wdata = l2_icache_wdata;
                l2_icache_rdata = l2_rdata;
                if (l2_resp) begin
                    l2_icache_resp = 1'b1;
                end
            end else if (~icache_sel & dcache_sel) begin
                l2_read = l2_dcache_read;
                l2_write = l2_dcache_write;
                l2_address = l2_dcache_address;
                l2_wdata = l2_dcache_wdata;
                l2_dcache_rdata = l2_rdata;
                if (l2_resp) begin
                    l2_dcache_resp = 1'b1;
                end
            end
        end

        ICACHE: begin
            l2_read = l2_icache_read;
            l2_write = l2_icache_write;
            l2_address = l2_icache_address;
            l2_wdata = l2_icache_wdata;
            l2_icache_rdata = l2_rdata;
            if (l2_resp) begin
                l2_icache_resp = 1'b1;
            end
        end

        DCACHE: begin
            l2_read = l2_dcache_read;
            l2_write = l2_dcache_write;
            l2_address = l2_dcache_address;
            l2_wdata = l2_dcache_wdata;
            l2_dcache_rdata = l2_rdata;
            if (l2_resp) begin
                l2_dcache_resp = 1'b1;
            end
        end
    endcase
end

always_comb begin
    next_state = state;
    case(state)
        IDLE:
            if (icache_sel)
                next_state = ICACHE;
            else if (dcache_sel)
                next_state = DCACHE;

        ICACHE:
            if (l2_resp & ~dcache_sel)
                next_state = IDLE;
            else if (l2_resp)
                next_state = DCACHE;

        DCACHE:
            if (l2_resp & ~icache_sel)
                next_state = IDLE;
            else if (l2_resp)
                next_state = ICACHE;
    endcase
end

always_ff @( posedge clk ) begin
    state <= next_state;
end

endmodule
