import rv32i_types::*;

module cpu_datapath (
    input clk,

    /// I-Mem interface
    input logic imem_resp,
    input logic [31:0] imem_rdata,
    output logic imem_read,
    output logic imem_write,
    output logic [31:0] imem_address,
    output logic [3:0] imem_byte_enable,
    output logic [31:0] imem_wdata,

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

logic fresh, imem_read_prev, imem_resp_prev;

initial begin
    imem_read_prev = 1'b0;
    imem_resp_prev = 1'b0;
end

always_ff @( posedge clk ) begin
    imem_read_prev <= imem_read;
    imem_resp_prev <= imem_resp;
end

assign imem_write = 1'b0;
assign imem_byte_enable = 4'hf;
assign imem_wdata = 32'h00000000;
assign imem_read = fresh | (imem_read_prev & ~imem_resp_prev);

logic [31:0] dmem_wdata_unshifted;

logic stall, no_mem;
logic pcmux_sel, br_en, br_en_MEM, br_en_WB;
logic [31:0] pc_out, pc_out_MEM, pcmux_out, pc_out_ID, pc_out_EX, pc_out_WB;
logic [31:0] cmpmux_out, alu_out, alu_out_WB, alu_out_MEM;
logic [31:0] dmem_rdata_WB;
rv32i_control_word ctw, ctwmux_out, ctw_EX, ctw_MEM, ctw_WB;

assign imem_address = pc_out;
pc_register PC
(
    .clk,
    .load(no_mem & ~stall),
    .in(pcmux_out),
    .out(pc_out),
    .fresh(fresh)
);

assign pcmux_out = pcmux_sel ? alu_out : pc_out + 32'd4;

/// MARK: - Components in ID stage

logic load_regfile;
logic rs1_out_sel, rs2_out_sel;
logic [1:0] rs1_out_EX_sel, rs2_out_EX_sel;
logic [4:0] rs1, rs2, rd, ir_rs1, ir_rs2, ir_rd;
logic [4:0] rs1_EX, rs2_EX;
logic [4:0] rd_EX, rd_MEM, rd_WB;
rv32i_word ir_out, ir_out_EX, ir_out_MEM, ir_out_WB;
rv32i_word rs1_out, rs2_out, regfile_in_WB, regfile_in_MEM, alumux1_out, alumux2_out;
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
    .in(regfile_in_WB),
    .rs1,
    .rs2,
    .rd(rd_WB),
    .rs1_out,
    .rs2_out
);

logic [2:0] funct3;
logic [6:0] funct7;
assign funct3 = ir_out[14:12];
assign funct7 = ir_out[31:25];
assign opcode = rv32i_opcode'(ir_out[6:0]);

logic [31:0] selected_rs1_out, selected_rs2_out;
assign selected_rs1_out = rs1_out_sel ? regfile_in_WB : rs1_out;
assign selected_rs2_out = rs2_out_sel ? regfile_in_WB : rs2_out;

control_rom control (
    .opcode,
    .funct3,
    .funct7,
    .ir_rs1,
    .ir_rs2,
    .ir_rd,
    .ctw,
    .rs1,
    .rs2,
    .rd
);

hdu hdu
(
    .dmem_read_EX(ctw_EX.dmem_read),
    .rs1,
    .rs2,
    .rd_EX,
    .stall
);

fwu fwu
(
    .load_regfile_MEM(ctw_MEM.load_regfile),
    .load_regfile_WB(ctw_WB.load_regfile),
    .rs1,
    .rs2,
    .rs1_EX(rs1_EX),
    .rs2_EX(rs2_EX),
    .rd_MEM,
    .rd_WB,
    .rs1_out_sel,
    .rs2_out_sel,
    .rs1_out_EX_sel,
    .rs2_out_EX_sel
);

assign ctwmux_out = stall ? 32'h00000000 : ctw;

/// MARK: - Components in EX stage

assign rs1_EX = ir_out_EX[19:15];
assign rs2_EX = ir_out_EX[24:20];
assign rd_EX = ir_out_EX[11:7];

// Note that alumux1_sel and alumux2_sel are computed by FWU.
assign pcmux_sel = ctw_EX.pcmux_sel[1] ? br_en : ctw_EX.pcmux_sel[0];

rv32i_word selected_rs1_EX_out, selected_rs2_EX_out;

