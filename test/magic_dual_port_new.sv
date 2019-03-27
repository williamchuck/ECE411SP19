/*
 * Dual-port magic memory
 *
 */

module magic_memory_dp
(
    input clk,

    /* Port A */
    input imem_read,
    input [31:0] imem_address,
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

initial
begin
    $readmemh("memory.lst", mem);
end

assign internal_imem_address = imem_address[26:0];
assign internal_dmem_address = dmem_address[26:0];

always @(posedge clk)
begin : response
    if (imem_read) begin
        imem_resp <= 1'b1;
        for (int i = 0; i < 4; i++) begin
            imem_rdata[i*8 +: 8] <= mem[internal_imem_address+i];
        end
    end else begin
        imem_resp <= 1'b0;
    end

    if (dmem_read) begin
        dmem_resp <= 1'b1;
        for (int i = 0; i < 4; i++) begin
            dmem_rdata[i*8 +: 8] <= mem[internal_dmem_address+i];
        end
    end else if (dmem_write) begin
        dmem_resp <= 1'b1;
        for (int i = 0; i < 4; i++) begin
            if (dmem_byte_enable[i])
            begin
                mem[internal_dmem_address+i] <= dmem_wdata[i*8 +: 8];
            end
        end
    end else begin
        dmem_resp <= 1'b0;
    end
end : response

endmodule : magic_memory_dp

