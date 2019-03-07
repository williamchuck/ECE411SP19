/*
 * Dual-port magic memory
 *
 * Usage note: Avoid writing to the same address on both ports simultaneously.
 */

module magic_memory_dp
(
    input clk,

    /* Port A */
    input imem_read,
    input imem_write,
    input [3:0] imem_byte_enable,
    input [31:0] imem_address,
    input [31:0] imem_wdata,
    output logic imem_resp,
    output logic [31:0] imem_rdata,

    /* Port B */
    input dmem_read,
    input dmem_write,
    input [3:0] dmem_byte_enable,
    input [31:0] dmem_address,
    input [31:0] dmem_wdata,
    output logic dmem_resp,
    output logic [31:0] dmem_rdata
);

timeunit 1ns;
timeprecision 1ns;

logic [7:0] mem [2**(27)];
logic [26:0] internal_imem_address;
logic [26:0] internal_dmem_address;

/* Initialize memory contents from memory.lst file */
initial
begin
    $readmemh("memory.lst", mem);
end

/* Calculate internal address */
assign internal_imem_address = imem_address[26:0];
assign internal_dmem_address = dmem_address[26:0];

/* Read */
always_comb
begin : mem_imem_read
    imem_rdata = {mem[internal_imem_address+3], mem[internal_imem_address+2], mem[internal_imem_address+1], mem[internal_imem_address]};
    dmem_rdata = {mem[internal_dmem_address+3], mem[internal_dmem_address+2], mem[internal_dmem_address+1], mem[internal_dmem_address]};
end : mem_imem_read

/* Port A write */
always @(posedge clk)
begin : mem_imem_write
    if (imem_write)
    begin
        if (imem_byte_enable[3])
        begin
            mem[internal_imem_address+3] = imem_wdata[31:24];
        end

        if (imem_byte_enable[2])
        begin
            mem[internal_imem_address+2] = imem_wdata[23:16];
        end

        if (imem_byte_enable[1])
        begin
            mem[internal_imem_address+1] = imem_wdata[15:8];
        end

        if (imem_byte_enable[0])
        begin
            mem[internal_imem_address] = imem_wdata[7:0];
        end
    end
end : mem_imem_write

/* Port B write */
always @(posedge clk)
begin : mem_dmem_write
    if (dmem_write)
    begin
        if (dmem_byte_enable[3])
        begin
            mem[internal_dmem_address+3] = dmem_wdata[31:24];
        end

        if (dmem_byte_enable[2])
        begin
            mem[internal_dmem_address+2] = dmem_wdata[23:16];
        end

        if (dmem_byte_enable[1])
        begin
            mem[internal_dmem_address+1] = dmem_wdata[15:8];
        end

        if (dmem_byte_enable[0])
        begin
            mem[internal_dmem_address] = dmem_wdata[7:0];
        end
    end
end : mem_dmem_write

/* Magic memory responds immediately */
assign imem_resp = imem_read | imem_write;
assign dmem_resp = dmem_read | dmem_write;

endmodule : magic_memory_dp

