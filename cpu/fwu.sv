import rv32i_types::*;

module fwu (
    input logic load_regfile_MEM,
    input logic load_regfile_WB_,
    input logic load_regfile_WB,
    input rv32i_reg rs1,
    input rv32i_reg rs2,
    input rv32i_reg rs1_EX,
    input rv32i_reg rs2_EX,
    input rv32i_reg rd_MEM,
    input rv32i_reg rd_WB_,
    input rv32i_reg rd_WB,
    output logic rs1_out_sel,
    output logic rs2_out_sel,
    output logic [1:0] rs1_out_EX_sel,
    output logic [1:0] rs2_out_EX_sel
);

always_comb begin : data_forwarding_logic
    // MEM stage has the more recent results that should be used if possible
    if (load_regfile_MEM && rd_MEM != 0 && rd_MEM == rs1_EX) begin
        rs1_out_EX_sel = 2'd1 ;
    end else if (load_regfile_WB_ && rd_WB_ != 0 && rd_WB_ == rs1_EX) begin
        rs1_out_EX_sel = 2'd2;
    end else if (load_regfile_WB && rd_WB != 0 && rd_WB == rs1_EX) begin
        rs1_out_EX_sel = 2'd3;
    end else begin
        rs1_out_EX_sel = 2'd0;
    end

    if (load_regfile_MEM && rd_MEM != 0 && rd_MEM == rs2_EX) begin
        rs2_out_EX_sel = 2'd1;
    end else if (load_regfile_WB_ && rd_WB_ != 0 && rd_WB_ == rs2_EX) begin
        rs2_out_EX_sel = 2'd2;
    end else if (load_regfile_WB && rd_WB != 0 && rd_WB == rs2_EX) begin 
        rs2_out_EX_sel = 2'd3;        
    end else begin
        rs2_out_EX_sel = 2'd0;
    end

    if (load_regfile_WB && rd_WB != 0 && rd_WB == rs1) begin
        rs1_out_sel = 1'd1;
    end else begin
        rs1_out_sel = 1'd0;
    end

    if (load_regfile_WB && rd_WB != 0 && rd_WB == rs2) begin
        rs2_out_sel = 1'd1;
    end else begin
        rs2_out_sel = 1'd0;
    end
end
    
endmodule