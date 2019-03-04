import rv32i_types::*;

module control_rom
(
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output rv32i_control_word ctw
);

always_comb begin : control_word_generation_logic
    ctw.opcode = opcode;
    ctw.aluop = alu_ops'(funct3);
    ctw.cmpop = branch_funct3_t'(funct3);
    ctw.dmem_read = 1'd0;
    ctw.dmem_write = 1'd0;
    ctw.wbmux_sel = 3'd0;
    ctw.cmpmux_sel = 1'd0;
    ctw.alumux1_sel = 2'd0;
    ctw.alumux2_sel = 3'd0;
    ctw.dmem_address_sel = 1'd0;
    
    case(opcode)
        op_lui: begin
            ctw.wbmux_sel = 3'd2;
        end

        op_auipc: begin
            ctw.aluop = alu_add;
            ctw.alumux1_sel = 2'd1;
            ctw.alumux2_sel = 3'd1;
        end

        op_jal: begin
            ctw.pcmux_sel = 2'b01;
            ctw.alumux1_sel = 2'd1;
            ctw.alumux2_sel = 3'd4;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = 3'd4;
        end

        op_jalr: begin
            ctw.pcmux_sel = 2'b01;
            ctw.aluop = alu_add;
            ctw.wbmux_sel = 3'd4;
        end

        op_br: begin
            ctw.pcmux_sel = 2'b1X;
            ctw.alumux1_sel = 2'd1;
            ctw.alumux2_sel = 3'd2;
            ctw.aluop = alu_add;
        end

        op_load: begin
            ctw.aluop = alu_add;
            ctw.dmem_address_sel = 1'd1;
            ctw.dmem_read = 1'b1;
            ctw.wbmux_sel = 3'd3;
        end

        op_store: begin
            ctw.aluop = alu_add;
            ctw.dmem_address_sel = 1'd1;
            ctw.alumux2_sel = 3'd3;
            ctw.dmem_write = 1'b1;
        end

        op_imm: begin
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
            if(arith_funct3_t'(funct3) == slt) begin
                ctw.cmpop = blt;
                ctw.wbmux_sel = 3'd1;
                ctw.cmpmux_sel = 1'b1;
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
        default: $display("Unknown opcode");
    endcase
end

endmodule