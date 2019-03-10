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

logic muxsel;
logic load_icache_buffer;
logic [255:0] icache_buffer_out;

register #(256) icache_buffer
(
    .clk,
    .load(load_icache_buffer),
    .in(l2_rdata),
    .out(icache_buffer_out)
);

enum integer { NO_TIE, ICACHE, DCACHE } state, next_state;

assign icache_sel = l2_icache_read | l2_icache_write;
assign dcache_sel = l2_dcache_read | l2_dcache_write;

assign icache_read = imem_read;
assign dcache_read = dmem_read;
assign dcache_write = dmem_write;

initial begin
    state = NO_TIE;
end

always_comb begin
    case({icache_sel, dcache_sel})
        2'b00: muxsel = 1'b0;
        2'b10: muxsel = 1'b0;
        2'b01: muxsel = 1'b1;
        2'b11: muxsel = 1'b0;
    endcase
end

always_comb begin
    case(state)
        NO_TIE: begin
            l2_read = muxsel ? l2_dcache_read : l2_icache_read;
            l2_write = muxsel ? l2_dcache_write : l2_icache_write;
            l2_address = muxsel ? l2_dcache_address : l2_icache_address;
            l2_wdata = muxsel ? l2_dcache_wdata : l2_icache_wdata;
            l2_icache_rdata = muxsel ? {s_line{1'bX}} : l2_rdata;
            l2_dcache_rdata = muxsel ? l2_rdata : {s_line{1'bX}};
            l2_icache_resp = muxsel ? 1'b0 : l2_resp;
            l2_dcache_resp = muxsel ? l2_resp : 1'b0;
            load_icache_buffer = 1'b0;
        end

        ICACHE: begin
            l2_read = l2_icache_read;
            l2_write = l2_icache_write;
            l2_address = l2_icache_address;
            l2_wdata = l2_icache_wdata;
            l2_icache_resp = 1'b0;
            l2_dcache_resp = 1'b0;
            l2_icache_rdata = {s_line{1'bX}};
            l2_dcache_rdata = {s_line{1'bX}};
            load_icache_buffer = 1'b1;
        end

        DCACHE: begin
            l2_read = l2_dcache_read;
            l2_write = l2_dcache_write;
            l2_address = l2_dcache_address;
            l2_wdata = l2_dcache_wdata;
            l2_icache_resp = l2_resp;
            l2_dcache_resp = l2_resp;
            l2_icache_rdata = icache_buffer_out;
            l2_dcache_rdata = l2_rdata;
            load_icache_buffer = 1'b0;
        end
    endcase
end

always_comb begin
    next_state = state;
    case(state)
        NO_TIE:
            if (icache_sel && dcache_sel)
                next_state = ICACHE;

        ICACHE:
            if (l2_resp)
                next_state = DCACHE;

        DCACHE:
            if (l2_resp)
                next_state = NO_TIE;
    endcase
end

always_ff @( posedge clk ) begin
    state <= next_state;
end

endmodule
