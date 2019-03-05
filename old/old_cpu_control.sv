import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module old_cpu_control
(
  input clk,

  /* Datapath controls */
  input rv32i_reg rs1,
  input rv32i_reg rs2,
  input rv32i_reg rd,
  input rv32i_opcode opcode,
  input logic [2:0] funct3,
  input logic [6:0] funct7,
  input logic [1:0] lsb,
  input logic br_en,
  output logic load_pc,
  output logic load_ir,
  output logic load_regfile,
  output logic load_mar,
  output logic load_mdr,
  output logic load_data_out,
  output logic pcmux_sel,
  output logic alumux1_sel,
  output logic [2:0] alumux2_sel,
  output logic [2:0] regfilemux_sel,
  output logic marmux_sel,
  output logic cmpmux_sel,
  output alu_ops aluop,
  output branch_funct3_t cmpop,
  output rv32i_reg rs1_addr,
  output rv32i_reg rs2_addr,
  output rv32i_reg rd_addr,

  /* Memory signals */
  input logic mem_resp,
  output logic mem_read,
  output logic mem_write,
  output rv32i_mem_wmask mem_byte_enable
);

/*
* The following ~54 lines of code have been added to help you drive the
* verification monitor. This is not required but we think it will help you
* with testing so we've tried to make it as easy as possible for you to get it
* up and running.
* */
logic trap;
logic [3:0] rmask, wmask;
branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;

assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);

