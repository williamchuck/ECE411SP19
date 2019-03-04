module control_rom
(
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output rv32i_control_word ctw
);

always_comb begin : control_word_generation_logic
    ctw.opcode = opcode;
    ctw.aluop = alu_ops'(funct3)
    ctw.cmpop = branch_funct3_t'(funct3)
    ctw.load_regfile = 0;
    ctw.dmem_read = 0;
    ctw.dmem_write = 0;
    ctw.wbmux_sel = 0;
    ctw.cmpmux_sel = 0;
    alumux1_sel = 0;
    alumux2_sel = 3'b000;

    case(opcode)
        op_lui: begin
            ctw.load_regfile = 1;
            ctw.alumux1_sel = 1;
            ctw.alumux2_sel = 3'b010;
        end

        op_auipc: begin
            ctw.aluop = alu_add;
            ctw.load_regfile = 1;
            ctw.alumux1_sel = 1;
            ctw.alumux2_sel = 3'b001;
        end
        default: $display("Unknown opcode");
    endcase
end

endmodule