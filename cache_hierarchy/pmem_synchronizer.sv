module pmem_synchronizer
(
    input logic clk,
    input logic stall,
    input logic pmem_resp,
    input logic pmem_read, pmem_write,
    input logic [255:0] pmem_rdata,
    output logic pmem_ready,
    output logic pmem_resp_sync,
    output logic [255:0] pmem_rdata_sync
);

logic request;
assign request = pmem_read | pmem_write;
assign pmem_resp_sync = ~request;

assign pmem_ready = pmem_resp;

// logic pmem_resp_stable;
logic [255:0] pmem_rdata_stable;

// register #(1) pmem_resp_reg
// (
//     .clk,
//     .load(~stall | pmem_resp),
//     .in(pmem_resp),
//     .out(pmem_resp_stable)
// );

register #(256) pmem_rdata_reg
(
    .clk,
    .load(~stall | pmem_resp),
    .in(pmem_rdata),
    .out(pmem_rdata_stable)
);

// assign pmem_resp_sync = stall ? pmem_resp_stable : pmem_resp;
assign pmem_rdata_sync = stall ? pmem_rdata_stable : pmem_rdata;

endmodule