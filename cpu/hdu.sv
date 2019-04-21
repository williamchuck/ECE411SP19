import rv32i_types::*;

module hdu (
    input logic dmem_read_EX,
    input logic dmem_read_MEM,
    input rv32i_reg rs1,
    input rv32i_reg rs2,
    input rv32i_reg rd_EX,
    input rv32i_reg rd_MEM,
    output logic stall
);

assign stall = dmem_read_EX && (rs1 == rd_EX || rs2 == rd_EX)
            || dmem_read_MEM && (rs1 == rd_MEM || rs2 == rd_MEM);

endmodule