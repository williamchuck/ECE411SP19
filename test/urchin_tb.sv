module urchin_tb;

timeunit 1ns;
timeprecision 1ns;

logic imem_resp, imem_read, imem_write, dmem_resp, dmem_read, dmem_write;
logic [3:0] imem_byte_enable, dmem_byte_enable;
logic [31:0] imem_address, imem_rdata, imem_wdata, dmem_address, dmem_rdata, dmem_wdata;
logic imem_ready, dmem_ready, imem_stall, dmem_stall;


logic EX_ins_valid;
logic [31:0] EX_ir;
logic [31:0] EX_pc;
logic [31:0] dmem_address_WB;
logic WB_load;

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

logic sm_error, sm_poison;

initial
begin
    clk = 0;
    order = 0;
    halt = 0;
end

/* Clock generator */
always #5 clk = ~clk;

// always @(posedge clk)
// begin
//     if (cpu.control.error == 1'd1) begin
//         $finish;
//     end
//     // if (dmem_address <= 32'h00000b00 && dmem_write) begin
//     //     $display("Writing data to imem");
//     //     $finish;
//     // end
//     if (pmem_write & pmem_resp) begin
//         write_address = pmem_address[31:5];
//         write_data = pmem_wdata;
//         write = 1;
//     end else begin
//         write_address = 27'hx;
//         write_data = 256'hx;
//         write = 0;
//     end
//     if (pm_error) begin
//         halt = 1;
//         $display("Halting with error!");
//         $finish;
//     end else 
//     if (cpu.no_mem & ~cpu.stall & (cpu.pc_out == cpu.pcmux_out))
//     begin
//         halt = 1;
//         $display("Halting without error");
//         $finish;
//     end
//     if (cpu.no_mem & ~cpu.stall) order = order + 1;
// end


urchin dut(
    .*
);

// cpu_datapath cpu
// (
//     .*
// );

// cache_hierarchy cache
// (
//     .*
// );

// magic_memory_dp mem
// (
//     .*
// );

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

// always @(posedge clk) begin
//     if (pmem_address == 32'hd80 && pmem_write) begin
//         $display("%0t pmem Writing to d80 %h", $time, pmem_wdata);
//     end
//     if (pmem_address == 32'hd80 && pmem_read) begin
//         $display("%0t pmem Reading from d80 %h", $time, pmem_rdata);
//     end
// end

shadow_memory sm
(
    .clk,

    .imem_valid(EX_ins_valid),
    .imem_addr(EX_pc),
    .imem_rdata(EX_ir),
    .dmem_valid(dmem_ready && WB_load && !dmem_write),
    .dmem_addr(dmem_write ? dmem_address : dmem_address_WB),
    .dmem_rdata,
    .write(dmem_write),
    .wmask(dmem_byte_enable),
    .wdata(dmem_wdata),
    .error(sm_error),
    .poison_inst(sm_poison)
);

endmodule : urchin_tb
