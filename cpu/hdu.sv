import rv32i_types::*;

module hdu (
    input logic dmem_read_EX,
    input rv32i_reg rs1,
    input rv32i_reg rs2,
    input rv32i_reg rd_EX,
    output logic stall
);

assign stall = dmem_read_EX && (rs1 == rd_EX || rs2 == rd_EX);

endmodule