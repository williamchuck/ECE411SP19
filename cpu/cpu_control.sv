import rv32i_types::*;

module control_rom
(
    input rv32i_word ir,
    input rv32i_word pc,
    output rv32i_control_word ctw
);

rv32i_opcode opcode;
rv32i_reg ir_rs1, ir_rs2, ir_rd;
logic [2:0] funct3;
logic [6:0] funct7;

assign ir_rs1 = ir[19:15];
assign ir_rs2 = ir[24:20];
assign ir_rd = ir[11:7];
assign funct3 = ir[14:12];
assign funct7 = ir[31:25];
assign opcode = rv32i_opcode'(ir[6:0]);

ctwimm_sel_t ctw_imm_sel;

rv32i_word imm_i_imm, imm_s_imm, imm_b_imm, imm_u_imm, imm_j_imm;

assign imm_i_imm = {{21{ir[31]}}, ir[30:20]};
assign imm_s_imm = {{21{ir[31]}}, ir[30:25], ir[11:7]};
assign imm_b_imm = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
assign imm_u_imm = {ir[31:12], 12'h000};
assign imm_j_imm = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};

always_comb begin : control_word_generation_logic
    ctw_imm_sel = imm_i;
    ctw.opcode = opcode;
    ctw.muldiv = 1'b0;
    ctw.aluop = alu_ops'(funct3);
    ctw.cmpop = branch_funct3_t'(funct3);
    ctw.dmem_read = 1'd0;
    ctw.dmem_write = 1'd0;
    ctw.wbmux_sel = wbm_alu;
    ctw.cmpmux_sel = cmpmux_rs2;
    ctw.alumux1_sel = alm1_rs1;
    ctw.alumux2_sel = alm2_imm;
    ctw.pcmux_sel = 2'd0;
    ctw.load_regfile = 1'd0;
    ctw.funct3 = funct3;
    ctw.funct7 = funct7;
    ctw.pc = pc;
    ctw.rs1 = 5'd0;
    ctw.rs2 = 5'd0;
    ctw.rd = 5'd0;
    
    case(opcode)
        op_lui: begin
            ctw.load_regfile = 1'd1;
            ctw.wbmux_sel = wbm_imm;
            ctw_imm_sel = imm_u;
            ctw.rd = ir_rd;
        end

        op_auipc: begin
            ctw.load_regfile = 1'd1;
            ctw.aluop = alu_add;
            ctw.alumux1_sel = alm1_pc;
            ctw_imm_sel = imm_u;
            ctw.rd = ir_rd;
        end

        op_jal: begin
            ctw.load_regfile = 1'd1;
            ctw.pcmux_sel = 2'b01;
            ctw.alumux1_sel = alm1_pc;
            ctw_imm_sel = imm_j;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = wbm_pc4;
            ctw.rd = ir_rd;
        end

        op_jalr: begin
            ctw.load_regfile = 1'd1;
            ctw.pcmux_sel = 2'b01;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = wbm_pc4;
            ctw.rs1 = ir_rs1;
            ctw.rd = ir_rd;
        end

        op_br: begin
            ctw.pcmux_sel = 2'b1X;
            ctw.alumux1_sel = alm1_pc;
            ctw_imm_sel = imm_b;
            ctw.aluop = alu_add;
            ctw.rs1 = ir_rs1;
            ctw.rs2 = ir_rs2;
        end

        op_load: begin
            ctw.load_regfile = 1'd1;
            ctw.aluop = alu_add;
            ctw.dmem_read = 1'b1;
            ctw.wbmux_sel = wbm_rdata;
            ctw.rs1 = ir_rs1;
            ctw.rd = ir_rd;
        end

        op_store: begin
            ctw.aluop = alu_add;
            ctw_imm_sel = imm_s;
            ctw.dmem_write = 1'b1;
            ctw.rs1 = ir_rs1;
            ctw.rs2 = ir_rs2;
        end

        op_imm: begin
            ctw.load_regfile = 1'd1;
            ctw.rs1 = ir_rs1;
            ctw.rd = ir_rd;
            if(arith_funct3_t'(funct3) == slt) begin
                ctw.cmpop = blt;
                ctw.wbmux_sel = wbm_br;
                ctw.cmpmux_sel = cmpmux_imm;
            end else if(arith_funct3_t'(funct3) == sltu) begin
                ctw.cmpop = bltu;
                ctw.wbmux_sel = wbm_br;
                ctw.cmpmux_sel = cmpmux_imm;
            end else if(arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sra;
            end
        end

        op_reg: begin
            ctw.load_regfile = 1'd1;
            ctw.rs1 = ir_rs1;
            ctw.rs2 = ir_rs2;
            ctw.rd = ir_rd;
            if (funct7 == 7'b0000001) begin
                ctw.muldiv = 1'b1;
                ctw.alumux2_sel = alm2_rs2;
            end else if (arith_funct3_t'(funct3) == slt) begin
                ctw.cmpop = blt;
                ctw.wbmux_sel = wbm_br;
            end else if (arith_funct3_t'(funct3) == sltu) begin
                ctw.cmpop = bltu;
                ctw.wbmux_sel = wbm_br;
            end else if (arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sra;
                ctw.alumux2_sel = alm2_rs2;
            end else if (arith_funct3_t'(funct3) == add && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sub;
                ctw.alumux2_sel = alm2_rs2;
            end else begin
                ctw.alumux2_sel = alm2_rs2;
            end 
        end

        op_nop: ;

        default: ;
    endcase
end

always_comb begin
    case(ctw_imm_sel)
        imm_i: ctw.imm = imm_i_imm;
        imm_u: ctw.imm = imm_u_imm;
        imm_b: ctw.imm = imm_b_imm;
        imm_s: ctw.imm = imm_s_imm;
        imm_j: ctw.imm = imm_j_imm;
        default: ctw.imm = 32'dX;
    endcase
end

endmodule