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
rv32i_reg cir_rs1, cir_rs1s, cir_rs2, cir_rs2s, cir_rd, cir_rds1, cir_rds2;
logic [2:0] funct3, c_funct3;
logic [6:0] funct7;
logic [1:0] funct2, funct;
logic [31:0] inst_pc;

assign ir_rs1 = ir[19:15];
assign ir_rs2 = ir[24:20];
assign ir_rd = ir[11:7];
assign cir_rs1 = ir[11:7];
assign cir_rd = ir[11:7];
assign cir_rs2 = ir[6:2];
assign cir_rs1s = {2'b00, ir[9:7]};
assign cir_rs2s = {2'b00, ir[4:2]};
assign cir_rds1 = {2'b00, ir[9:7]};
assign cir_rds2 = {2'b00, ir[4:2]};
assign funct3 = ir[14:12];
assign funct7 = ir[31:25];
assign opcode = rv32i_opcode'(ir[6:0]);
assign c_opcode = ir[1:0];
assign c_funct3 = ir[15:13];
assign funct2 = ir[11:10];
assign funct = ir[6:5];

logic error;
ctwimm_sel_t ctw_imm_sel;

rv32i_word imm_i_imm, imm_s_imm, imm_b_imm, imm_u_imm, imm_j_imm;
rv32i_word cimm_u_addi4sp_imm, cimm_addi16sp_imm, cimm_lui_imm;
rv32i_word cimm_u_lsw_imm, cimm_u_lwsp_imm, cimm_u_swsp_imm;
rv32i_word cimm_i_imm, cimm_u_imm, cimm_b_imm, cimm_j_imm;

assign imm_i_imm = {{21{ir[31]}}, ir[30:20]};
assign imm_s_imm = {{21{ir[31]}}, ir[30:25], ir[11:7]};
assign imm_b_imm = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
assign imm_u_imm = {ir[31:12], 12'h000};
assign imm_j_imm = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};

assign cimm_u_addi4sp_imm = {22'd0, ir[10:7], ir[12:11], ir[6], ir[7], 2'd0};
assign cimm_addi16sp_imm = {{22{ir[12]}}, ir[12], ir[4:3], ir[5], ir[2], ir[6], 4'd0};
assign cimm_u_lsw_imm = {25'd0, ir[5], ir[12:10], ir[6], 2'd0};
assign cimm_j_imm = {{20{ir[12]}}, ir[12], ir[8], ir[10:9], ir[6], ir[7], ir[2], ir[11], ir[5:3], 1'b0};
assign cimm_i_imm = {{26{ir[12]}}, ir[12], ir[6:2]};
assign cimm_lui_imm = {{14{ir[12]}}, ir[12], ir[6:2], 12'd0};
assign cimm_u_imm = {{26{1'b0}}, ir[12], ir[6:2]};
assign cimm_b_imm = {{23{ir[12]}}, ir[12], ir[6:5], ir[2], ir[11:10], ir[4:3], 1'b0};
assign cimm_u_lwsp_imm = {{24{1'b0}}, ir[3:2], ir[12], ir[6:4], 2'b00};
assign cimm_u_swsp_imm = {{24{1'b0}}, ir[8:7], ir[12:9], 2'b00};

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
    ctw.ir = ir;
    error = 1'd0;
    
    case(opcode)
        op_lui: begin
            ctw.load_regfile = 1'd1;
            ctw.wbmux_sel = wbm_imm;
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

        default: begin
            // C extension
            case(rv32ic_opcode'({c_opcode, c_funct3}))
                c_addi4spn: begin
                    ctw.aluop = alu_add;
                    ctw.rs1 = 5'd2;
                    ctw.rd = 5'd2;
                    ctw.load_regfile = 1'b1;
                    ctw_imm_sel = cimm_u_addi4sp;
                end

                c_lw: begin
                    ctw.aluop = alu_add;
                    ctw.dmem_read = 1'b1;
                    ctw.wbmux_sel = wbm_rdata;
                    ctw_imm_sel = cimm_u_lsw;
                    ctw.rs1 = cir_rs1s;
                    ctw.rd = cir_rds2;
                    ctw.load_regfile = 1'b1;
                end

                c_sw: begin
                    ctw.aluop = alu_add;
                    ctw.dmem_write = 1'b1;
                    ctw_imm_sel = cimm_u_lsw;
                    ctw.rs1 = cir_rs1s;
                    ctw.rs2 = cir_rs2s;
                end

                c_addi: begin
                    ctw.aluop = alu_add;
                    ctw.load_regfile = 1'b1;
                    ctw.rs1 = cir_rs1;
                    ctw.rd = cir_rd;
                    ctw_imm_sel = cimm_i;
                end

                c_jal: begin
                    ctw.load_regfile = 1'd1;
                    ctw.pcmux_sel = 2'b01;
                    ctw.alumux1_sel = alm1_pc;
                    ctw_imm_sel = cimm_j;
                    ctw.aluop = alu_add;
                    ctw.wbmux_sel = wbm_pc2;
                    ctw.rd = 5'd1;
                end

                c_li: begin
                    ctw.load_regfile = 1'd1;
                    ctw.wbmux_sel = wbm_imm;
                    ctw.rd = cir_rd;
                    ctw_imm_sel = cimm_i;
                end

                c_lui_addi16sp: begin
                    if (cir_rd == 5'd2) begin // addi16sp
                        ctw.aluop = alu_add;
                        ctw.rs1 = cir_rs1;
                        ctw.rd = cir_rd;
                        ctw.load_regfile = 1'b1;
                        ctw_imm_sel = cimm_addi16sp;
                    end else begin // lui
                        ctw.load_regfile = 1'b1;
                        ctw.wbmux_sel = wbm_imm;
                        ctw.rd = cir_rd;
                        ctw_imm_sel = cimm_lui;
                    end
                end

                c_misc_alu: begin
                    ctw.load_regfile = 1'b1;
                    ctw.rs1 = cir_rs1s;
                    ctw.rd = cir_rds1;
                    case(funct2)
                        2'b00: begin // srli
                            ctw_imm_sel = cimm_u;
                            ctw.aluop = alu_srl;
                        end
                        2'b01: begin // srai
                            ctw_imm_sel = cimm_u;
                            ctw.aluop = alu_sra;
                        end
                        2'b10: begin // andi
                            ctw_imm_sel = cimm_u;
                            ctw.aluop = alu_and;
                        end
                        2'b11: begin // reg-reg
                            ctw.rs2 = cir_rs2s;
                            ctw.alumux2_sel = alm2_rs2;
                            case(funct)
                                2'b00: begin // sub
                                    ctw.aluop = alu_sub;
                                end
                                2'b01: begin // xor
                                    ctw.aluop = alu_xor;
                                end
                                2'b10: begin // or
                                    ctw.aluop = alu_or;
                                end
                                2'b11: begin // and
                                    ctw.aluop = alu_and;
                                end
                            endcase
                        end
                    endcase
                end

                c_j: begin
                    ctw.pcmux_sel = 2'b01;
                    ctw.alumux1_sel = alm1_pc;
                    ctw_imm_sel =  cimm_j;
                    ctw.aluop = alu_add;
                end

                c_beqz, c_bnez: begin
                    ctw.cmpmux_sel = cmpmux_zero;
                    ctw.pcmux_sel = 2'b1X;
                    ctw.alumux1_sel = alm1_pc;
                    ctw_imm_sel = cimm_b;
                    ctw.aluop = alu_add;
                    ctw.rs1 = ir_rs1;
                    if (c_funct3[0]) begin // bnez
                        ctw.cmpop = bne;
                    end else begin // beqz
                        ctw.cmpop = beq;
                    end
                end

                c_slli: begin
                    ctw.aluop = alu_sll;
                    ctw.load_regfile = 1'b1;
                    ctw.rs1 = cir_rs1;
                    ctw.rd = cir_rd;
                    ctw_imm_sel = cimm_u;
                end

                c_lwsp: begin
                    ctw.rs1 = 5'd2;
                    ctw.rd = cir_rd;
                    ctw.load_regfile = 1'b1;
                    ctw_imm_sel = cimm_u_lwsp;
                    ctw.aluop = alu_add;
                    ctw.dmem_read = 1'b1;
                end

                c_jalr_mv_add: begin
                    if (ir[12]) begin
                        if (cir_rs2 == 5'd0) begin // jalr
                            ctw.load_regfile = 1'd1;
                            ctw.pcmux_sel = 2'b01;
                            ctw.aluop = alu_add;
                            ctw.wbmux_sel = wbm_pc2;
                            ctw.rs1 = ir_rs1;
                            ctw.rd = 5'd1;
                            ctw.alumux2_sel = alm2_zero;
                        end else begin // add
                            ctw.rs1 = cir_rs1;
                            ctw.rs2 = cir_rs2;
                            ctw.rd = cir_rd;
                            ctw.alumux2_sel = alm2_rs2;
                            ctw.aluop = alu_add;
                            ctw.load_regfile = 1'b1;
                        end
                    end else begin // jr/mv
                        if (cir_rs2 == 5'd0) begin // jr
                            ctw.pcmux_sel = 2'b01;
                            ctw.aluop = alu_add;
                            ctw.rs1 = ir_rs1;
                            ctw.alumux2_sel = alm2_zero;
                        end else begin // mv
                            ctw.rs1 = 5'd0;
                            ctw.rs2 = cir_rs2;
                            ctw.rd = cir_rd;
                            ctw.alumux2_sel = alm2_rs2;
                            ctw.aluop = alu_add;
                            ctw.load_regfile = 1'b1;
                        end
                    end
                end

                c_swsp: begin
                    ctw.rs1 = 5'd2;
                    ctw.rs2 = cir_rs2;
                    ctw_imm_sel = cimm_u_swsp;
                    ctw.aluop = alu_add;
                    ctw.dmem_write = 1'b1;
                end
                
                default: begin
                end
            endcase
        end
    endcase
end

always_comb begin
    case(ctw_imm_sel)
        imm_i: ctw.imm = imm_i_imm;
        imm_u: ctw.imm = imm_u_imm;
        imm_b: ctw.imm = imm_b_imm;
        imm_s: ctw.imm = imm_s_imm;
        imm_j: ctw.imm = imm_j_imm;
        cimm_u_addi4sp: ctw.imm = cimm_u_addi4sp_imm;
        cimm_addi16sp: ctw.imm = cimm_addi16sp_imm;
        cimm_u_lsw: ctw.imm = cimm_u_lsw_imm;
        cimm_j: ctw.imm = cimm_j_imm;
        cimm_i: ctw.imm = cimm_i_imm;
        cimm_u: ctw.imm = cimm_u_imm;
        cimm_lui: ctw.imm = cimm_lui_imm;
        cimm_b: ctw.imm = cimm_b_imm;
        cimm_u_lwsp: ctw.imm = cimm_u_lwsp_imm;
        cimm_u_swsp: ctw.imm = cimm_u_swsp_imm;
        default: ctw.imm = 32'dX;
    endcase
end

endmodule