import rv32i_types::*;

module old_cpu_datapath
(
    input clk,

    /* control signals */
    input load_pc,
    input load_ir,
    input load_regfile,
    input load_mar,
    input load_mdr,
    input load_data_out,
    input pcmux_sel,
    input alumux1_sel,
    input logic [2:0] alumux2_sel,
    input logic [2:0] regfilemux_sel,
    input marmux_sel,
    input cmpmux_sel,
    input alu_ops aluop,
    input branch_funct3_t cmpop,
    input rv32i_reg rs1_addr, rs2_addr, rd_addr,

    output logic [1:0] lsb,
    output rv32i_reg rs1,
    output rv32i_reg rs2,
    output rv32i_reg rd,
    output rv32i_opcode opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic br_en,

    // Memory
    input rv32i_word mem_rdata,
    output rv32i_word mem_wdata,
    output rv32i_word mem_address
);

// MARK: - Internal signals

// PC
rv32i_word pcmux_out;
rv32i_word pc_out;
rv32i_word pc_plus4_out;
// MDR
rv32i_word mdrreg_out, mdr_out_ext;
rv32i_word marmux_out, mar_out;
// IR
rv32i_word i_imm, s_imm, b_imm, u_imm, j_imm;
// Regfile
rv32i_word rs1_out, rs2_out;
rv32i_word regfilemux_out;
// ALU
rv32i_word alumux1_out, alumux2_out;
rv32i_word alu_out;
// CMP
rv32i_word cmpmux_out;
rv32i_word br_en_zext;

assign pc_plus4_out = pc_out + 32'h00000004;
assign br_en_zext = br_en == 1'b0 ? 32'h00000000 : 32'h00000001;
assign lsb = mar_out[1:0];
assign mem_address = mar_out & 32'hfffffffc;

// MARK: - PC components

mux2 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus4_out),
    .b(alu_out),
    .f(pcmux_out)
);

pc_register pc
(
    .clk,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

// MARK: - IR components

ir IR
(
    .*,
    .load(load_ir),
    .in(mdrreg_out)
);

// MARK: - Regfile components

regfile regfile
(
    .clk,
    .load(load_regfile),
    .in(regfilemux_out),
    .rs1(rs1_addr),
    .rs2(rs2_addr),
    .rd(rd_addr),
    .rs1_out(rs1_out),
    .rs2_out(rs2_out)
);

always_comb begin : mdr_out_extender
    case(load_funct3_t'(funct3))
        lb: begin
            case(lsb)
                2'b00: mdr_out_ext = {{24{mdrreg_out[7]}}, mdrreg_out[7:0]};
                2'b01: mdr_out_ext = {{24{mdrreg_out[15]}}, mdrreg_out[15:8]};
                2'b10: mdr_out_ext = {{24{mdrreg_out[23]}}, mdrreg_out[23:16]};
                2'b11: mdr_out_ext = {{24{mdrreg_out[31]}}, mdrreg_out[31:24]};
                default: mdr_out_ext = mdrreg_out;
            endcase
        end
        lh: begin
            case(lsb)
                2'b00: mdr_out_ext = {{16{mdrreg_out[15]}}, mdrreg_out[15:0]};
                2'b10: mdr_out_ext = {{16{mdrreg_out[31]}}, mdrreg_out[31:16]};
                default: mdr_out_ext = mdrreg_out;
            endcase
        end
        lbu: begin
            case(lsb)
                2'b00: mdr_out_ext = {24'h000000, mdrreg_out[7:0]};
                2'b01: mdr_out_ext = {24'h000000, mdrreg_out[15:8]};
                2'b10: mdr_out_ext = {24'h000000, mdrreg_out[23:16]};
                2'b11: mdr_out_ext = {24'h000000, mdrreg_out[31:24]};
                default: mdr_out_ext = mdrreg_out;
            endcase
        end
        lhu: begin
            case(lsb)
                2'b00: mdr_out_ext = {16'h0000, mdrreg_out[15:0]};
                2'b10: mdr_out_ext = {16'h0000, mdrreg_out[31:16]};
                default: mdr_out_ext = mdrreg_out;
            endcase
        end
        default: mdr_out_ext = mdrreg_out;
    endcase
end

mux8 regfilemux
(
    .sel(regfilemux_sel),
    .a0(alu_out),
    .a1(br_en_zext),
    .a2(u_imm),
    .a3(mdr_out_ext),
    .a4(pc_plus4_out),
    .a5(32'h00000000),
    .a6(32'h00000000),
    .a7(32'h00000000),
    .f(regfilemux_out)
);

// MARK: - ALU components

mux2 alumux1
(
  .sel(alumux1_sel),
  .a(rs1_out),
  .b(pc_out),
  .f(alumux1_out)
);

mux8 alumux2
(
    .sel(alumux2_sel),
    .a0(i_imm),
    .a1(u_imm),
    .a2(b_imm),
    .a3(s_imm),
    .a4(j_imm),
    .a5(rs2_out),
    .a6(32'h00000000),
    .a7(32'h00000000),
    .f(alumux2_out)
);

alu alu
(
    .aluop,
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out)
);

// MARK: - CMP components

mux2 cmpmux
(
    .sel(cmpmux_sel),
    .a(rs2_out),
    .b(i_imm),
    .f(cmpmux_out)
);

compare cmp
(
    .cmpop,
    .arg1(rs1_out),
    .arg2(cmpmux_out),
    .br_en(br_en)
);

// MARK: - Memory components

mux2 marmux
(
    .sel(marmux_sel),
    .a(pc_out),
    .b(alu_out),
    .f(marmux_out)
);

register mar
(
    .clk,
    .load(load_mar),
    .in(marmux_out),
    .out(mar_out)
);

register mdr
(
    .clk,
    .load(load_mdr),
    .in(mem_rdata),
    .out(mdrreg_out)
);

register mem_reg
(
    .clk,
    .load(load_data_out),
    .in(rs2_out),
    .out(mem_wdata)
);

endmodule : old_cpu_datapath
