module urchin (
    input clk,
    input pmem_resp,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic [31:0] pmem_address,
    output logic pmem_read,
    output logic pmem_write
);

logic imem_resp, dmem_resp, dmem_read, dmem_write;
logic [3:0] dmem_byte_enable;
logic [31:0] imem_address, imem_rdata, dmem_address, dmem_rdata, dmem_wdata;
assign imem_address = 32'd0;

logic mem_resp, mem_read, mem_write;
logic [3:0] mem_byte_enable;
logic [31:0] mem_rdata, mem_wdata, mem_address;

assign mem_resp = dmem_resp;
assign mem_rdata = dmem_rdata;
assign dmem_write = mem_write;
assign dmem_read = mem_read;
assign dmem_byte_enable = mem_byte_enable;
assign dmem_address = mem_address;
assign dmem_wdata = mem_wdata;

// cpu_datapath cpu
// (
//     .*
// );

old_cpu cpu
(
    .*
);

cache_hierarchy cache
(
    .*
);

endmodule