import rv32i_types::*;

module old_cpu
(
    input clk,

    input mem_resp,
    input logic [31:0] mem_rdata,
    output logic mem_read,
    output logic mem_write,
    output logic [3:0] mem_byte_enable,
    output logic [31:0] mem_address,
    output logic [31:0] mem_wdata
);

logic load_pc, load_ir, load_regfile, load_mar, load_mdr, load_data_out;
logic pcmux_sel, alumux1_sel, marmux_sel, cmpmux_sel;
logic br_en;
logic [2:0] alumux2_sel, regfilemux_sel;
logic [2:0] funct3;
logic [6:0] funct7;
logic [1:0] lsb;
alu_ops aluop;
branch_funct3_t cmpop;
rv32i_reg rs1, rs2, rd, rs1_addr, rs2_addr, rd_addr;
rv32i_opcode opcode;

old_cpu_datapath datapath
(
    .*
);

old_cpu_control control
(
    .*
);

endmodule
