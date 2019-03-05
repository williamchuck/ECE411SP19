module urchin_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic pmem_resp;
logic pmem_read;
logic pmem_write;
logic [31:0] pmem_address;
logic [255:0] pmem_wdata;
logic [255:0] pmem_rdata;

logic pm_error;

initial
begin
    clk = 0;
end

/* Clock generator */
always #5 clk = ~clk;

always @(posedge clk)
begin
    if (pm_error) begin
        $display("Halting with error!");
        $finish;
    end else 
    if (dut.cpu.datapath.load_pc & (dut.cpu.datapath.pc_out == dut.cpu.datapath.pcmux_out))
    begin
        $display("Halting without error");
        $finish;
    end
end


urchin dut(
    .*
);

physical_memory memory(
    .clk,
    .read(pmem_read),
    .write(pmem_write),
    .address(pmem_address),
    .wdata(pmem_wdata),
    .resp(pmem_resp),
    .error(pm_error),
    .rdata(pmem_rdata)
);

endmodule : urchin_tb
