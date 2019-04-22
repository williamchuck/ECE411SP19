#  mp3-cp1.s version 3.0
.align 4
.section .text
.globl _start
_start:
	lw x1, OP1
	lw x2, OP2
	mul x3, x1, x2
    mulh x4, x1, x2
    mulhu x5, x1, x2
    mulhsu x6, x1, x2

    div x7, x1, x2
    divu x8, x1, x2
    rem x9, x1, x2
    remu x10, x1, x2
    
done:
    beq x0, x0, done

.section .rodata
.balign 256
OP1:    .word 123454321
OP2:    .word 11
