my_mp2test.s:
.align 4
.section .text
.globl _start

_start:
    andi x1,x1, 0  # counter 
    lw x2, loop_num # loop number
    lui x4, 100
    la x3, start_addr
    lw x5, tag_offset
loop_start:
    add x3, x3, x5
    sw x4, 0(x3)
    lw x4, 0(x3)


    addi x1,x1, 1
    bne x2, x1, loop_start

ready_halt:
    li  t0, 1
    la  t1, tohost   # 4000 0018 , inst 317
    sw  t0, 0(t1)    # 4000 001c , inst 3030313
    sw  x0, 4(t1)    # 4000 0020 , inst 532023
myhalt:                 # Infinite loop to keep the processor
    beq x0, x0, myhalt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.
                      # 4000 0028

.section .rodata

tag_offset: .word 0x00020000
start_addr: .word 0x40001000
            .fill 0x00800000
loop_num:   .word 0x00000064

.section ".tohost"
.globl tohost
tohost: .dword 0
.section ".fromhost"
.globl fromhost
fromhost: .dword 0
