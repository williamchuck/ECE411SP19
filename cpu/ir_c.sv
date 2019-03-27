import rv32i_types::*;

module ir_c
(

    input clk,
    input load,
    input [31:0] in,
    output [2:0] c_funct3,
    output [6:0] c_funct4,
    output rv32i_c_opcode c_opcode,
    output [31:0] ci_imm,
    output [31:0] css_imm,
    output [31:0] ciw_imm,
    output [31:0] clcs_imm,
    output [4:0] rdrs1,
    output [4:0] rs2,
    output [2:0] rd_c,
    output [2:0] rs1_c,
    output [31:0] jmp_target,
    output [31:0] offset
);