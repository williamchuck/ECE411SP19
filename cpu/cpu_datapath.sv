import rv32i_types::*;

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
    output logic [31:0] dmem_wdata
);

/// MARK: - Components in IF stage

logic load_pc, pcmux_sel, cmpmux_out, br_en, br_en_MEM, br_en_WB;
logic [31:0] pc_out, pc_out_MEM, pcmux_out, pc_out_ID, pc_out_EX, alu_out, alu_out_WB, alu_out_MEM;
logic [31:0] dmem_rdata_WB;
rv32i_control_word ctw, ctw_EX, ctw_MEM, ctw_WB;

assign imem_address = pc_out;
assign load_pc = 1'b1;
pc_register PC
(
    .*,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

assign pcmux_out = pcmux_sel ? alu_out : pc_out + 32'd4;

/// MARK: - Components in ID stage

logic load_regfile, dmem_address_sel;
logic [1:0] alumux1_sel;
logic [2:0] alumux2_sel;
logic [4:0] rs1, rs2, rd, ir_rs1, ir_rs2, ir_rd;
logic [4:0] rd_EX, rd_MEM, rd_WB;
rv32i_word ir_out, ir_out_EX, ir_out_MEM, ir_out_WB
rv32i_word rs1_out, rs2_out, reg_back, alumux1_out, alumux2_out;
rv32i_word rs1_out_EX, rs2_out_EX, rs2_out_MEM;
rv32i_opcode opcode;

assign ir_rs1 = ir_out[19:15];
assign ir_rs2 = ir_out[24:20];
assign ir_rd = ir_out[11:7];
assign load_regfile = ctw_WB.load_regfile;

regfile regfile
(
    .clk,
    .load(load_regfile),
    .in(reg_back),
    .rs1,
    .rs2,
    .rd,
    .rs1_out,
    .rs2_out
);

logic stall;

// TODO: These two modules don't exist yet.
logic [2:0] funct3;
logic [6:0] funct7;
assign funct3 = ir_out[14:12];
assign funct7 = ir_out[31:25];
assign opcode = rv32i_opcode'(ir_out[6:0]);

control_rom control ( .* );
hdu hdu
(
    .dmem_read_EX(ctw_EX.dmem_read),
    .rs1,
    .rs2,
    .rd_EX(rd_EX),
    .stall
);

fwu fwu
(
    .load_regfile_MEM(ctw_MEM.load_regfile),
    .load_regfile_WB(ctw_WB.load_regfile),
    .rs1,
    .rs2,
    .rd_MEM,
    .rd_WB,
    .ctw_alumux1_sel(ctw_EX.alumux1_sel),
    .ctw_alumux2_sel(ctw_EX.alumux2_sel),
    .alumux1_sel,
    .alumux2_sel
);

/// MARK: - Components in EX stage

// Note that alumux1_sel and alumux2_sel are computed by FWU.
assign pcmux_sel = ctw_EX.pcmux_sel[1] ? br_en : ctw_EX.pcmux_sel[0];

always_comb begin
    case(alumux1_sel)
        2'd0: alumux1_out = rs1_out_EX;
        2'd1: alumux1_out = pc_out_EX;
        2'd2: alumux1_out = alu_out_MEM;
        2'd3: alumux1_out = reg_back;
        default: alumux1_out = 32'dX;
    endcase
end

rv32i_word i_imm, s_imm, b_imm, u_imm, j_imm;
assign i_imm = {{21{ir_out_EX[31]}}, ir_out_EX[30:20]};
assign s_imm = {{21{ir_out_EX[31]}}, ir_out_EX[30:25], ir_out_EX[11:7]};
assign b_imm = {{20{ir_out_EX[31]}}, ir_out_EX[7], ir_out_EX[30:25], ir_out_EX[11:8], 1'b0};
assign u_imm = {ir_out_EX[31:12], 12'h000};
assign j_imm = {{12{ir_out_EX[31]}}, ir_out_EX[19:12], ir_out_EX[20], ir_out_EX[30:21], 1'b0};

always_comb begin
    case(alumux2_sel)
        3'd0: alumux2_out = i_imm;
        3'd1: alumux2_out = u_imm;
        3'd2: alumux2_out = b_imm;
        3'd3: alumux2_out = s_imm;
        3'd4: alumux2_out = j_imm;
        3'd5: alumux2_out = rs2_out_EX;
        3'd6: alumux2_out = alu_out_MEM;
        3'd7: alumux2_out = reg_back;
        default: alumux2_out = 32'dX;
    endcase
end

alu alu
(
    .aluop(ctw_EX.aluop),
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out)
);

mux2 cmpmux
(
    .sel(ctw_EX.cmpmux_sel),
    .a(rs2_out_EX),
    .b(i_imm),
    .f(cmpmux_out)
);

compare cmp
(
    .cmpop(ctw_EX.cmpop),
    .arg1(rs1_out_EX),
    .arg2(cmpmux_out),
    .br_en
);

/// MARK: - Components in MEM stage

assign rd_MEM = ir_out_MEM[11:7];
assign dmem_address_sel = ctw_MEM.dmem_address_sel;
assign dmem_read = ctw_MEM.dmem_read;
assign dmem_write = ctw_MEM.dmem_write;
assign dmem_address = dmem_address_sel ? alu_out_MEM : pc_out_MEM;
assign dmem_wdata = rs2_out_MEM;
always_comb begin : dmem_byte_enable_logic
    case(store_funct3_t'(funct3))
        sb: begin
            case(dmem_address[1:0])
                2'b00: dmem_byte_enable = 4'h1;
                2'b01: dmem_byte_enable = 4'h2;
                2'b10: dmem_byte_enable = 4'h4;
                2'b11: dmem_byte_enable = 4'h8;
                default: ;
            endcase
        end
        sh: begin
            case(dmem_address[1:0])
                2'b00: dmem_byte_enable = 4'h3;
                2'b10: dmem_byte_enable = 4'hc;
                default: dmem_byte_enable = 4'h0;
            endcase
        end
        default: dmem_byte_enable = 4'h0;
    endcase
end

/// MARK: - Components in WB stage

assign rd_WB = ir_out_WB[11:7];

always_comb begin
    case(ctw_WB.wbmux_sel)
        3'd0: reg_back = alu_out_WB;
        3'd1: reg_back = {31'b0, br_en_WB};
        3'd2: reg_back = u_imm;
        3'd3: reg_back = dmem_rdata_WB;
        3'd4: reg_back = pc_out + 4;
        default: reg_back = 32'bX;
    endcase
end

/// MARK: - IF/ID pipeline register

logic no_mem;
assign no_mem = imem_resp & (dmem_resp | (~dmem_write & ~dmem_read));

register ir
(
    .clk,
    .load(no_mem & ~stall),
    .in(imem_rdata),
    .out(ir_out)
);

register IF_ID_pc
(
    .*,
    .load(no_mem & ~stall),
    .in(pc_out),
    .out(pc_out_ID)
);

/// MARK: - ID/EX pipeline register

register ID_EX_ir
(
    .clk,
    .load(no_mem),
    .in(ir_out),
    .out(ir_out_EX)
);

register ID_EX_ctw
(
    .*,
    .load(no_mem),
    .in(ctw),
    .out(ctw_EX)
);

register ID_EX_pc
(
    .*,
    .load(no_mem),
    .in(pc_out_ID),
    .out(pc_out_EX)
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
    .clk,
    .load(no_mem),
    .in(ctw_EX),
    .out(ctw_MEM)
);

register EX_MEM_rs2_out
(
    .clk,
    .load(no_mem),
    .in(rs2_out_EX),
    .out(rs2_out_MEM)
);

register EX_MEM_alu_out
(
    .clk,
    .load(no_mem),
    .in(alu_out),
    .out(alu_out_MEM)
);

register EX_MEM_pc
(
    .clk,
    .load(no_mem),
    .in(pc_out_EX),
    .out(pc_out_MEM)
);

register EX_MEM_ir
(
    .clk,
    .load(no_mem),
    .in(ir_out_EX),
    .out(ir_out_MEM)
);

register #(1) EX_MEM_br_en
(
    .clk,
    .load(no_mem),
    .in(br_en),
    .out(br_en_MEM)
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

register MEM_WB_ir
(
    .clk,
    .load(no_mem),
    .in(ir_out_MEM),
    .out(ir_out_WB)
);

register #(1) MEM_WB_br_en
(
    .clk,
    .load(no_mem),
    .in(br_en_MEM),
    .out(br_en_WB)
);

endmodule