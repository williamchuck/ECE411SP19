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
    output logic dmem_stall,

    //shadow memory
    output logic EX_ins_valid,
    output logic [31:0] EX_ir,
    output logic [31:0] EX_pc,

    output logic [31:0] dmem_address_WB,
    output logic WB_load
);

logic [31:0] true_pc, pc_out, pcmux_out, pc_out_ID;

logic pipe1, pipe2, pipe3, pipe4;
logic load_regfile, load_regfile_WB, load_regfile_MEM;
logic rs1_out_sel, rs2_out_sel;
logic [1:0] rs1_out_EX_sel, rs2_out_EX_sel;
// rv32i_word ir_out, ir_out_EX, ir_out_MEM, ir_out_WB, ir;
rv32i_word ir;
rv32i_word rs1_out, rs2_out, regfile_in_WB, regfile_in_MEM, alumux1_out, alumux2_out;
rv32i_word rs1_out_EX, rs2_out_EX, rs2_out_MEM;

logic [31:0] buffer_branch_target, branch_target;

rv32i_control_word ctw_nil;

assign ctw_nil.is_c = 1'b0;
assign ctw_nil.opcode = op_nop;
assign ctw_nil.c_opcode = c_reserved;
assign ctw_nil.aluop = alu_add;
assign ctw_nil.muldiv = 1'b0;
assign ctw_nil.cmpop = beq;
assign ctw_nil.load_regfile = 1'b0;
assign ctw_nil.dmem_read = 1'b0;
assign ctw_nil.dmem_write = 1'b0;
assign ctw_nil.cmpmux_sel = cmpmux_rs2;
assign ctw_nil.pcmux_sel = 2'b00;
assign ctw_nil.alumux1_sel = alm1_rs1;
assign ctw_nil.wbmux_sel = wbm_alu;
assign ctw_nil.alumux2_sel = alm2_imm;
assign ctw_nil.funct3 = 3'b000;
assign ctw_nil.funct7 = 7'b0;
assign ctw_nil.pc = 32'b0;
assign ctw_nil.ir = 32'hFFFFFFFF;
assign ctw_nil.imm = 32'b0;
assign ctw_nil.rs1 = 5'b0;
assign ctw_nil.rs2 = 5'b0;
assign ctw_nil.rd = 5'b0;

/// MARK: - Components in IF stage

assign imem_write = 1'b0;
assign imem_byte_enable = 4'hf;
assign imem_wdata = 32'h00000000;
assign imem_read = 1'b1;//imem_permit;

logic [31:0] dmem_wdata_unshifted;
logic data_hazard_stall, control_hazard_stall, ir_stall;
logic pcmux_sel, pcmux_sel_IF, pcmux_sel_ID, br_en, br_en_MEM, br_en_WB;
logic [31:0] cmpmux_out, alu_out, alu_out_WB, alu_out_MEM;
logic [31:0] dmem_rdata_WB;
rv32i_control_word ctw, ctwmux_out, ctw_EX, ctw_MEM, ctw_WB;

logic control_hazard_1_bit, control_hazard_2_bit, jump, buffer_jump;
logic alu_resp, alu_ready, alu_ready_MEM, alu_ready_WB;

assign pipe1 = ~data_hazard_stall & imem_resp & ~ir_stall & alu_resp & dmem_resp;
assign pipe2 = ~data_hazard_stall & ~ir_stall & alu_resp & dmem_resp;
assign pipe3 = ~data_hazard_stall & alu_resp & dmem_resp;

assign imem_address = pc_out;
pc_register PC
(
    .clk,
    .load(pipe1),
    .in(pcmux_out),
    .out(pc_out)
);

