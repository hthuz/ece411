riscv_mp2test.s:
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
    # lw  x1, threshold # X1 <- 0x80(40)
    # lui  x1, 40
    # lui  x2, 2       # X2 <= 2

    # lui  x3, 8     # X3 <= 8

    
    # la x10, result      # X10 <= Addr[result]

    # lw x8, mygood         # X8 <= 0x12345678
    # sw x8, 0(x10)       # [Result] <= 0x12345678

    lui x2, 40

    la x3, my_next
    jalr x4, 1(x3)

    lui x2, 60
    lui x2, 70
    lui x2, 80
my_next:
    lui x2, 90
    lui x2, 100
    lui x2, 110



    # load test
    # lw x1, load_num
    # lh x2, load_num
    # lhu x3, load_num
    # lb x4, load_num
    # lbu x5, load_num

    # imm passed
    # slti x3, x2, 3 
    # sltiu x3, x2, 3
    # addi
    # slli x3, x3, 3
    # srli x4, x3, 4
    # srai x4, x3, 4
    # xori
    # ori
    # andi

    # srli x2, x2, 12
    # rli x3, x3, 12
    # Passed
    # add x3, x1, x2
    # sll x3, x3, x2
    # sub x3, x3, x2
    # slt x4, x3, x2
    # sltu x4, x3, x3
    # srl x4, x3, x2
    # sra x4, x3, x2
    # xor x3, x1, x2
    # or x3, x2, x1
    # and x3, x2, x1

    # slli x3, x3, 3
    # srli x2, x2, 10

ready_halt:
    li  t0, 1
    la  t1, tohost
    sw  t0, 0(t1)
    sw  x0, 4(t1)
myhalt:                 # Infinite loop to keep the processor
    beq x0, x0, myhalt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.


    addi x4, x3, 4    # X4 <= X3 + 2

loop1:
    slli x3, x3, 1    # X3 <= X3 << 1
    xori x5, x2, 127  # X5 <= XOR (X2, 7b'1111111)
    addi x5, x5, 1    # X5 <= X5 + 1
    addi x4, x4, 4    # X4 <= X4 + 8

    bleu x4, x1, loop1   # Branch if last result was zero or positive.

    andi x6, x3, 64   # X6 <= X3 + 64

    auipc x7, 8         # X7 <= PC + 8
    lw x8, good         # X8 <= 0x600d600d
    la x10, result      # X10 <= Addr[result]
    sw x8, 0(x10)       # [Result] <= 0x600d600d
    lw x9, result       # X9 <= [Result]
    bne x8, x9, deadend # PC <= bad if x8 != x9

    li  t0, 1
    la  t1, tohost
    sw  t0, 0(t1)
    sw  x0, 4(t1)
halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.

deadend:
    lw x8, bad     # X8 <= 0xdeadbeef
deadloop:
    beq x8, x8, deadloop

.section .rodata

bad:        .word 0xdeadbeef
threshold:  .word 0x00000040
result:     .word 0x00000000
good:       .word 0x600d600d
good2:      .word 0x6fff6fff
good3:      .word 0x00060066
mygood:     .word 0x12345678
mybad:      .word 0x87654321
load_num:   .word 0x1234f123

.section ".tohost"
.globl tohost
tohost: .dword 0
.section ".fromhost"
.globl fromhost
fromhost: .dword 0
