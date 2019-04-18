.align 4
.section .text
.globl _start

_start:
    li sp, 0x84000000
	addi	sp,sp,-2032
	sw	s0,2024(sp)
	sw	s1,2020(sp)
	sw	s2,2016(sp)
	sw	s4,2008(sp)
	sw	ra,2028(sp)
	sw	s3,2012(sp)
	addi	sp,sp,-560
	addi	s4,sp,640
	addi	s2,sp,1600
	mv	s1,s4
	li	s0,0
.L2:
	addi	s3,s0,1
	sw	s0,0(s1)
	li	a1,80
	mv	a0,s3
	call	__modsi3
	addi	a5,s0,80
	sw	a0,0(s2)
	sw	s0,320(s1)
	sw	a5,640(s1)
	addi	a0,s0,37
	li	a1,80
	sw	a5,320(s2)
	call	__modsi3
	addi	a0,a0,80
	sw	a0,640(s2)
	li	a5,80
	mv	s0,s3
	addi	s1,s1,4
	addi	s2,s2,4
	bne	s3,a5,.L2
	li	a4,4096
	li	a5,-4096
	addi	a4,a4,-1536
	add	a4,a4,sp
	addi	a5,a5,1536
	add	a5,a4,a5
	li	a4,-1
.L3:
	sw	a4,0(a5)
	addi	a5,a5,4
	bne	s4,a5,.L3
	li	a5,4096
	addi	a4,a5,-1540
	li	a2,-4096
	addi	a5,a5,-1536
	addi	a7,a2,1536
	add	a5,a5,sp
	addi	t1,sp,1596
	add	t3,sp,a4
	addi	s4,s4,-4
	add	a7,a5,a7
.L10:
	lw	a0,0(t1)
	mv	a4,a0
	j	.L4
.L13:
	mv	a4,a5
.L4:
	li	a3,4096
	addi	a3,a3,-1536
	slli	a5,a4,2
	add	a3,a3,sp
	add	a5,a3,a5
	add	a5,a2,a5
	lw	a5,1536(a5)
	bgez	a5,.L13
	lw	a6,0(t3)
	mv	a3,a6
	j	.L5
.L14:
	mv	a3,a5
.L5:
	li	a1,4096
	addi	a1,a1,-1536
	slli	a5,a3,2
	add	a1,a1,sp
	add	a5,a1,a5
	add	a5,a2,a5
	lw	a5,1536(a5)
	bgez	a5,.L14
	bne	a3,a4,.L7
.L6:
	addi	t1,t1,-4
	addi	t3,t3,-4
	bne	s4,t1,.L10
	li	a5,37
	li	a4,-4096
.L11:
	li	a3,4096
	addi	a3,a3,-1536
	slli	a5,a5,2
	add	a3,a3,sp
	add	a5,a3,a5
	add	a5,a4,a5
	lw	a5,1536(a5)
	bgez	a5,.L11
.L12:
	j	.L12
.L15:
	mv	a0,a1
.L7:
	slli	a4,a0,2
	add	a4,a7,a4
	lw	a1,0(a4)
	bgez	a1,.L15
	slli	a5,a6,2
	add	a5,a7,a5
	lw	a3,0(a5)
	bltz	a3,.L23
.L16:
	mv	a6,a3
	slli	a5,a6,2
	add	a5,a7,a5
	lw	a3,0(a5)
	bgez	a3,.L16
.L23:
	beq	a0,a6,.L6
	add	t4,a1,a3
	bgt	a1,a3,.L24
	sw	t4,0(a4)
	sw	a0,0(a5)
	j	.L6
.L24:
	sw	t4,0(a5)
	sw	a6,0(a4)
	j	.L6
foo:
	j	.L26
.L27:
	mv	a1,a5
.L26:
	slli	a5,a1,2
	add	a5,a0,a5
	lw	a5,0(a5)
	bgez	a5,.L27
	mv	a0,a1
	ret
bar:
	j	.L29
.L33:
	mv	a1,a3
.L29:
	slli	a4,a1,2
	add	a4,a0,a4
	lw	a3,0(a4)
	bgez	a3,.L33
	slli	a5,a2,2
	add	a5,a0,a5
	lw	a6,0(a5)
	bltz	a6,.L35
