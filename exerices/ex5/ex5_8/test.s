# C code:
# unsigned int squre(unsigned int i)
# {
#     return i * i;
# }
# 
# unsigned int sum_squres(unsigned int i)
# {
#     unsigned int sum = 0;
#     for (int j = 0; j <= i; j++)
#     {
#         sum += squre(j);
#     }
#     return sum;
# }
# 
# void _start()
# {
#     sum_squre(3);
# }
# 
# Description:
#   Using assembly language to implement equivalent C languge.
#

    .text
    .global _start

_start:
    la sp, stack_end	# prepare stack for calling functions

    li a0, 3
    call sum_squre

stop:
    j stop

sum_squre:
    # prologue
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)

    # s0 store input param i
    # s1 store sum
    # s2 sotre j
    # s3 store squre(j)
    mv s0, a0
    li s1, 0
    li s2, 0

loop:
    mv a0, s2
    jal squre
    add s1, s1, a0
    addi s2, s2, 1
    ble s2, s0, loop
    mv a0, s1
    
    # epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20

    ret

    nop

squre:
    # prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    # squre
    mv s0, a0
    mul s1, s0, s0
    mv a0, s1

    # epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    ret

    nop

stack_start:
    .rept 12
    .word 0
    .endr

stack_end:


    .end