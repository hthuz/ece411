my_mp2test.s:
.align 4
.section .text
.globl _start

_start:
    # la x2, data1
    lw x3, data1
    # sw x3, 0(x2)
    # lw x3, data2
    # lui x1, 100

ready_halt:
    li  t0, 1
    la  t1, tohost
    sw  t0, 0(t1)
    sw  x0, 4(t1)
myhalt:                 # Infinite loop to keep the processor
    beq x0, x0, myhalt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.

.section .rodata

data0:      .word 0x00000000
data1:      .word 0x11111111
data2:      .word 0x22222222
data3:      .word 0x33333333
data4:      .word 0x44444444


.section ".tohost"
.globl tohost
tohost: .dword 0
.section ".fromhost"
.globl fromhost
fromhost: .dword 0