.L34:
	mv	a2,a6
	slli	a5,a2,2
	add	a5,a0,a5
	lw	a6,0(a5)
	bgez	a6,.L34
.L35:
	beq	a2,a1,.L28
	add	a0,a6,a3
	blt	a6,a3,.L36
	sw	a0,0(a4)
	sw	a1,0(a5)
.L28:
	ret
.L36:
	sw	a0,0(a5)
	sw	a2,0(a4)
	ret
__mulsi3:
	mv	a5,a0
	li	a0,0
	beqz	a5,.L41
.L40:
	andi	a4,a5,1
	srli	a5,a5,1
	beqz	a4,.L39
	add	a0,a0,a1
.L39:
	slli	a1,a1,1
	bnez	a5,.L40
	ret
.L41:
	ret
__divsi3:
	addi	sp,sp,-16
	sw	s0,8(sp)
	srai	a5,a0,31
	srai	s0,a1,31
	xor	a0,a0,a5
	xor	a1,a1,s0
	sub	a1,a1,s0
	sub	a0,a0,a5
	sw	ra,12(sp)
	xor	s0,a5,s0
	call	__udivsi3
	xor	a0,a0,s0
	sub	a0,a0,s0
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
__modsi3:
	addi	sp,sp,-16
	sw	s0,8(sp)
	srai	a5,a0,31
	srai	s0,a1,31
	sw	s1,4(sp)
	sw	s2,0(sp)
	mv	s1,a0
	mv	s2,a1
	xor	a0,a0,a5
	xor	a1,a1,s0
	sub	a1,a1,s0
	sub	a0,a0,a5
	sw	ra,12(sp)
	xor	s0,a5,s0
	call	__udivsi3
	xor	a0,a0,s0
	mv	a1,s2
	sub	a0,a0,s0
	call	__mulsi3
	lw	ra,12(sp)
	lw	s0,8(sp)
	sub	a0,s1,a0
	lw	s2,0(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
__udivsi3:
	addi	sp,sp,-32
	sw	s1,20(sp)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	s1,0
	beqz	a1,.L50
	beqz	a0,.L50
	mv	s0,a0
	mv	a0,a1
	mv	s3,a1
	call	__clzsi2
	mv	s2,a0
	mv	a0,s0
	call	__clzsi2
	sub	a0,s2,a0
	li	a5,31
	bgtu	a0,a5,.L50
	mv	s1,s0
	beq	a0,a5,.L50
	addi	a4,a0,1
	li	a5,32
	sub	a5,a5,a4
	sll	a5,s0,a5
	srl	a0,s0,a4
	addi	a1,s3,-1
	li	s1,0
.L52:
	slli	a0,a0,1
	srli	a2,a5,31
	or	a2,a2,a0
	sub	a3,a1,a2
	srai	a3,a3,31
	slli	a5,a5,1
	and	a0,a3,s3
	addi	a4,a4,-1
	or	a5,a5,s1
	sub	a0,a2,a0
	andi	s1,a3,1
	bnez	a4,.L52
	slli	a5,a5,1
	or	s1,a5,s1
.L50:
	lw	ra,28(sp)
	lw	s0,24(sp)
	mv	a0,s1
	lw	s2,16(sp)
	lw	s1,20(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
__clzsi2:
	li	a5,-65536
	and	a5,a0,a5
	beqz	a5,.L67
	srli	a0,a0,16
	li	a4,8
	li	a3,0
.L61:
	li	a5,65536
	addi	a5,a5,-256
	and	a5,a0,a5
	beqz	a5,.L62
	srli	a0,a0,8
	mv	a4,a3
.L62:
	andi	a5,a0,240
	beqz	a5,.L63
	srli	a0,a0,4
	andi	a5,a0,12
	beqz	a5,.L65
.L71:
	srli	a0,a0,2
.L66:
	srli	a5,a0,1
	xori	a5,a5,1
	li	a3,2
	andi	a5,a5,1
	sub	a5,zero,a5
	sub	a0,a3,a0
	and	a0,a5,a0
	add	a0,a0,a4
	ret
.L67:
	li	a4,24
	li	a3,16
	j	.L61
.L63:
	andi	a5,a0,12
	addi	a4,a4,4
	bnez	a5,.L71
.L65:
	addi	a4,a4,2
	j	.L66
