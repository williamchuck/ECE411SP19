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

logic load_pc, pcmux_sel, cmpmux_out, br_en;
logic [2:0] alumux2_sel;
logic [31:0] pc, pc_out_plus4, pcmux_out, pc_ID, pc_EX, pc_back, alumux2_out, alu_out, alu_out_WB, alu_out_MEM;
logic [31:0] rs2_out_MEM, rs1_out_EX, rs2_out_EX, dmem_rdata_WB, ir_out, ir_out_EX;
rv32i_control_word ctw, ctw_EX, ctw_MEM, ctw_WB;
assign pc_out_plus4 = pc + 32'h00000004;
assign imem_address = pc;
pc_register PC
(
    .*,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc)
);

assign pcmux_out = pcmux_sel ? pc_back : pc_out_plus4;

/// MARK: - Components in ID stage

logic load_regfile, alumux1_sel, alumux1_out;
logic [4:0] rs1, rs2, rd;
rv32i_word rs1_out, rs2_out, reg_back;
rv32i_opcode opcode;

assign rs1 = ir_out[19:15];
assign rs2 = ir_out[24:20];
assign rd = ir_out[11:7];

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

logic no_hazard;

// TODO: These two modules don't exist yet.
logic [2:0] funct3;
logic [6:0] funct7;
assign funct3 = ir_out[14:12];
assign funct7 = ir_out[31:25];
assign opcode = rv32i_opcode'(ir_out[6:0]);

control_rom control ( .* );
hdu hdu ( .* );

/// MARK: - Components in EX stage

// Note that alumux1_sel and alumux2_sel are computed by FWU.

assign alumux1_out = alumux1_sel ? pc_EX : rs1_out_EX;

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
        default: alumux2_out = 32'd0;
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

assign reg_back = ctw_WB ? dmem_rdata_WB : alu_out_WB;

/// MARK: - IF/ID pipeline register

logic no_mem;
assign no_mem = imem_resp & (dmem_resp | (~dmem_write & ~dmem_read));

register ir
(
    .clk,
    .load(no_mem & no_hazard),
    .in(imem_rdata),
    .out(ir_out)
);

register IF_ID_pc
(
    .*,
    .load(no_mem & no_hazard),
    .in(pc),
    .out(pc_ID)
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
    .in(pc_ID),
    .out(pc_EX)
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