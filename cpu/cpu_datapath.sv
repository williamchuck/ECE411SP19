import rv32i_types::*;

module cpu_datapath (
    input clk,

    /// I-Mem interface
    input logic imem_resp,
    input logic imem_ready,
    input logic [31:0] imem_rdata,
    output logic imem_read,
    output logic imem_write,
    output logic [31:0] imem_address,
    output logic [3:0] imem_byte_enable,
    output logic [31:0] imem_wdata,
    output logic imem_stall,

    // D_Mem interface
    input logic dmem_resp,
    input logic dmem_ready,
    input logic [31:0] dmem_rdata,
    output logic dmem_read,
    output logic dmem_write,
    output logic [31:0] dmem_address,
    output logic [3:0] dmem_byte_enable,
    output logic [31:0] dmem_wdata,
    output logic dmem_stall
);

logic [31:0] pc_out, pc_out_MEM, pcmux_out, pc_out_ID, pc_out_EX, pc_out_WB;

logic load_regfile;
logic rs1_out_sel, rs2_out_sel;
logic [1:0] rs1_out_EX_sel, rs2_out_EX_sel;
// logic [4:0] rs1, rs2, rd;
// logic [4:0] rs1_EX, rs2_EX;
// logic [4:0] rd_EX, rd_MEM, rd_WB;
rv32i_word ir_out, ir_out_EX, ir_out_MEM, ir_out_WB;
rv32i_word rs1_out, rs2_out, regfile_in_WB, regfile_in_MEM, alumux1_out, alumux2_out;
rv32i_word rs1_out_EX, rs2_out_EX, rs2_out_MEM;

/// MARK: - Components in IF stage


assign imem_write = 1'b0;
assign imem_byte_enable = 4'hf;
assign imem_wdata = 32'h00000000;
assign imem_read = 1'b1;//imem_permit;

logic [31:0] dmem_wdata_unshifted;
logic data_hazard_stall;
logic pcmux_sel, br_en, br_en_MEM, br_en_WB;
logic [31:0] cmpmux_out, alu_out, alu_out_WB, alu_out_MEM;
logic [31:0] dmem_rdata_WB;
rv32i_control_word ctw, ctwmux_out, ctw_EX, ctw_MEM, ctw_WB;

assign imem_address = pc_out;
pc_register PC
(
    .clk,
    .load(~data_hazard_stall && dmem_resp && imem_resp),
    .in(pcmux_out),
    .out(pc_out)
);

assign pcmux_out = pcmux_sel ? alu_out : pc_out + 32'd4;

/// MARK: - Components in ID stage


logic force_nop;

assign ir_out = force_nop ? 32'h00000013 : imem_rdata;

// assign load_regfile = ctw_WB.load_regfile && dmem_ready && ctw_WB.opcode == op_load);

always_comb begin
    if(ctw_WB.opcode == op_load) begin
        load_regfile = dmem_ready;
    end else begin
        load_regfile = ctw_WB.load_regfile;
    end
end

regfile regfile
(
    .clk,
    .load(load_regfile),
    .in(regfile_in_WB),
    .rs1(ctw.rs1),
    .rs2(ctw.rs2),
    .rd(ctw_WB.rd),
    .rs1_out,
    .rs2_out
);

logic [31:0] selected_rs1_out, selected_rs2_out;
assign selected_rs1_out = rs1_out_sel ? regfile_in_WB : rs1_out;
assign selected_rs2_out = rs2_out_sel ? regfile_in_WB : rs2_out;

control_rom control (
    .ir(ir_out),
    .pc(pc_out_ID),
    .ctw
    // .rs1,
    // .rs2,
    // .rd
);

hdu hdu
(
    .dmem_read_EX(ctw_EX.dmem_read),
    .rs1(ctw.rs1),
    .rs2(ctw.rs2),
    .rd_EX(ctw_EX.rd),
    .stall(data_hazard_stall)
);

fwu fwu
(
    .load_regfile_MEM(ctw_MEM.load_regfile),
    .load_regfile_WB(ctw_WB.load_regfile),
    .rs1(ctw.rs1),
    .rs2(ctw.rs2),
    .rs1_EX(ctw_EX.rs1),
    .rs2_EX(ctw_EX.rs2),
    .rd_MEM(ctw_MEM.rd),
    .rd_WB(ctw_WB.rd),
    .rs1_out_sel,
    .rs2_out_sel,
    .rs1_out_EX_sel,
    .rs2_out_EX_sel
);

assign ctwmux_out = data_hazard_stall ? 32'h00000013 : ctw;

assign force_nop = (ctw_EX.opcode == op_br && br_en) | (ctw_MEM.opcode == op_br && br_en_MEM) | ~imem_ready;

/// MARK: - Components in EX stage

// assign rs1_EX = ir_out_EX[19:15];
// assign rs2_EX = ir_out_EX[24:20];
// assign rd_EX = ir_out_EX[11:7];

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
        rs1_EX_sel: alumux1_out = selected_rs1_EX_out;
        pc_out_sel: alumux1_out = ctw_EX.pc;
        default: alumux1_out = 32'dX;
    endcase

    case(ctw_EX.alumux2_sel)
        i_imm_sel: alumux2_out = i_imm;
        u_imm_sel: alumux2_out = u_imm;
        b_imm_sel: alumux2_out = b_imm;
        s_imm_sel: alumux2_out = s_imm;
        j_imm_sel: alumux2_out = j_imm;
        rs2_EX_sel: alumux2_out = selected_rs2_EX_out;
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
logic [31:0] dmem_address_untruncated, dmem_address_untruncated_WB;

