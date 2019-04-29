.align 4
.section .text
.globl _start

_start:
    li sp, 0x84000000
	addi	sp,sp,-704
	sw	ra,700(sp)
	sw	s0,696(sp)
	sw	s1,692(sp)
	addi	s0,sp,704
	sw	zero,-20(s0)
	j	.L2
.L5:
	sw	zero,-24(s0)
	j	.L3
.L4:
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	sub	a4,a4,a5
	lw	a5,-20(s0)
	slli	a3,a5,3
	lw	a5,-24(s0)
	add	a5,a3,a5
	slli	a5,a5,2
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-436(a5)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L3:
	lw	a4,-24(s0)
	li	a5,7
	ble	a4,a5,.L4
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	li	a5,12
	ble	a4,a5,.L5
	sw	zero,-20(s0)
	j	.L6
.L9:
	sw	zero,-24(s0)
	j	.L7
.L8:
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	add	a3,a4,a5
	lw	a4,-20(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	lw	a4,-24(s0)
	add	a5,a5,a4
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	sw	a3,-532(a5)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L7:
	lw	a4,-24(s0)
	li	a5,2
	ble	a4,a5,.L8
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L6:
	lw	a4,-20(s0)
	li	a5,7
	ble	a4,a5,.L9
	addi	a5,s0,-452
	sw	a5,-28(s0)
	addi	a5,s0,-548
	sw	a5,-36(s0)
	addi	a5,s0,-704
	sw	a5,-32(s0)
	sw	zero,-20(s0)
	j	.L10
.L13:
	sw	zero,-24(s0)
	j	.L11
.L12:
	lw	a5,-24(s0)
	slli	a5,a5,2
	lw	a4,-36(s0)
	add	a4,a4,a5
	lw	s1,-32(s0)
	addi	a5,s1,4
	sw	a5,-32(s0)
	li	a3,3
	li	a2,8
	mv	a1,a4
	lw	a0,-28(s0)
	call	foo
	mv	a5,a0
	sw	a5,0(s1)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L11:
	lw	a4,-24(s0)
	li	a5,2
	ble	a4,a5,.L12
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
	lw	a5,-28(s0)
	addi	a5,a5,32
	sw	a5,-28(s0)
.L10:
	lw	a4,-20(s0)
	li	a5,12
	ble	a4,a5,.L13
.L14:
	j	.L14
foo:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	a3,-48(s0)
	sw	zero,-20(s0)
	j	.L16
.L17:
	lw	a5,-36(s0)
	addi	a4,a5,4
	sw	a4,-36(s0)
	lw	a4,0(a5)
	lw	a5,-40(s0)
	lw	a5,0(a5)
	mv	a1,a5
	mv	a0,a4
	call	__mulsi3
	mv	a5,a0
	mv	a4,a5
	lw	a5,-20(s0)
	add	a5,a5,a4
	sw	a5,-20(s0)
	lw	a5,-48(s0)
	slli	a5,a5,2
	lw	a4,-40(s0)
	add	a5,a4,a5
	sw	a5,-40(s0)
.L16:
	lw	a5,-44(s0)
	addi	a4,a5,-1
	sw	a4,-44(s0)
	bnez	a5,.L17
	lw	a5,-20(s0)
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
__mulsi3:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	zero,-20(s0)
	j	.L20
.L22:
	lw	a5,-36(s0)
	andi	a5,a5,1
	beqz	a5,.L21
	lw	a4,-20(s0)
	lw	a5,-40(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
.L21:
	lw	a5,-36(s0)
	srli	a5,a5,1
	sw	a5,-36(s0)
	lw	a5,-40(s0)
	slli	a5,a5,1
	sw	a5,-40(s0)
.L20:
	lw	a5,-36(s0)
	bnez	a5,.L22
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
