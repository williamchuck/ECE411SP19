import rv32i_types::*;

module control_rom
(
    input rv32i_word ir,
    // input rv32i_opcode opcode,
    // input logic [2:0] funct3,
    // input logic [6:0] funct7,
    // input rv32i_reg ir_rs1,
    // input rv32i_reg ir_rs2,
    // input rv32i_reg ir_rd,
    output rv32i_control_word ctw,
    output rv32i_reg rs1,
    output rv32i_reg rs2,
    output rv32i_reg rd
);

rv32i_opcode opcode;
logic [1:0] c_opcode;
rv32i_reg ir_rs1, ir_rs2, ir_rd;
logic [2:0] funct3, c_funct3;
logic [6:0] funct7;

assign ir_rs1 = ir[19:15];
assign ir_rs2 = ir[24:20];
assign ir_rd = ir[11:7]
assign funct3 = ir[14:12];
assign funct7 = ir[31:25];
assign opcode = rv32i_opcode'(ir[6:0]);
assign c_opcode = ir[1:0];

logic error;

always_comb begin : control_word_generation_logic
    ctw.opcode = opcode;
    ctw.aluop = alu_ops'(funct3);
    ctw.cmpop = branch_funct3_t'(funct3);
    ctw.dmem_read = 1'd0;
    ctw.dmem_write = 1'd0;
    ctw.wbmux_sel = 3'd0;
    ctw.cmpmux_sel = 1'd0;
    ctw.alumux1_sel = 1'd0;
    ctw.alumux2_sel = 3'd0;
    ctw.pcmux_sel = 2'd0;
    ctw.load_regfile = 1'd0;
    ctw.funct3 = funct3;
    ctw.funct7 = funct7;
    rs1 = 5'd0;
    rs2 = 5'd0;
    rd = 5'd0;
    error = 1'd0;
    
    case(opcode)
        op_lui: begin
            ctw.load_regfile = 1'd1;
            ctw.wbmux_sel = 3'd2;
            rd = ir_rd;
        end

        op_auipc: begin
            ctw.load_regfile = 1'd1;
            ctw.aluop = alu_add;
            ctw.alumux1_sel = 1'd1;
            ctw.alumux2_sel = 3'd1;
            rd = ir_rd;
        end

        op_jal: begin
            ctw.load_regfile = 1'd1;
            ctw.pcmux_sel = 2'b01;
            ctw.alumux1_sel = 1'd1;
            ctw.alumux2_sel = 3'd4;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = 3'd4;
            rd = ir_rd;
        end

        op_jalr: begin
            ctw.load_regfile = 1'd1;
            ctw.pcmux_sel = 2'b01;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = 3'd4;
            rs1 = ir_rs1;
            rd = ir_rd;
        end

        op_br: begin
            ctw.pcmux_sel = 2'b1X;
            ctw.alumux1_sel = 1'd1;
            ctw.alumux2_sel = 3'd2;
            ctw.aluop = alu_add;
            rs1 = ir_rs1;
            rs2 = ir_rs2;
        end

        op_load: begin
            ctw.load_regfile = 1'd1;
            ctw.aluop = alu_add;
            ctw.dmem_read = 1'b1;
            ctw.wbmux_sel = 3'd3;
            rs1 = ir_rs1;
            rd = ir_rd;
        end

        op_store: begin
            ctw.aluop = alu_add;
            ctw.alumux2_sel = 3'd3;
            ctw.dmem_write = 1'b1;
            rs1 = ir_rs1;
            rs2 = ir_rs2;
        end

        op_imm: begin
            ctw.load_regfile = 1'd1;
            rs1 = ir_rs1;
            rd = ir_rd;
            if(arith_funct3_t'(funct3) == slt) begin
                ctw.cmpop = blt;
                ctw.wbmux_sel = 3'd1;
                ctw.cmpmux_sel = 1'b1;
            end else if(arith_funct3_t'(funct3) == sltu) begin
                ctw.cmpop = bltu;
                ctw.wbmux_sel = 3'd1;
                ctw.cmpmux_sel = 1'b1;
            end else if(arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sra;
            end
        end

        op_reg: begin
            ctw.load_regfile = 1'd1;
            rs1 = ir_rs1;
            rs2 = ir_rs2;
            rd = ir_rd;
            if(arith_funct3_t'(funct3) == slt) begin
                ctw.cmpop = blt;
                ctw.wbmux_sel = 3'd1;
            end else if(arith_funct3_t'(funct3) == sltu) begin
                ctw.cmpop = bltu;
                ctw.wbmux_sel = 3'd1;
            end else if(arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sra;
                ctw.alumux2_sel = 3'd5;
            end else if(arith_funct3_t'(funct3) == add && funct7 == 7'b0100000) begin
                ctw.aluop = alu_sub;
                ctw.alumux2_sel = 3'd5;
            end else begin
                ctw.alumux2_sel = 3'd5;
            end
        end

        op_nop: ;

        default: begin
            // C extension
            case({c_opcode, c_funct3})
                c_addi4spn: begin
                    ctw.aluop = alu_add;
                end

                c_lw: begin
                end

                c_sw: begin
                end

                c_addi: begin
                end

                c_jal: begin
                end

                c_li: begin
                    
                end

                c_lui: begin
                    // Complicated
                end

                c_alu: begin
                    
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

                c_jrmvadd: begin
                    
                end

                c_swsp: begin
                    
                end
                default: ;
            endcase
        end
    endcase
end

endmodule