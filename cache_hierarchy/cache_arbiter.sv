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

logic muxsel_imm, muxsel_delayed, muxsel;
logic arbiter_active_imm, arbiter_active_delayed, arbiter_active;
logic tiebreaker; // last tie breaker

initial begin
    tiebreaker = 1'b0;
end

assign muxsel = l2_resp ? muxsel_delayed : muxsel_imm;
assign arbiter_active = l2_resp ? arbiter_active_delayed : arbiter_active_imm;

assign icache_sel = l2_icache_read | l2_icache_write;
assign dcache_sel = l2_dcache_read | l2_dcache_write;

assign icache_read = (arbiter_active & muxsel == `DATA) ? 1'b0 : imem_read;
assign dcache_read = (arbiter_active & muxsel == `INSN) ? 1'b0 : dmem_read;
assign dcache_write = (arbiter_active & muxsel == `INSN) ? 1'b0 : dmem_write;

assign l2_read = muxsel ? l2_dcache_read : l2_icache_read;
assign l2_write = muxsel ? l2_dcache_write : l2_icache_write;
assign l2_address = muxsel ? l2_dcache_address : l2_icache_address;
assign l2_wdata = muxsel ? l2_dcache_wdata : l2_icache_wdata;
assign l2_icache_rdata = muxsel ? {s_line{1'bX}} : l2_rdata;
assign l2_dcache_rdata = muxsel ? l2_rdata : {s_line{1'bX}};
assign l2_icache_resp = muxsel ? 1'b0 : l2_resp;
assign l2_dcache_resp = muxsel ? l2_resp : 1'b0;

always_comb begin : mux_sel_logic
    case({icache_sel, dcache_sel})
        2'b00: {muxsel_imm, arbiter_active_imm} = 2'b00;
        2'b10: {muxsel_imm, arbiter_active_imm} = {`INSN, 1'b1};
        2'b01: {muxsel_imm, arbiter_active_imm} = {`DATA, 1'b1};
        2'b11: {muxsel_imm, arbiter_active_imm} = {tiebreaker, 1'b1};
    endcase
end

always_ff @( posedge clk ) begin
    muxsel_delayed <= muxsel_imm;
    arbiter_active_delayed <= arbiter_active_imm;
    if (l2_resp) begin
        tiebreaker <= ~tiebreaker;
    end
end

endmodule
