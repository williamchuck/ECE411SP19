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

cpu_datapath cpu
(
    .*
);

cache_hierarchy cache
(
    .*
);

endmodule