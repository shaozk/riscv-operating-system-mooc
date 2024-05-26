# C code:
# struct S {
#     unsigned int a;
#     unsigned int b;
# };
# 
# struct S s = {0};
# 
# #define set_struct(s) \
#     s.a = a; \
#     s.b = b;
# 
# #define get_struct(s) \
#     a = s.a; \
#     b = s.b;
# 
# void foo()
# {
#     register unsigned int a = 0x12345678;
#     register unsigned int b = 0x87654321;
#     set_struct(s);
#     a = 0;
#     b = 0;
#     get_struct(s);
# }
# Description:
#   Using assembly language to implement equivalent C language.

# Macro definition
.macro set_struct, reg
    la x5, \reg
    sw x3, 0(x5)
    sw x4, 4(x5)
.endm

.macro get_struct, reg
    la x5, \reg
    lw x3, 0(x5)
    lw x4, 4(x5)
.endm

    .text
    .global _start 

_start:
    # x3 store a
    # x4 store b
    li x3, 0x12345678
    li x4, 0x87654321

    set_struct _struct_s

    li x3, 0
    li x4, 0

    get_struct _struct_s

stop:
    j stop

_struct_s:
    .word 0x00000000
    .word 0x00000000

    .end