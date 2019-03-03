module cpu_datapath (
    input clk,

    /// I-Mem interface
    input logic imem_resp,
    input logic [31:0] imem_rdata,
    output logic [31:0] imem_address,

    // D_Mem interface
    input logic dmem_resp,
    input logic [31:0] dmem_rdata,
    output logic dmem_read,
    output logic dmem_write,
    output logic [31:0] dmem_address,
    output logic [3:0] dmem_byte_enable,
    output logic [31:0] dmem_wdata,
);

/// MARK: - Components in IF stage

logic [31:0] pc, pc_out_plus4, pcmux_out, pc_back;
assign pc_out_plus4 = pc + 32'h00000004;
assign imem_address = pc;
pc_register PC
(
    .*,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc)
);
mux2 pcmux
(
    .sel(pcmux_sel),
    .a(pc_out_plus4),
    .b(pc_back),
    .f(pcmux_out)
);

/// MARK: - Components in ID stage

logic [4:0] rs1, rs2, rd;
rv32i_word rs1_out, rs2_out, reg_back;
rv32i_opcode opcode;

regfile regfile
(
    .*,
    .load(load_regfile),
    .in(reg_back)
);

// TODO: These two modules don't exist yet.
control_rom rom( .* );
hdu hdu ( .* );

/// MARK: - Components in EX stage

// Note that alumux1_sel and alumux2_sel are computed by FWU.
mux2 alumux1
(
    .sel(alumux1_sel),
    .a(rs1_out_EX),
    .b(ctw.pc),
    .f(alumux1_out)
);

mux8 alumux2
(
    .sel(alumux2_sel),
    .a0(ctw_EX.i_imm),
    .a1(ctw_EX.u_imm),
    .a2(ctw_EX.b_imm),
    .a3(ctw_EX.s_imm),
    .a4(ctw_EX.j_imm),
    .a5(rs2_out_EX),
    .a6(32'h00000000),
    .a7(32'h00000000),
    .f(alumux2_out)
);

alu alu
(
    .*,
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out)
);

mux2 cmpmux
(
    .sel(ctw_EX.cmpmux_sel),
    .a(rs2_out_EX),
    .b(ctw_EX.i_imm),
    .f(cmpmux_out)
);

cmp cmp
(
    .*,
    .a(rs1_out_EX),
    .b(cmpmux_out),
    .f(br_en)
);

// TODO: This module doesn't exist yet.
fwu fwu ( .* );

/// MARK: - Components in MEM stage

assign dmem_read = ctw_MEM.dmem_read;
assign dmem_write = ctw_MEM.dmem_write;
assign dmem_address = alu_out_MEM;
assign dmem_wdata = rs2_out_MEM;
always_comb begin : dmem_byte_enable_logic
    case(store_funct3_t'(funct3))
        sb: begin
            case(lsb)
                2'b00: mem_byte_enable = 4'h1;
                2'b01: mem_byte_enable = 4'h2;
                2'b10: mem_byte_enable = 4'h4;
                2'b11: mem_byte_enable = 4'h8;
                default: ;
            endcase
        end
        sh: begin
            case(lsb)
                2'b00: mem_byte_enable = 4'h3;
                2'b10: mem_byte_enable = 4'hc;
                default: mem_byte_enable = 4'h0;
            endcase
        end
        default: mem_byte_enable = 4'h0;
    endcase
end

/// MARK: - Components in WB stage

mux2 wbmux
(
    .sel(ctw_WB.wbmux_sel),
    .a(alu_out_WB),
    .b(dmem_rdata_WB),
    .f(reg_back)
);

/// MARK: - IF/ID pipeline register

ir ir
(
    .*,
    .load(no_mem & no_hazard),
    .in(imem_rdata)
);

register IF_ID_pc
(
    .*,
    .load(no_mem & no_hazard),
    .in(pc),
    .out(pc_ID)
);

/// MARK: - ID/EX pipeline register

register ID_EX_ctw
(
    .*,
    .load(no_mem),
    .in(ctw),
    .out(ctw_EX)
);

register ID_EX_rs1_out
(
    .*,
    .load(no_mem),
    .in(rs1_out),
    .out(rs1_out_EX)
);

register ID_EX_rs2_out
(
    .*,
    .load(no_mem),
    .in(rs2_out),
    .out(rs2_out_EX)
);

/// MARK: - EX/MEM pipeline register

register EX_MEM_ctw
(
    .*,
    .load(no_mem),
    .in(ctw_EX),
    .out(ctw_MEM)
);

register EX_MEM_rs2_out
(
    .*,
    .load(no_mem),
    .in(rs2_out_EX),
    .out(rs2_out_MEM)
);

register EX_MEM_alu_out
(
    .*,
    .load(no_mem),
    .in(alu_out),
    .out(alu_out_MEM)
);

/// MARK: - MEM/WB pipeline register

register MEM_WB_ctw
(
    .*,
    .load(no_mem),
    .in(ctw_MEM),
    .out(ctw_WB)
);

register MEM_WB_alu_out
(
    .*,
    .load(no_mem),
    .in(alu_out_MEM),
    .out(alu_out_WB)
);

register MEM_WB_dmem_rdata
(
    .*,
    .load(no_mem),
    .in(dmem_rdata),
    .out(dmem_rdata_WB)
);

endmodule