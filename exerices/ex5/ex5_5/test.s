# C code
# int array[2] = {0x11111111, 0xffffffff};
# int i = array[0];
# int j = array[1];
# Description:
#   Using assembly language to implement equivalent C language.

    .text
    .global _start

_start:
    # x3 store array address
    # x4 store i
    # x5 store j
    la x3, _array
    lw x4, 0(x3)
    lw x5, 4(x3)

stop:
    j stop


_array:
    .word 0x11111111
    .word 0xffffffff

    .end