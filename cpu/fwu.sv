import rv32i_types::*;

module fwu (
    input logic load_regfile_MEM,
    input logic load_regfile_WB,
    input rv32i_reg rs1,
    input rv32i_reg rs2,
    input rv32i_reg rd_MEM,
    input rv32i_reg rd_WB,
    input logic [1:0] ctw_alumux1_sel,
    input logic [2:0] ctw_alumux2_sel,
    output logic [1:0] alumux1_sel,
    output logic [2:0] alumux2_sel
);

always_comb begin : data_forwarding_logic
    // MEM stage has the more recent results that should be used if possible
    if (load_regfile_MEM && rd_MEM != 0) begin
        alumux1_sel = (rd_MEM == rs1) ? 2'd2 : ctw_alumux1_sel;
        alumux2_sel = (rd_MEM == rs2) ? 3'd6 : ctw_alumux2_sel;
    end else if (load_regfile_WB && rd_WB != 0) begin
        alumux1_sel = (rd_WB == rs1) ? 2'd3 : ctw_alumux1_sel;
        alumux2_sel = (rd_WB == rs2) ? 3'd7 : ctw_alumux2_sel;
    end else begin
        alumux1_sel = ctw_alumux1_sel;
        alumux2_sel = ctw_alumux2_sel;
    end
end
    
endmodule