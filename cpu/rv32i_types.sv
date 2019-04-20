package rv32i_types;

typedef enum bit [6:0] {
    op_lui   = 7'b0110111, //load upper immediate (U type)
    op_auipc = 7'b0010111, //add upper immediate PC (U type)
    op_jal   = 7'b1101111, //jump and link (J type)
    op_jalr  = 7'b1100111, //jump and link register (I type)
    op_br    = 7'b1100011, //branch (B type)
    op_load  = 7'b0000011, //load (I type)
    op_store = 7'b0100011, //store (S type)
    op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011, //arith ops with register operands (R type)
    op_csr   = 7'b1110011, //control and status register (I type)
    op_nop   = 7'b1111111  //no-op
} rv32i_opcode;

typedef enum bit [1:0] {
    cop2_0 = 2'd0,
    cop2_1 = 2'd1,
    cop2_2 = 2'd2
} c_op2;

typedef enum bit [2:0] {
    cop3_0 = 3'd0,
    cop3_1 = 3'd1,
    cop3_2 = 3'd2,
    cop3_3 = 3'd3,
    cop3_4 = 3'd4,
    cop3_5 = 3'd5,
    cop3_6 = 3'd6,
    cop3_7 = 3'd7
} c_funct3_t;

typedef enum bit [4:0] {
    c_addi4spn = {cop2_0, cop3_0},
    c_fld = {cop2_0, cop3_1}, //not supported
    c_lw = {cop2_0, cop3_2},
    c_flw = {cop2_0, cop3_3}, //not supported
    c_reserved = {cop2_0, cop3_4}, //not supported
    c_fsd = {cop2_0, cop3_5}, //not supported
    c_sw = {cop2_0, cop3_6},
    c_fsw = {cop2_0, cop3_7}, //not supported
    c_addi = {cop2_1, cop3_0},
    c_jal = {cop2_1, cop3_1},
    c_li = {cop2_1, cop3_2},
    c_lui_addi16sp = {cop2_1, cop3_3},
    c_misc_alu = {cop2_1, cop3_4},
    c_j = {cop2_1, cop3_5},
    c_beqz = {cop2_1, cop3_6},
    c_bnez = {cop2_1, cop3_7},
    c_slli = {cop2_2, cop3_0},
    c_fldsp = {cop2_2, cop3_1}, //not supported
    c_lwsp = {cop2_2, cop3_2},
    c_flwsp = {cop2_2, cop3_3}, //not supported
    c_jalr_mv_add = {cop2_2, cop3_4},
    c_fsdsp =  {cop2_2, cop3_5}, //not supported
    c_swsp =  {cop2_2, cop3_6},
    c_fswsp = {cop2_2, cop3_7} //not supported
} rv32ic_opcode;

typedef enum bit [1:0] { 
    irh_one = 1'd0,
    irh_rdata_high = 2'd1
    irh_rdata_low = 2'd2
} ir_high_sel_t;

typedef enum bit [1:0] { 
    irl_one = 2'd0,
    irl_rdata_low = 2'd1,
    irl_low_full = 2'd2,
    irl_half = 2'd3
} ir_low_sel_t;

typedef enum bit {
    rs1_EX_sel = 1'd0,
    pc_out_sel = 1'd1
} alumux1_sel_t;

typedef enum bit [2:0] {
    i_imm_sel = 3'd0,
    u_imm_sel = 3'd1,
    b_imm_sel = 3'd2,
    s_imm_sel = 3'd3,
    j_imm_sel = 3'd4,
    rs2_EX_sel = 3'd5
} alumux2_sel_t;

typedef enum bit [2:0] {
    alu_out_wb_sel = 3'd0,
    br_en_wb_sel = 3'd1,
    u_imm_wb_sel = 3'd2,
    rdata_wb_sel = 3'd3,
    pc_inc_wb_sel = 3'd4
} wb_sel_t;

typedef enum bit [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
} branch_funct3_t;

typedef enum bit [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
} store_funct3_t;

typedef enum bit [2:0] {
    add  = 3'b000, //check bit30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr   = 3'b101, //check bit30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] {
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
} alu_ops;

typedef struct packed {
    rv32i_opcode opcode;
    alu_ops aluop;
    branch_funct3_t cmpop;
    logic load_regfile;
    logic dmem_read;
    logic dmem_write;
    logic cmpmux_sel;
    logic [1:0] pcmux_sel;
    alumux1_sel_t alumux1_sel;
    wb_sel_t wbmux_sel;
    alumux2_sel_t alumux2_sel;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] pc;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
} rv32i_control_word;

typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;

endpackage : rv32i_types