// blocking_unit_abstraction_layer dmem_blocking_unit
// (
//     .clk,
//     .select(ctw_MEM.dmem_read | ctw_MEM.dmem_write),
//     .resp(dmem_resp),
//     .pc(pc_out_MEM),
//     .permit(dmem_permit),
//     .busy(dmem_busy)
// );

// rdata_buffer dmem_buffer(
//     .clk,
//     .resp(dmem_resp),
//     .busy(blocking_unit_busy),
//     .rdata(dmem_rdata),
//     .rdata_synchronized(dmem_rdata_WB)
// );

// assign rd_MEM = ir_out_MEM[11:7];
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
        sw: begin
            dmem_byte_enable = 4'hF;
            dmem_wdata = dmem_wdata_unshifted;
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
    case(load_funct3_t'(ctw_WB.funct3))
        lb: begin
            case(dmem_address_untruncated_WB[1:0])
                2'b00: dmem_rdata_shifted = {{24{dmem_rdata[7]}}, dmem_rdata[7:0]};
                2'b01: dmem_rdata_shifted = {{24{dmem_rdata[15]}}, dmem_rdata[15:8]};
                2'b10: dmem_rdata_shifted = {{24{dmem_rdata[23]}}, dmem_rdata[23:16]};
                2'b11: dmem_rdata_shifted = {{24{dmem_rdata[31]}}, dmem_rdata[31:24]};
                default: ;
            endcase
        end

        lh: begin
            case(dmem_address_untruncated_WB[1:0])
                2'b00: dmem_rdata_shifted = {{16{dmem_rdata[15]}}, dmem_rdata[15:0]};
                2'b10: dmem_rdata_shifted = {{16{dmem_rdata[31]}}, dmem_rdata[31:16]};
                default: ;
            endcase
        end

        lw: ;

        lbu: begin
            case(dmem_address_untruncated_WB[1:0])
                2'b00: dmem_rdata_shifted = {24'd0, dmem_rdata[7:0]};
                2'b01: dmem_rdata_shifted = {24'd0, dmem_rdata[15:8]};
                2'b10: dmem_rdata_shifted = {24'd0, dmem_rdata[23:16]};
                2'b11: dmem_rdata_shifted = {24'd0, dmem_rdata[31:24]};
                default: ;
            endcase
        end

        lhu: begin
            case(dmem_address_untruncated_WB[1:0])
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
        alu_out_wb_sel: regfile_in_MEM = alu_out_MEM;
        br_en_wb_sel: regfile_in_MEM = {31'b0, br_en_MEM};
        u_imm_wb_sel: regfile_in_MEM = u_imm;
        rdata_wb_sel: regfile_in_MEM = 32'd0;
        pc_inc_wb_sel: regfile_in_MEM = pc_out_MEM + 4;
        default: regfile_in_MEM = 32'bX;
    endcase
end

/// MARK: - Components in WB stage

// assign rd_WB = ir_out_WB[11:7];

always_comb begin
    case(ctw_WB.wbmux_sel)
        alu_out_wb_sel: regfile_in_WB = alu_out_WB;
        br_en_wb_sel: regfile_in_WB = {31'b0, br_en_WB};
        u_imm_wb_sel: regfile_in_WB = u_imm;
        rdata_wb_sel: regfile_in_WB = dmem_rdata_shifted;
        pc_inc_wb_sel: regfile_in_WB = pc_out_WB + 4;
        default: regfile_in_WB = 32'bX;
    endcase
end

/// MARK: - IF/ID pipeline register

register IF_ID_pc
(
    .clk,
    .load(~data_hazard_stall && dmem_resp && imem_resp),
    .in(pc_out),
    .out(pc_out_ID)
);

assign imem_stall = ~(~data_hazard_stall && dmem_resp);

/// MARK: - ID/EX pipeline register

register #(4*32+$bits(rv32i_control_word)) ID_EX_pipeline
(
    .clk,
    .load(dmem_resp),
    .in({ir_out, ctwmux_out, pc_out_ID, selected_rs1_out, selected_rs2_out}),
    .out({ir_out_EX, ctw_EX, pc_out_EX, rs1_out_EX, rs2_out_EX})
);

/// MARK: - EX/MEM pipeline register

register #($bits(rv32i_control_word)+4*32+1) EX_MEM_pipeline
(
    .clk,
    .load(dmem_resp),
    .in({ctw_EX, selected_rs2_EX_out, alu_out, pc_out_EX, ir_out_EX, br_en}),
    .out({ctw_MEM, rs2_out_MEM, alu_out_MEM, pc_out_MEM, ir_out_MEM, br_en_MEM})
);

/// MARK: - MEM/WB pipeline register

register #($bits(rv32i_control_word)+32*4+1) MEM_WB_pipeline
(
    .clk,
    .load(dmem_resp),
    .in({ctw_MEM, alu_out_MEM, dmem_address_untruncated, pc_out_MEM, ir_out_MEM, br_en_MEM}),
    .out({ctw_WB, alu_out_WB, dmem_address_untruncated_WB, pc_out_WB, ir_out_WB, br_en_WB})
);

assign dmem_stall = 1'd0;

endmodule