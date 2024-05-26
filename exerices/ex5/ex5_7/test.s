# C code:
# char array[] = {'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd', '!', '\0'};
# int len = 0;
# while (arrar[len] != '\0') {
#     len++;
# }
# Description:
#   Using assembly language to implement equivalent C language.

    .text
    .global _start

_start:
    # x3 store array address
    # x4 store len
    la x3, _array
    li x4, 0
    li x5, '\0'

loop:
    addi x4, x4, 1
    addi x3, x3, 1
    lb x6, 1(x3)
    bne x5, x6, loop    


stop:
    j stop

_array:
    .byte 'h'
    .byte 'e'
    .byte 'l'
    .byte 'l'
    .byte 'o'
    .byte ','
    .byte 'w'
    .byte 'o'
    .byte 'r'
    .byte 'l'
    .byte 'd'
    .byte '!'
    .byte '\0'

    .end