assign pcmux_out = pcmux_sel ? branch_target : (pc_out & 32'hfffffffc) + 32'd4;
// assign branch_target = jump ? alu_out : buffer_branch_target;
assign branch_target = buffer_jump ? buffer_branch_target : alu_out;

/// MARK: - Components in ID stage

logic force_nop;
// assign ir_out = force_nop ? 32'hffffffff : ir;
assign ctwmux_out = force_nop ? ctw_nil : ctw;

logic is_load;
always_comb begin
    is_load = (~ctw_WB.is_c & (ctw_WB.opcode == op_load)) | (ctw_WB.is_c & ((ctw_WB.c_opcode == c_lw)|(ctw_WB.c_opcode == c_lwsp)));
    if (is_load) begin
        load_regfile_WB = dmem_ready;
    end else if (ctw_WB.opcode == op_reg && ctw_WB.muldiv) begin
        load_regfile_WB = alu_ready_WB;
    end else begin
        load_regfile_WB = ctw_WB.load_regfile;
    end

    if (ctw_MEM.opcode == op_reg && ctw_MEM.muldiv) begin
        load_regfile_MEM = alu_ready_MEM;
    end else begin
        load_regfile_MEM = ctw_MEM.load_regfile;
    end
end
assign load_regfile = load_regfile_WB;

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

ir_manager irm
(
    .clk,
    .j(pcmux_sel_ID),
    .ready(imem_ready),
    .hazard(data_hazard_stall | ~dmem_resp),
    .control_hazard_stall,
    .pc(pc_out_ID),
    .true_pc,
    .imem_rdata,
    .ir,
    .ir_stall
);

control_rom control (
    .ir,
    .pc(true_pc),
    .ctw
);

hdu hdu
(
    .dmem_read_EX(ctw_EX.dmem_read),
    .dmem_read_MEM(ctw_MEM.dmem_read),
    .rs1(ctw.rs1),
    .rs2(ctw.rs2),
    .rd_EX(ctw_EX.rd),
    .rd_MEM(ctw_MEM.rd),
    .stall(data_hazard_stall)
);

fwu fwu
(
    .load_regfile_MEM(load_regfile_MEM),
    .load_regfile_WB(load_regfile_WB),
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

register #(1) control_hazard_1
(
    .clk,
    .load(ctw_EX.opcode != op_nop | pipe1),
    .in(~pipe1 & pcmux_sel),
    .out(control_hazard_1_bit)
);

register #(1) control_hazard_2
(
    .clk,
    .load(pipe1),
    .in((pipe1 & pcmux_sel) | control_hazard_1_bit),
    .out(control_hazard_2_bit)
);

register branch_target_buffer
(
    .clk,
    .load(ctw_EX.opcode != op_nop | pipe1),
    .in(branch_target),
    .out(buffer_branch_target)
);

register #(1) jump_buffer
(
    .clk,
    .load(ctw_EX.opcode != op_nop | pipe1),
    .in(jump),
    .out(buffer_jump)
);

assign control_hazard_stall = jump | control_hazard_1_bit | control_hazard_2_bit;
// assign buffer_jump = control_hazard_1_bit | control_hazard_2_bit;
assign force_nop = (data_hazard_stall | control_hazard_stall | ~imem_ready);

/// MARK: - Components in EX stage

assign jump = ctw_EX.pcmux_sel[1] ? br_en : ctw_EX.pcmux_sel[0];
assign pcmux_sel = jump | control_hazard_1_bit;

rv32i_word selected_rs1_EX_out, selected_rs2_EX_out;

logic alu_resp_;
register #(1) alu_resp_reg
(
    .clk,
    .load(1'b1),
    .in(alu_resp),
    .out(alu_resp_)
);

always_comb begin : rs1_2_sel
    selected_rs1_EX_out = rs1_out_EX;
    case(rs1_out_EX_sel)
        2'd0: selected_rs1_EX_out = rs1_out_EX;
        2'd1: selected_rs1_EX_out = regfile_in_MEM;
        2'd2: selected_rs1_EX_out = regfile_in_WB;
        default:;
    endcase

    selected_rs2_EX_out = rs2_out_EX;
    case(rs2_out_EX_sel)
        2'd0: selected_rs2_EX_out = rs2_out_EX;
        2'd1: selected_rs2_EX_out = regfile_in_MEM;
        2'd2: selected_rs2_EX_out = regfile_in_WB;
        default:;
    endcase
end

always_comb begin : alumux1_2_selection
    case(ctw_EX.alumux1_sel)
        alm1_rs1: alumux1_out = selected_rs1_EX_out;
        alm1_pc: alumux1_out = ctw_EX.pc;
        default: alumux1_out = 32'dX;
    endcase

    case(ctw_EX.alumux2_sel)
        alm2_imm: alumux2_out = ctw_EX.imm;
        alm2_rs2: alumux2_out = selected_rs2_EX_out;
        alm2_zero: alumux2_out = 32'd0;
        default: alumux2_out = 32'dX;
    endcase
end

alu alu
(
    .clk,
    .aluop(ctw_EX.aluop),
    .muldiv(ctw_EX.muldiv),
    .alu_stall(~dmem_resp),
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out),
    .resp(alu_resp),
    .ready(alu_ready)
);

always_comb begin
    case(ctw_EX.cmpmux_sel)
        cmpmux_imm: cmpmux_out = ctw_EX.imm;
        cmpmux_rs2: cmpmux_out = selected_rs2_EX_out;
        cmpmux_zero: cmpmux_out = 32'd0;
        default: cmpmux_out = 32'dX;
    endcase
end

compare cmp
(
    .cmpop(ctw_EX.cmpop),
    .arg1(selected_rs1_EX_out),
    .arg2(cmpmux_out),
    .br_en
);

assign EX_ins_valid = ctw_EX.opcode != op_nop && ctw_EX.opcode != 0;
assign EX_ir = ctw_EX.ir;
assign EX_pc = ctw_EX.pc;

/// MARK: - Components in MEM stage
logic [31:0] dmem_address_untruncated, dmem_address_untruncated_WB;

assign dmem_read = ctw_MEM.dmem_read & alu_ready_MEM;
assign dmem_write = ctw_MEM.dmem_write & alu_ready_MEM;
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
            dmem_byte_enable = 4'hf;
            dmem_wdata = dmem_wdata_unshifted;
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
        wbm_alu: regfile_in_MEM = alu_out_MEM;
        wbm_br: regfile_in_MEM = {31'b0, br_en_MEM};
        wbm_imm: regfile_in_MEM = ctw_MEM.imm;
        wbm_rdata: regfile_in_MEM = 32'd0;
        wbm_pc4: regfile_in_MEM = ctw_MEM.pc + 4;
        wbm_pc2: regfile_in_MEM = ctw_MEM.pc + 2;
        default: regfile_in_MEM = 32'bX;
    endcase
end

/// MARK: - Components in WB stage

assign WB_load = ctw_WB.opcode == op_load;

always_comb begin
    case(ctw_WB.wbmux_sel)
        wbm_alu: regfile_in_WB = alu_out_WB;
        wbm_br: regfile_in_WB = {31'b0, br_en_WB};
        wbm_imm: regfile_in_WB = ctw_WB.imm;
        wbm_rdata: regfile_in_WB = dmem_rdata_shifted;
        wbm_pc4: regfile_in_WB = ctw_WB.pc + 4;
        wbm_pc2: regfile_in_WB = ctw_WB.pc + 2;
        default: regfile_in_WB = 32'bX;
    endcase
end

/// MARK: - PC/IF pipeline register
register #(1) PC_IF_pcmux_sel
(
    .clk,
    .load(pipe1),
    .in(pcmux_sel),
    .out(pcmux_sel_IF)
);

/// MARK: - IF/ID pipeline register

register #(33) IF_ID_pc
(
    .clk,
    .load(pipe1),
    .in({pc_out, pcmux_sel_IF}),
    .out({pc_out_ID, pcmux_sel_ID})
);

assign imem_stall = ~pipe2;

/// MARK: - ID/EX pipeline register

register #(2*32+$bits(rv32i_control_word)) ID_EX_pipeline
(
    .clk,
    .load(alu_resp & dmem_resp),
    .in({ctwmux_out, selected_rs1_out, selected_rs2_out}),
    .out({ctw_EX, rs1_out_EX, rs2_out_EX})
);

/// MARK: - EX/MEM pipeline register

register #($bits(rv32i_control_word)+2*32+1+1) EX_MEM_pipeline
(
    .clk,
    .load(dmem_resp),
    .in({ctw_EX, selected_rs2_EX_out, alu_out, alu_ready, br_en}),
    .out({ctw_MEM, rs2_out_MEM, alu_out_MEM, alu_ready_MEM, br_en_MEM})
);

/// MARK: - MEM/WB pipeline register

register #($bits(rv32i_control_word)+32*2+1+1 + 32) MEM_WB_pipeline
(
    .clk,
    .load(dmem_resp),
    .in({ctw_MEM, alu_out_MEM, dmem_address_untruncated, br_en_MEM, dmem_address, alu_ready_MEM}),
    .out({ctw_WB, alu_out_WB, dmem_address_untruncated_WB, br_en_WB, dmem_address_WB, alu_ready_WB})
);

assign dmem_stall = 1'd0;

endmodule