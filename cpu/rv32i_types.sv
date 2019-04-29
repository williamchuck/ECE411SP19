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
    op_nop   = 7'b0000000  //no-op
} rv32i_opcode;

typedef enum bit [1:0] {
    cmpmux_rs2 = 2'd0,
    cmpmux_imm = 2'd1,
    cmpmux_zero = 2'd2
} cmpmux_sel_t;

typedef enum bit {
    alm1_rs1 = 1'd0,
    alm1_pc = 1'd1
} alumux1_sel_t;

typedef enum bit [3:0] {
    imm_i = 4'd0,
    imm_u = 4'd1,
    imm_b = 4'd2,
    imm_s = 4'd3,
    imm_j = 4'd4
} ctwimm_sel_t;

typedef enum bit [1:0] {
    alm2_imm = 2'd0,
    alm2_rs2 = 2'd1,
    alm2_zero = 2'd2
} alumux2_sel_t;

typedef enum bit [2:0] {
    wbm_alu = 3'd0,
    wbm_br = 3'd1,
    wbm_imm = 3'd2,
    wbm_rdata = 3'd3,
    wbm_pc4 = 3'd4,
    wbm_pc2 = 3'd5
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

typedef enum bit [2:0] {
    mul    = 3'b000, // sign-sign low
    mulh   = 3'b001, // sign-sign high
    mulhsu = 3'b010, // sign-unsign high
    mulhu  = 3'b011, // unsign-unsign high
    div    = 3'b100, // sign / sign
    divu   = 3'b101, // unsign / unsign
    rem    = 3'b110, // sign % sign
    remu   = 3'b111  // unsign $ unsign
} mul_ops;

typedef struct packed {
    rv32i_opcode opcode;
    alu_ops aluop;
    logic muldiv;
    branch_funct3_t cmpop;
    logic load_regfile;
    logic dmem_read;
    logic dmem_write;
    cmpmux_sel_t cmpmux_sel;
    logic [1:0] pcmux_sel;
    alumux1_sel_t alumux1_sel;
    wb_sel_t wbmux_sel;
    alumux2_sel_t alumux2_sel;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] pc;
    logic [31:0] imm;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
} rv32i_control_word;

typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;

endpackage : rv32i_types
