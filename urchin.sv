module urchin (
    input clk,
    input pmem_resp,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic [31:0] pmem_address,
    output logic pmem_read,
    output logic pmem_write
);

logic imem_resp, imem_read, imem_write, dmem_resp, dmem_read, dmem_write;
logic [3:0] imem_byte_enable, dmem_byte_enable;
logic [31:0] imem_address, imem_rdata, imem_wdata, dmem_address, dmem_rdata, dmem_wdata;

cpu_datapath cpu
(
    .clk,
    /// I-Mem interface
    .imem_resp,
    .imem_rdata,
    .imem_read,
    .imem_write,
    .imem_address,
    .imem_byte_enable,
    .imem_wdata,

    // D_Mem interface
    .dmem_resp,
    .dmem_rdata,
    .dmem_read,
    .dmem_write,
    .dmem_address,
    .dmem_byte_enable,
    .dmem_wdata
);

cache_hierarchy cache
(
    .clk,
    .imem_read,
    .imem_write,
    .imem_address,
    .imem_byte_enable,
    .imem_wdata,
    .imem_resp,
    .imem_rdata,

    .dmem_read,
    .dmem_write,
    .dmem_address,
    .dmem_byte_enable,
    .dmem_wdata,
    .dmem_rdata,
    .dmem_resp,

    .pmem_resp,
    .pmem_rdata,
    .pmem_wdata,
    .pmem_address,
    .pmem_read,
    .pmem_write
);

endmodule