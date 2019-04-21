import rv32i_types::*;

module control_rom
(
    input rv32i_word ir,
    input rv32i_word pc,
    output rv32i_control_word ctw
);

rv32i_opcode opcode;
logic [1:0] c_opcode;
rv32i_reg ir_rs1, ir_rs2, ir_rd;
rv32i_reg cir_rs1, cir_rs1s, cir_rs2, cir_rs2s, cir_rd, cir_rds;
logic [2:0] funct3, c_funct3;
logic [6:0] funct7;
logic [31:0] inst_pc;

assign ir_rs1 = ir[19:15];
assign ir_rs2 = ir[24:20];
assign ir_rd = ir[11:7];
assign cir_rs1 = ir[11:7];
assign cir_rd = ir[11:7];
assign cir_rs2 = ir[6:2];
assign cir_rs1s = {2'b00, ir[9:7]};
assign cir_rs2s = {2'b00, ir[4:2]};
assign cir_rds = {2'b00, ir[4:2]};
assign funct3 = ir[14:12];
assign funct7 = ir[31:25];
assign opcode = rv32i_opcode'(ir[6:0]);
assign c_opcode = ir[1:0];

logic error;

rv32i_word i_imm, s_imm, b_imm, u_imm, j_imm;
rv32i_word c_lsw_uimm, ci_imm;

assign i_imm = {{21{ir_out_EX[31]}}, ir_out_EX[30:20]};
assign s_imm = {{21{ir_out_EX[31]}}, ir_out_EX[30:25], ir_out_EX[11:7]};
assign b_imm = {{20{ir_out_EX[31]}}, ir_out_EX[7], ir_out_EX[30:25], ir_out_EX[11:8], 1'b0};
assign u_imm = {ir_out_EX[31:12], 12'h000};
assign j_imm = {{12{ir_out_EX[31]}}, ir_out_EX[19:12], ir_out_EX[20], ir_out_EX[30:21], 1'b0};

assign c_addi4spn_uimm = {22'd0, ir[10:7], ir[12:11], ir[6], ir[7], 2'd0};
assign c_lsw_uimm = {25'd0, ir[5], ir[12:10], ir[6], 2'd0};
assign c_j_imm = {{20{ir[12]}}, ir[12], ir[8], ir[10:9], ir[6], ir[7], ir[2], ir[11], ir[5:3], 1'b0};
assign ci_imm = {{26{ir[12]}}, ir[12], ir[6:2]};
assign c_addi16sp_imm = {{22{ir[12]}}, ir[12], ir[4:3], ir[5], ir[2], ir[6], 4'd0};
assign c_lui_imm = {{14{ir[12]}}, ir[12], ir[6:2], 12'd0};
assign ci_uimm = {{26{1'b0}}, ir[12], ir[6:2]};
assign cb_imm = {{23{ir[12]}}, ir[12], ir[6:5], ir[2], ir[11:10], ir[4:3], 1'b0};
assign c_lwsp_uimm = {{24{1'b0}}, ir[3:2], ir[12], ir[6:4], 2'b00};
assign c_swsp_uimm = {{24{1'b0}}, ir[8:7], ir[12:9], 2'b00};

always_comb begin
    case(ctw_imm_sel)
        
        default:
    endcase
end

always_comb begin : control_word_generation_logic
    ctw_imm_sel = i_imm_sel;
    ctw.opcode = opcode;
    ctw.aluop = alu_ops'(funct3);
    ctw.cmpop = branch_funct3_t'(funct3);
    ctw.dmem_read = 1'd0;
    ctw.dmem_write = 1'd0;
    ctw.wbmux_sel = alu_out_wb_sel;
    ctw.cmpmux_sel = 1'd0;
    ctw.alumux1_sel = rs1_EX_sel;
    ctw.alumux2_sel = imm_sel;
    ctw.pcmux_sel = 2'd0;
    ctw.load_regfile = 1'd0;
    ctw.funct3 = funct3;
    ctw.funct7 = funct7;
    ctw.pc = pc;
    ctw.rs1 = 5'd0;
    ctw.rs2 = 5'd0;
    ctw.rd = 5'd0;
    ctw.ir = ir;
    error = 1'd0;
    
    case(opcode)
        op_lui: begin
            ctw.load_regfile = 1'd1;
            ctw.wbmux_sel = imm_wb_sel;
            ctw.rd = ir_rd;
        end

        op_auipc: begin
            ctw.load_regfile = 1'd1;
            ctw.aluop = alu_add;
            ctw.alumux1_sel = pc_out_sel;
            ctw.alumux2_sel = imm_sel;
            ctw_imm_sel = u_imm_sel;
            ctw.rd = ir_rd;
        end

        op_jal: begin
            ctw.load_regfile = 1'd1;
            ctw.pcmux_sel = 2'b01;
            ctw.alumux1_sel = pc_out_sel;
            ctw.alumux2_sel = imm_sel;
            ctw_imm_sel = j_imm_sel;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = pc_inc_wb_sel;
            ctw.rd = ir_rd;
        end

        op_jalr: begin
            ctw.load_regfile = 1'd1;
            ctw.pcmux_sel = 2'b01;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = pc_inc_wb_sel;
            ctw.rs1 = ir_rs1;
            ctw.rd = ir_rd;
        end

        op_br: begin
            ctw.pcmux_sel = 2'b1X;
            ctw.alumux1_sel = pc_out_sel;
            ctw.alumux2_sel = imm_sel;
            ctw_imm_sel = b_imm_sel;
            ctw.aluop = alu_add;
            ctw.rs1 = ir_rs1;
            ctw.rs2 = ir_rs2;
        end

        op_load: begin
            ctw.load_regfile = 1'd1;
            ctw.aluop = alu_add;
            ctw.dmem_read = 1'b1;
            ctw.wbmux_sel = rdata_wb_sel;
            ctw.rs1 = ir_rs1;
            ctw.rd = ir_rd;
        end

        op_store: begin
            ctw.aluop = alu_add;
            ctw_imm_sel = s_imm_sel;
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
                ctw.wbmux_sel = br_en_wb_sel;
                ctw.cmpmux_sel = 1'b1;
            end else if(arith_funct3_t'(funct3) == sltu) begin
                ctw.cmpop = bltu;
                ctw.wbmux_sel = br_en_wb_sel;
                ctw.cmpmux_sel = 1'b1;
            end else if(arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sra;
            end
        end

        op_reg: begin
            ctw.load_regfile = 1'd1;
            ctw.rs1 = ir_rs1;
            ctw.rs2 = ir_rs2;
            ctw.rd = ir_rd;
            if(arith_funct3_t'(funct3) == slt) begin
                ctw.cmpop = blt;
                ctw.wbmux_sel = br_en_wb_sel;
            end else if(arith_funct3_t'(funct3) == sltu) begin
                ctw.cmpop = bltu;
                ctw.wbmux_sel = br_en_wb_sel;
            end else if(arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sra;
                ctw.alumux2_sel = rs2_EX_sel;
            end else if(arith_funct3_t'(funct3) == add && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sub;
                ctw.alumux2_sel = rs2_EX_sel;
            end else begin
                ctw.alumux2_sel = rs2_EX_sel;
            end
        end

        op_nop: ;

        default: begin
            // C extension
            case(rv32ic_opcode'({c_opcode, c_funct3}))
                c_addi4spn: begin
                    ctw.aluop = alu_add;
                    ctw.rs1 = 5'd2;
                    ctw.rd = 5'd2;
                    ctw.load_regfile = 1'b1;
                    ctw_imm_sel = c_addi4spn_uimm_sel;
                end

                c_lw: begin
                    ctw.aluop = alu_add;
                    ctw.dmem_read = 1'b1;
                    ctw.wbmux_sel = rdata_wb_sel;
                    ctw_imm_sel = c_lsw_uimm;
                    ctw.rs1 = cir_rs1s;
                    ctw.rd = ir_rds;
                    ctw.load_regfile = 1'b1;
                end

                c_sw: begin
                    ctw.aluop = alu_add;
                    ctw.dmem_write = 1'b1;
                    ctw_imm_sel = c_lsw_uimm;
                    ctw.rs1 = cir_rs1s;
                    ctw.rs2 = cir_rs2s;
                end

                c_addi: begin
                    ctw.aluop = alu_add;
                    ctw.load_regfile = 1'b1;
                    ctw.rs1 = cir_rs1;
                    ctw.rd = cir_rd;
                    ctw_imm_sel = ci_imm;
                end

                c_jal: begin
                end

                c_li: begin
                end

                c_lui_addi16sp: begin
                end

                c_misc_alu: begin
                end

                c_j: begin
                end

                c_beqz: begin
                end

                c_bnez: begin
                end

                c_slli: begin
                end

                c_lwsp: begin
                end

                c_jalr_mv_add: begin
                end

                c_swsp: begin
                end
                
                default: begin
                end
            endcase
        end
    endcase
end

endmodule