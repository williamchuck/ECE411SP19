riscv_mp0test.s:
.align 4
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # Note that the comments in this file should not be taken as
    # an example of good commenting style!!  They are merely provided
    # in an effort to help you understand the assembly style.
	
    # X4 will contain the number of succeeded test cases at the end
    add  x4, x0, x0
	
    # Initializing the registers for testing the reg-reg instrs
    lw   x1, LVAL1
    lw   x2, LVAL2
    lw   x3, LVAL3

    # Test case 1 for SLT instr
    slt  x5, x0, x1
    bne  x5, x0, badend
    addi x4, x4, 1
    # Test case 2 for SLT instr
    slt  x5, x0, x2
    beq  x5, x0, badend
    addi x4, x4, 1
    # Test case 3 for SLT instr
    slt  x5, x3, x3
    bne  x5, x0, badend
    addi x4, x4, 1

    #Test case 1 for SLTU
    sltu x5, x0, x1
    beq  x5, x0, badend
    addi x4, x4, 1
    # Test case 2 for SLTU instr
    sltu  x5, x1, x2
    bne  x5, x0, badend
    addi x4, x4, 1
	
    # Test case 1 for SUB instr
    sub  x5, x1, x2
    slt  x5, x0, x5
    bne  x5, x0, badend
    addi x4, x4, 1
    # Test case 2 for SUB instr
    sub  x5, x3, x2
    slt  x5, x0, x5
    beq  x5, x0, badend
    addi x4, x4, 1
    # Test case 3 for SUB instr
    sub  x5, x1, x1
    slt  x5, x0, x5
    bne  x5, x0, badend
    addi x4, x4, 1

    # Test case 1 for SRA
    sra  x5, x1, x4
    bne  x5, x1, badend
    sra  x5, x3, x4
    addi x4, x4, 1
    lw   x6, SRAOUT
    bne  x5, x6, badend
    addi x4, x4, 1
  
    # Initializing the registers for testing the memory instrs
    lw   x1, LVAL4B1
    lw   x2, LVAL5B1

    # Test case 1 for LB
    lb   x5, LVAL4B1
    lb   x6, LVAL4B2
    slli x6, x6, 8
    lb   x7, LVAL4B3
    slli x7, x7, 16
    lb   x8, LVAL4B4
    slli x8, x8, 24
    or   x8, x8, x7
    or   x8, x8, x6
    or   x8, x8, x5
    bne  x8, x1, badend
    addi x4, x4, 1
	
    # Test case 1 for LH
    lh   x5, LVAL4B1
    lh   x6, LVAL4B3
    slli x6, x6, 16
    or   x6, x6, x5
    bne  x6, x1, badend
    addi x4, x4, 1
	
    # Test case 1 for LBU
    lbu  x5, LVAL5B1
    lbu  x6, LVAL5B2
    slli x6, x6, 8
    lbu  x7, LVAL5B3
    slli x7, x7, 16
    lbu  x8, LVAL5B4
    slli x8, x8, 24
    or   x8, x8, x7
    or   x8, x8, x6
    or   x8, x8, x5
    bne  x8, x2, badend
    addi x4, x4, 1
	
    # Test case 1 for LHU
    lhu  x5, LVAL5B1
    lhu  x6, LVAL5B3
    slli x6, x6, 16
    or   x6, x6, x5
    bne  x6, x2, badend
    addi x4, x4, 1
	
    # Test case 1 for SB
    sb   x1, SVAL1B1, x9
    srli x1, x1, 8
    sb   x1, SVAL1B2, x9
    srli x1, x1, 8
    sb   x1, SVAL1B3, x9
    srli x1, x1, 8
    sb   x1, SVAL1B4, x9
    lw   x1, LVAL4B1
    lw   x5, SVAL1B1
    bne  x5, x1, badend
    addi x4, x4, 1
	
    # Test case 1 for SH
    sh   x2, SVAL2B1, x9
    srli x2, x2, 16
    sh   x2, SVAL2B3, x9
    lw   x2, LVAL5B1
    lw   x5, SVAL2B1
    bne  x5, x2, badend
    addi x4, x4, 1

	
goodend:
    jal  x0, goodend

badend:
    jal  x0, badend

.section .rodata

LVAL1:	    .word 0xffffffff
LVAL2:	    .word 0x0000ffff
LVAL3:	    .word 0x7fffffff
LVAL4B1:    .byte 0x78
LVAL4B2:    .byte 0x56
LVAL4B3:    .byte 0x34
LVAL4B4:    .byte 0x12
LVAL5B1:    .byte 0x98
LVAL5B2:    .byte 0xba
LVAL5B3:    .byte 0xdc
LVAL5B4:    .byte 0xfe
SVAL1B1:    .byte 0x00
SVAL1B2:    .byte 0x00
SVAL1B3:    .byte 0x00
SVAL1B4:    .byte 0x00
SVAL2B1:    .byte 0x00
SVAL2B2:    .byte 0x00
SVAL2B3:    .byte 0x00
SVAL2B4:    .byte 0x00
SRAOUT:	    .word 0x007fffff
