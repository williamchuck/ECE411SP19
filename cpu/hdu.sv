module hdu (
    input logic dmem_read_EX,
    input logic rs1,
    input logic rs2,
    input logic rd_EX,
    output logic stall
);

assign stall = dmem_read_EX && (rs1 == rd_EX || rs2 == rd_EX);
    
endmodule