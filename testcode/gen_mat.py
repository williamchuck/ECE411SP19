print ".align 4"
print ".section .text"
print ".globl _start"
print "_start:"

for i in range(2):
    for j in range(8):
        print "lw x1, S" + str(i*10+j)
        print "la x2, T" + str(i*10+j)
        print "sw x1, 0(x2)"

for i in range(2, 5):
    for j in range(8):
        print "la x3, S" + str(i*10+j)
        print "la x2, T" + str(i*10+j)
        print "lhu x1, 0(x3)"
        print "sh x1, 0(x2)"
        print "lhu x1, 2(x3)"
        print "sh x1, 2(x2)"

for i in range(5, 8):
    for j in range(8):
        print "la x3, S" + str(i*10+j)
        print "la x2, T" + str(i*10+j)
        print "lbu x1, 0(x3)"
        print "sb x1, 0(x2)"
        print "lbu x1, 1(x3)"
        print "sb x1, 1(x2)"
        print "lbu x1, 2(x3)"
        print "sb x1, 2(x2)"
        print "lbu x1, 3(x3)"
        print "sb x1, 3(x2)"

for i in range(8):
    for j in range(8):
        print "lw x1, S" + str(i*10+j)

print "halt:"
print "beq x0, x0, halt"

for i in range(8):
    for j in range(8):
        print "S" + str(i*10+j) + ": .word " + hex(10 * i + j)

for i in range(8):
    for j in range(8):
        print "T" + str(i*10+j) + ": .word 0x00000000"