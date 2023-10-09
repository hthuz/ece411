my_mp2test.s:
.align 4
.section .text
.globl _start

_start:
    la x1, data0  # 0000
    la x2, data1 
    la x3, data2
    la x4, data3
    la x5, data4

    lw x6, wdata0
    sw x6, 0(x1)

    lw x6, wdata1
    sw x6, 0(x2)
    
    lw x6, wdata2
    sw x6, 0(x3)

    lw x6, wdata3
    sw x6,  0(x4)

    lw x6, wdata4
    sw x6, 0(x5)



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
                             # 4000 002C
            .fill 0x00000000 # 4000 0030
data0:      .word 0x00000000 # At address 4000 0034
            .fill 0x00040000 
data1:      .word 0x11111111 # At address 4000 0038
            .fill 0x00040000 
data2:      .word 0x22222222 # At address 4000 004c
            .fill 0x00040000 
data3:      .word 0x33333333
            .fill 0x00040000 
data4:      .word 0x44444444


wdata0:     .word 0xffff0000
wdata1:     .word 0xffff1111
wdata2:     .word 0xffff2222
wdata3:     .word 0xffff3333
wdata4:     .word 0xffff4444
wdata5:     .word 0xffff5555


.section ".tohost"
.globl tohost
tohost: .dword 0
.section ".fromhost"
.globl fromhost
fromhost: .dword 0
