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

    # Note that one/two/eight are data labels
    lw   x1, LVAL1
    lw   x2, LVAL2
    lw   x3, LVAL3
    add  x4, x1, x3
    addi x6, x0, 4
    add  x3, x4, x6
    la   x10, SVAL1
    sw   x3, 0(x10)
    addi x6, x0, -10
    add  x4, x4, x6
    la   x10, SVAL2
    sw   x4, 0(x10)
    addi x6, x0, -13
    and  x5, x2, x6
    la   x10, SVAL3
    sw   x5, 0(x10)
    addi x6, x0, 12
    and  x6, x2, x6
    or   x6, x6, x0
    la   x10, SVAL4
    sw   x6, 0(x10)
    lw   x8, LVAL4
    lw   x9, LVAL5
    lw   x10, LVAL6
    xor  x11, x8, x9
    la   x12, SVAL5
    sw   x11, 0(x12)
    sll  x11, x9, x10
    la   x12, SVAL6
    sw   x11, 0(x12)
    srl  x11, x9, x10
    la   x12, SVAL7
    sw   x11, 0(x12)
    
    lw   x1, SVAL1
    lw   x2, SVAL2
    lw   x3, SVAL3
    lw   x4, SVAL4
    lw   x8, SVAL5
    lw   x9, SVAL6
    lw   x10, SVAL7

    jal  x7, there
    
goodend:
    j    goodend

there:	
    lw   x6, good
    jalr x0, x7, 0
    lw   x6, badend
    
badend:
    j    badend

.section .rodata

bad:        .word 0xdeadbeef
LVAL1:	    .word 0x00000020
LVAL2:	    .word 0x000000D5
LVAL3:	    .word 0x0000000F
LVAL4:	    .word 0x00000F0F
LVAL5:	    .word 0x000000FF
LVAL6:	    .word 0x00000004
SVAL1:	    .word 0x00000000
SVAL2:	    .word 0x00000000
SVAL3:	    .word 0x00000000
SVAL4:	    .word 0x00000000
SVAL5:	    .word 0x00000000
SVAL6:	    .word 0x00000000
SVAL7:	    .word 0x00000000
good:       .word 0x600d600d
