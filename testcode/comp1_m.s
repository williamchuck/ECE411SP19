.align 4
.section .text
.globl _start

_start:
    li sp, 0x84000000
	addi	sp,sp,-288
	sw	ra,284(sp)
	sw	s0,280(sp)
	addi	s0,sp,288
	addi	a5,s0,-280
	sw	a5,-24(s0)
	sw	zero,-20(s0)
	j	.L2
.L5:
	lw	a5,-20(s0)
	addi	a5,a5,1
	addi	a4,s0,-280
	slli	a5,a5,3
	add	a4,a4,a5
	lw	a5,-20(s0)
	slli	a5,a5,3
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-260(a5)
	lw	a5,-20(s0)
	andi	a5,a5,1
	beqz	a5,.L3
	li	a5,-1
	j	.L4
.L3:
	li	a5,1
.L4:
	lw	a4,-20(s0)
	mul	a4,a5,a4
	lw	a5,-20(s0)
	slli	a5,a5,3
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-264(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	li	a5,30
	ble	a4,a5,.L5
	sw	zero,-28(s0)
	sw	zero,-32(s0)
	lw	a0,-24(s0)
	call	foo
.L6:
	j	.L6
foo:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	sw	zero,-28(s0)
	j	.L8
.L12:
	li	a5,1
	sw	a5,-20(s0)
	lw	a5,-36(s0)
	sw	a5,-24(s0)
	j	.L9
.L11:
	lw	a5,-24(s0)
	lw	a4,0(a5)
	lw	a5,-24(s0)
	lw	a5,4(a5)
	lw	a5,0(a5)
	ble	a4,a5,.L10
	lw	a5,-24(s0)
	lw	a5,0(a5)
	sw	a5,-32(s0)
	lw	a5,-24(s0)
	lw	a5,4(a5)
	lw	a4,0(a5)
	lw	a5,-24(s0)
	sw	a4,0(a5)
	lw	a5,-24(s0)
	lw	a5,4(a5)
	lw	a4,-32(s0)
	sw	a4,0(a5)
	sw	zero,-20(s0)
.L10:
	lw	a5,-24(s0)
	lw	a5,4(a5)
	sw	a5,-24(s0)
.L9:
	lw	a5,-24(s0)
	lw	a5,4(a5)
	lw	a4,-28(s0)
	bne	a4,a5,.L11
	lw	a5,-24(s0)
	sw	a5,-28(s0)
.L8:
	lw	a5,-20(s0)
	beqz	a5,.L12
	nop
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra

