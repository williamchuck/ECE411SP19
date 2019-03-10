import rv32i_types::*;

module fwu (
    input logic load_regfile_MEM,
    input logic load_regfile_WB,
    input rv32i_reg rs1_EX,
    input rv32i_reg rs2_EX,
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
        alumux1_sel = (rd_MEM == rs1_EX && ctw_alumux1_sel == 3'd0) ? 2'd2 : ctw_alumux1_sel;
        alumux2_sel = (rd_MEM == rs2_EX && ctw_alumux2_sel == 3'd5) ? 3'd6 : ctw_alumux2_sel;
    end else if (load_regfile_WB && rd_WB != 0) begin
        alumux1_sel = (rd_WB == rs1_EX && ctw_alumux1_sel == 3'd0) ? 2'd3 : ctw_alumux1_sel;
        alumux2_sel = (rd_WB == rs2_EX && ctw_alumux2_sel == 3'd5) ? 3'd7 : ctw_alumux2_sel;
    end else begin
        alumux1_sel = ctw_alumux1_sel;
        alumux2_sel = ctw_alumux2_sel;
    end
end
    
endmodule