always_comb
begin : trap_check
    trap = 0;
    rmask = 0;
    wmask = 0;

    case (opcode)
        op_lui, op_auipc, op_imm, op_reg, op_jal, op_jalr:;

        op_br: begin
            case (branch_funct3)
                beq, bne, blt, bge, bltu, bgeu:;
                default: trap = 1;
            endcase
        end

        op_load: begin
            case (load_funct3)
                lw: rmask = 4'b1111;
                lh: rmask = (lsb == 2'b00) ? 4'h3 : 4'hc;
                lhu: rmask = (lsb == 2'b00) ? 4'h3 : 4'hc;
                lb: rmask = (lsb == 2'b00) ? 4'h1 : (
                            (lsb == 2'b01) ? 4'h2 : (
                            (lsb == 2'b10) ? 4'h4 : 4'h8 ));
                lbu: rmask = (lsb == 2'b00) ? 4'h1 : (
                             (lsb == 2'b01) ? 4'h2 : (
                             (lsb == 2'b10) ? 4'h4 : 4'h8 ));
                default: trap = 1;
            endcase
        end

        op_store: begin
            case (store_funct3)
                sw: wmask = 4'b1111;
                sh: wmask = (lsb == 2'b00) ? 4'h3 : 4'hc;
                sb: wmask = (lsb == 2'b00) ? 4'h1 : (
                            (lsb == 2'b01) ? 4'h2 : (
                            (lsb == 2'b10) ? 4'h4 : 4'h8 ));
                default: trap = 1;
            endcase
        end

        default: trap = 1;
    endcase
end

enum int unsigned {
    FETCH1,
    FETCH2,
    FETCH3,
    DECODE,
    S_IMM,
    S_REG,
    BR,
    CALC_ADDR,
    LDR1,
    LDR2,
    STR1,
    STR2,
    S_AUIPC,
    S_LUI,
    S_JAL,
    S_JALR
} state, next_state;

always_comb
begin : state_actions
    // Control
    load_pc = 1'b0;
    load_ir = 1'b0;
    load_regfile = 1'b0;
    load_mar = 1'b0;
    load_mdr = 1'b0;
    load_data_out = 1'b0;
    pcmux_sel = 0;
    alumux1_sel = 1'b0;
    alumux2_sel = 3'b000;
    regfilemux_sel = 3'b000;
    marmux_sel = 1'b0;
    cmpmux_sel = 1'b0;
    aluop = alu_ops'(funct3);
    cmpop = branch_funct3_t'(funct3);

    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_byte_enable = 4'b1111;

    rs1_addr = 5'b00000;
    rs2_addr = 5'b00000;
    rd_addr = 5'b00000;

    case(state)
        FETCH1: begin
            /* MAR <= PC */
            load_mar = 1;
        end

        FETCH2: begin
            /* Read memory */
            mem_read = 1;
            load_mdr = 1;
        end

        FETCH3: begin
            /* Load IR */
            load_ir = 1;
        end

        DECODE: /* Do nothing */;

        S_IMM: begin
            if (arith_funct3_t'(funct3) == slt) begin
                load_regfile = 1;
                load_pc = 1;
                cmpop = blt;
                regfilemux_sel = 3'b001;
                cmpmux_sel = 1;
                rs1_addr = rs1;
                rd_addr = rd;
            end else if (arith_funct3_t'(funct3) == sltu) begin
                load_regfile = 1;
                load_pc = 1;
                cmpop = bltu;
                regfilemux_sel = 3'b001;
                cmpmux_sel = 1;
                rs1_addr = rs1;
                rd_addr = rd;
            end else if (arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                load_regfile = 1;
                load_pc = 1;
                aluop = alu_sra;
                rs1_addr = rs1;
                rd_addr = rd;
            end else begin
                load_regfile = 1;
                load_pc = 1;
                rs1_addr = rs1;
                rd_addr = rd;
            end
        end

        S_REG: begin
            if (arith_funct3_t'(funct3) == slt) begin
                load_regfile = 1;
                load_pc = 1;
                cmpop = blt;
                regfilemux_sel = 3'b001;
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = rd;
            end else if (arith_funct3_t'(funct3) == sltu) begin
                load_regfile = 1;
                load_pc = 1;
                cmpop = bltu;
                regfilemux_sel = 3'b001;
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = rd;
            end else if(arith_funct3_t'(funct3) == sr && funct7 == 7'b0100000) begin
                load_regfile = 1;
                load_pc = 1;
                aluop = alu_sra;
                alumux2_sel = 3'b101;
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = rd;
            end else if (arith_funct3_t'(funct3) == add && funct7 == 7'b0100000) begin
                load_regfile = 1;
                load_pc = 1;
                aluop = alu_sub;
                alumux2_sel = 3'b101;
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = rd;
            end else begin
                load_regfile = 1;
                load_pc = 1;
                alumux2_sel = 3'b101;
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = rd;
            end
        end

        BR: begin
            pcmux_sel = br_en;
            load_pc = 1;
            alumux1_sel = 1;
            alumux2_sel = 3'b010;
            aluop = alu_add;
            rs1_addr = rs1;
            rs2_addr = rs2;
        end

        CALC_ADDR: begin
            if (opcode == op_load) begin
                aluop = alu_add;
                load_mar = 1;
                marmux_sel = 1;
                rs1_addr = rs1;
            end else begin
                aluop = alu_add;
                load_mar = 1;
                marmux_sel = 1;
                rs1_addr = rs1;
                rs2_addr = rs2;
                alumux2_sel = 3'b011;
                load_data_out = 1;
            end
        end

        LDR1: begin
            load_mdr = 1;
            mem_read = 1;
        end

        LDR2: begin
            regfilemux_sel = 3'b011;
            load_regfile = 1;
            load_pc = 1;
            rd_addr = rd;
            rs1_addr = rs1;
        end

        STR1: begin
            mem_write = 1;
            aluop = alu_add;
            marmux_sel = 1;
            rs1_addr = rs1;
            rs2_addr = rs2;
            alumux2_sel = 3'b011;
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
                default: ;
            endcase
        end

        STR2: begin
            load_pc = 1;
            alumux2_sel = 3'b011;
            rs1_addr = rs1;
            load_data_out = 1;
            rs2_addr = rs2;
        end

        S_AUIPC: begin
            load_regfile = 1;
            alumux1_sel = 1;
            alumux2_sel = 3'b001;
            aluop = alu_add;
            load_pc = 1;
            rd_addr = rd;
        end

        S_LUI: begin
            load_regfile = 1;
            load_pc = 1;
            regfilemux_sel = 3'b010;
            rd_addr = rd;
        end

        S_JAL: begin
            load_regfile = 1;
            rd_addr = rd;
            load_pc = 1;
            pcmux_sel = 1;
            alumux1_sel = 1;
            alumux2_sel = 3'b100;
            aluop = alu_add;
            regfilemux_sel = 3'b100;
        end

        S_JALR: begin
            load_regfile = 1;
            rd_addr = rd;
            rs1_addr = rs1;
            load_pc = 1;
            pcmux_sel = 1;
            aluop = alu_add;
            regfilemux_sel = 3'b100;
        end

        default: /* Do nothing */;
    endcase
end

always_comb
begin : next_state_logic
    next_state = state;
    case(state)
        FETCH1: next_state = FETCH2;
        FETCH2: if (mem_resp) next_state = FETCH3;
        FETCH3: next_state = DECODE;

        DECODE: begin
            case(opcode)
                op_auipc: next_state = S_AUIPC;
                op_lui: next_state = S_LUI;
                op_load: next_state = CALC_ADDR;
                op_store: next_state = CALC_ADDR;
                op_imm: next_state = S_IMM;
                op_reg: next_state = S_REG;
                op_br: next_state = BR;
                op_jal: next_state = S_JAL;
                op_jalr: next_state = S_JALR;
                default: $display("Unknown␣opcode");
            endcase
        end

        CALC_ADDR: begin
            case (opcode)
                op_load: next_state = LDR1;
                op_store: next_state = STR1;
                default: $display("Paradoxical opcode");
            endcase
        end

        LDR1: if (mem_resp) next_state = LDR2;
        STR1: if (mem_resp) next_state = STR2;

        default: next_state = FETCH1;
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : old_cpu_control
