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

/* autograder signals */
logic [255:0] write_data;
logic [27:0] write_address;
logic write;
logic halt;
logic pm_error;
logic [63:0] order;

initial
begin
    clk = 0;
    order = 0;
    halt = 0;
end

/* Clock generator */
always #5 clk = ~clk;

always @(posedge clk)
begin
    if (pmem_write & pmem_resp) begin
        write_address = pmem_address[31:5];
        write_data = pmem_wdata;
        write = 1;
    end else begin
        write_address = 27'hx;
        write_data = 256'hx;
        write = 0;
    end
    if (pm_error) begin
        halt = 1;
        $display("Halting with error!");
        $finish;
    end else 
    if (dut.cpu.load_pc & (dut.cpu.pc_out == dut.cpu.pcmux_out))
    begin
        halt = 1;
        $display("Halting without error");
        $finish;
    end
    if (dut.cpu.load_pc) order = order + 1;
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

endmodule : mp2_tb