always_comb begin : rs1_2_sel
    selected_rs1_EX_out = 32'd0;
    case(rs1_out_EX_sel)
        2'd0: selected_rs1_EX_out = rs1_out_EX;
        2'd1: selected_rs1_EX_out = regfile_in_MEM;
        2'd2: selected_rs1_EX_out = regfile_in_WB;
        default:;
    endcase
    selected_rs2_EX_out = 32'd0;
    case(rs2_out_EX_sel)
        2'd0: selected_rs2_EX_out = rs2_out_EX;
        2'd1: selected_rs2_EX_out = regfile_in_MEM;
        2'd2: selected_rs2_EX_out = regfile_in_WB;
        default:;
    endcase
end

rv32i_word i_imm, s_imm, b_imm, u_imm, j_imm;
assign i_imm = {{21{ir_out_EX[31]}}, ir_out_EX[30:20]};
assign s_imm = {{21{ir_out_EX[31]}}, ir_out_EX[30:25], ir_out_EX[11:7]};
assign b_imm = {{20{ir_out_EX[31]}}, ir_out_EX[7], ir_out_EX[30:25], ir_out_EX[11:8], 1'b0};
assign u_imm = {ir_out_EX[31:12], 12'h000};
assign j_imm = {{12{ir_out_EX[31]}}, ir_out_EX[19:12], ir_out_EX[20], ir_out_EX[30:21], 1'b0};

always_comb begin : alumux1_2_selection
    case(ctw_EX.alumux1_sel)
        1'd0: alumux1_out = selected_rs1_EX_out;
        1'd1: alumux1_out = pc_out_EX;
        default: alumux1_out = 32'dX;
    endcase

    case(ctw_EX.alumux2_sel)
        3'd0: alumux2_out = i_imm;
        3'd1: alumux2_out = u_imm;
        3'd2: alumux2_out = b_imm;
        3'd3: alumux2_out = s_imm;
        3'd4: alumux2_out = j_imm;
        3'd5: alumux2_out = selected_rs2_EX_out;
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

assign cmpmux_out = ctw_EX.cmpmux_sel ? i_imm : selected_rs2_EX_out;

compare cmp
(
    .cmpop(ctw_EX.cmpop),
    .arg1(selected_rs1_EX_out),
    .arg2(cmpmux_out),
    .br_en
);

/// MARK: - Components in MEM stage
logic [31:0] dmem_address_untruncated;
assign rd_MEM = ir_out_MEM[11:7];
assign dmem_read = ctw_MEM.dmem_read;
assign dmem_write = ctw_MEM.dmem_write;
assign dmem_address_untruncated = alu_out_MEM;
assign dmem_address = {alu_out_MEM[31:2], 2'b00};
assign dmem_wdata_unshifted = rs2_out_MEM;
always_comb begin
    case(store_funct3_t'(ctw_MEM.funct3))
        sb: begin
            case(dmem_address_untruncated[1:0])
                2'b00: begin
                    dmem_byte_enable = 4'h1;
                    dmem_wdata = {24'd0, dmem_wdata_unshifted[7:0]};
                end

                2'b01: begin
                    dmem_byte_enable = 4'h2;
                    dmem_wdata = {16'd0, dmem_wdata_unshifted[7:0],  8'd0};
                end
                2'b10: begin
                    dmem_byte_enable = 4'h4;
                    dmem_wdata = {8'd0, dmem_wdata_unshifted[7:0],  16'd0};
                end
                2'b11: begin
                    dmem_byte_enable = 4'h8;
                    dmem_wdata = {dmem_wdata_unshifted[7:0], 24'd0};
                end
                default: begin 
                    dmem_byte_enable = 4'h0;
                    dmem_wdata = 32'd0;
                end
            endcase
        end
        sh: begin
            case(dmem_address_untruncated[1:0])
                2'b00: begin
                    dmem_byte_enable = 4'h3;
                    dmem_wdata = {16'd0, dmem_wdata_unshifted[15:0]};
                end
                2'b10: begin
                    dmem_byte_enable = 4'hc;
                    dmem_wdata = {dmem_wdata_unshifted[15:0], 16'd0};
                end
                default: begin 
                    dmem_byte_enable = 4'h0;
                    dmem_wdata = 32'd0;
                end
            endcase
        end
        default: begin
            dmem_byte_enable = 4'h0;
            dmem_wdata = 32'd0;
        end
    endcase
end

rv32i_word dmem_rdata_shifted;
always_comb begin
    dmem_rdata_shifted = dmem_rdata;
    case(load_funct3_t'(ctw_MEM.funct3))
        lb: begin
            case(dmem_address_untruncated[1:0])
                2'b00: dmem_rdata_shifted = {{24{dmem_rdata[7]}}, dmem_rdata[7:0]};
                2'b01: dmem_rdata_shifted = {{24{dmem_rdata[15]}}, dmem_rdata[15:8]};
                2'b10: dmem_rdata_shifted = {{24{dmem_rdata[23]}}, dmem_rdata[23:16]};
                2'b11: dmem_rdata_shifted = {{24{dmem_rdata[31]}}, dmem_rdata[31:24]};
                default: ;
            endcase
        end

        lh: begin
            case(dmem_address_untruncated[1:0])
                2'b00: dmem_rdata_shifted = {{16{dmem_rdata[15]}}, dmem_rdata[15:0]};
                2'b10: dmem_rdata_shifted = {{16{dmem_rdata[31]}}, dmem_rdata[31:16]};
                default: ;
            endcase
        end

        lw: ;

        lbu: begin
            case(dmem_address_untruncated[1:0])
                2'b00: dmem_rdata_shifted = {24'd0, dmem_rdata[7:0]};
                2'b01: dmem_rdata_shifted = {24'd0, dmem_rdata[15:8]};
                2'b10: dmem_rdata_shifted = {24'd0, dmem_rdata[23:16]};
                2'b11: dmem_rdata_shifted = {24'd0, dmem_rdata[31:24]};
                default: ;
            endcase
        end

        lhu: begin
            case(dmem_address_untruncated[1:0])
                2'b00: dmem_rdata_shifted = {16'd0, dmem_rdata[15:0]};
                2'b10: dmem_rdata_shifted = {16'd0, dmem_rdata[31:16]};
                default: ;
            endcase
        end
        default: ;
    endcase
end

always_comb begin
    case(ctw_MEM.wbmux_sel)
        3'd0: regfile_in_MEM = alu_out_MEM;
        3'd1: regfile_in_MEM = {31'b0, br_en_MEM};
        3'd2: regfile_in_MEM = u_imm;
        3'd3: regfile_in_MEM = dmem_rdata_shifted;
        3'd4: regfile_in_MEM = pc_out_MEM + 4;
        default: regfile_in_MEM = 32'bX;
    endcase
end

/// MARK: - Components in WB stage

assign rd_WB = ir_out_WB[11:7];

always_comb begin
    case(ctw_WB.wbmux_sel)
        3'd0: regfile_in_WB = alu_out_WB;
        3'd1: regfile_in_WB = {31'b0, br_en_WB};
        3'd2: regfile_in_WB = u_imm;
        3'd3: regfile_in_WB = dmem_rdata_WB;
        3'd4: regfile_in_WB = pc_out_WB + 4;
        default: regfile_in_WB = 32'bX;
    endcase
end

/// MARK: - IF/ID pipeline register

assign no_mem = (imem_resp | ~imem_read) & (dmem_resp | (~dmem_write & ~dmem_read));

register ir
(
    .clk,
    .load(no_mem & ~stall),
    .in(imem_rdata),
    .out(ir_out)
);

// assign ir_out = imem_rdata;

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

register #($bits(rv32i_control_word)) ID_EX_ctw
(
    .*,
    .load(no_mem),
    .in(ctwmux_out),
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
    .in(selected_rs1_out),
    .out(rs1_out_EX)
);

register ID_EX_rs2_out
(
    .*,
    .load(no_mem),
    .in(selected_rs2_out),
    .out(rs2_out_EX)
);

/// MARK: - EX/MEM pipeline register

register #($bits(rv32i_control_word)) EX_MEM_ctw
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
    .in(selected_rs2_EX_out),
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

register #($bits(rv32i_control_word)) MEM_WB_ctw
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
    .in(dmem_rdata_shifted),
    .out(dmem_rdata_WB)
);

// assign dmem_rdata_WB = dmem_rdata_shifted;

register MEM_WB_pc
(
    .clk,
    .load(no_mem),
    .in(pc_out_MEM),
    .out(pc_out_WB)
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