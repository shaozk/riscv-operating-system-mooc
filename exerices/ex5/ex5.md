# 第5章 RISC-V 汇编语言编程

## 练习5-1

* 对 ``code/asm/sub`` 执行反汇编，查看 ``sub x5, x6, x7`` 这条汇编指令对应的机器指令的编码，并对照 RISC-V 的 specification 自己解析该条指令的编码。

```sh
$ make code

...
        sub x5, x6, x7          # x5 = x6 - x7
80000008:       407302b3                sub     t0,t1,t2
...

# 十六进制：0x 407302b3
# 二进制：0b 0100 0000 0111 0011 0000 0010 1011 0011
# opcode	[6:0] 		011 0011 (OP)
# funct7	[31:25] 	0100 000 
# funct3	[14:12] 	000
# rd		[11:7] 		0010 1 (x5)
# rs1		[19:15]		0011 0 (x6)
# rs2		[24:20]		0 0111 (x7)

# 参考 riscv-spec-20191213.pdf p130 'RV32I Base Instruction Set'
```



* 现知道某条 RISC-V 的机器指令在内存中的值为 ``b3 05 95 00`` ，从左往右为从低地址到高地址，单位为字节，请将其翻译为对应的汇编指令。

```sh
# 小端序 0x 00 95 05 b3
# 二进制 0b 0000 0000 1001 0101 0000 0101 1011 0011
# opcode	[6:0]		011 0011 (OP)
# funct7	[31:25]		0000 000
# funct3	[14:12]		000			==> ADD
# rd		[11:7]		0101 1 (x11)
# rs1		[19:15]		0101 0 (x10)
# rs2		[24:20]		0 1001 (x9)
# ==> add x11, x10, x9
```



## 练习5-2

* 有如下一段 C 语言程序代码，尝试用汇编代码达到等效的结果，并采用 gdb 调试查看执行结果。

```c
register int a, b, c, d, e;
b = 1;
c = 2;
e = 3;
a = b + c;
d = a - e;
```

```sh
# C code:
# register int a, b, c, d, e;
# b = 1;
# c = 2;
# e = 3;
# a = b + c;
# d = a - e;
# Description:
#	Use asm to do the same thing like C.

	.text			    # Define beginning of text section
	.global	_start		# Define entry _start

_start:
    # x3 store var a
    # x4 store var b
    # x5 store var c
    # x6 store var d
    # x7 store var e
    li x4, 1            # b = 1 
    li x5, 2            # c = 2
	li x7, 4		    # e = 3
	add x3, x4, x5	    # a = b + c
    sub x6, x3, x7      # d = a - e

stop:
	j stop			# Infinite loop to stop execution

	.end			# End of file

```

```sh
# 使用gdb调试，在原gdbinit文件中添加对x3和x4的监控
# display/z $x3
# display/z $x4

$ make debug-
...
Press Ctrl-C and then input 'quit' to exit GDB and QEMU
-------------------------------------------------------
Reading symbols from test.elf...
Breakpoint 1 at 0x80000000: file test.s, line 21.
0x00001000 in ?? ()
=> 0x00001000:  97 02 00 00     auipc   t0,0x0
1: /z $x3 = 0x00000000
2: /z $x4 = 0x00000000
3: /z $x5 = 0x00000000
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000000

Breakpoint 1, _start () at test.s:21
21          li x4, 1            # b = 1 
=> 0x80000000 <_start+0>:       13 02 10 00     li      tp,1
1: /z $x3 = 0x00000000
2: /z $x4 = 0x00000000
3: /z $x5 = 0x80000000
4: /z $x6 = 0x00000000
--Type <RET> for more, q to quit, c to continue without paging--
5: /z $x7 = 0x00000000
(gdb) si
22          li x5, 2            # c = 2
=> 0x80000004 <_start+4>:       93 02 20 00     li      t0,2
1: /z $x3 = 0x00000000
2: /z $x4 = 0x00000001
3: /z $x5 = 0x80000000
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000000
(gdb) si
23              li x7, 4                    # e = 3
=> 0x80000008 <_start+8>:       93 03 40 00     li      t2,4
1: /z $x3 = 0x00000000
2: /z $x4 = 0x00000001
3: /z $x5 = 0x00000002
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000000
(gdb) si
24              add x3, x4, x5      # a = b + c
=> 0x8000000c <_start+12>:      b3 01 52 00     add     gp,tp,t0
1: /z $x3 = 0x00000000
2: /z $x4 = 0x00000001
3: /z $x5 = 0x00000002
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000004
(gdb) si
25          sub x6, x3, x7      # d = a - e
=> 0x80000010 <_start+16>:      33 83 71 40     sub     t1,gp,t2
1: /z $x3 = 0x00000003
2: /z $x4 = 0x00000001
3: /z $x5 = 0x00000002
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000004
(gdb) si
stop () at test.s:28
28              j stop                  # Infinite loop to stop execution
=> 0x80000014 <stop+0>: 6f 00 00 00     j       0x80000014 <stop>
1: /z $x3 = 0x00000003
2: /z $x4 = 0x00000001
3: /z $x5 = 0x00000002
4: /z $x6 = 0xffffffff
5: /z $x7 = 0x00000004
(gdb) Quit

# Tips: -1在寄存器用0xffffffff表示（补码）
```



## 练习5-3

* 有如下一段 C 语言程序代码，尝试用汇编代码达到等效的结果，并采用 gdb 调试查看执行结果。

```c
register int a, b, c, d, e;
b = 1;
c = 2;
d = 3;
e = 4;
a = (b + c) - (d + e);
```

```sh
# C code:
# register int a, b, c, d, e;
# b = 1;
# c = 2;
# d = 3;
# e = 4;
# a = (b + c) - (d + e);
# Description:
#	Use asm to do the same thing like C.


	.text			    # Define beginning of text section
	.global	_start		# Define entry _start

_start:
    # x3 store var a
    # x4 store var b
    # x5 store var c
    # x6 store var d
    # x7 store var e
    li x4, 1            # b = 1 
    li x5, 2            # c = 2
    li x6, 3            # d = 3
	li x7, 4		    # e = 4
	add x3, x4, x5	    # a = b + c
    add x4, x6, x7      # b = d + e
    sub x3, x3, x4      # a = a - b = (b + c) - (d + e)

stop:
	j stop			# Infinite loop to stop execution

	.end			# End of file

```

```sh
$ make debug
...
(gdb) 
27          sub x3, x3, x4      # a = a - b = (b + c) - (d + e)
=> 0x80000018 <_start+24>:      b3 81 41 40     sub     gp,gp,tp
1: /z $x3 = 0x00000003
2: /z $x4 = 0x00000007
3: /z $x5 = 0x00000002
4: /z $x6 = 0x00000003
5: /z $x7 = 0x00000004
(gdb) 
stop () at test.s:30
30              j stop                  # Infinite loop to stop execution
=> 0x8000001c <stop+0>: 6f 00 00 00     j       0x8000001c <stop>
1: /z $x3 = 0xfffffffc
2: /z $x4 = 0x00000007
3: /z $x5 = 0x00000002
4: /z $x6 = 0x00000003
5: /z $x7 = 0x00000004
...
```



## 练习5-4

* 给定一个 32 位数 ``0x87654321`` ，先编写 C 程序，将低 16 位（``0x4321``）和高 16 位（``0x8765``）分离出来保存到独立的变量中，完成后再尝试采用汇编语言实现类似的效果。

```C
/* 
* Description:
*	Separate the high 16 bits and low 16 bits of 32-bit
* Example:
*   0x87654321
*   low:    0x4321
*   high:   0x8765
*/

void main()
{
    int a = 0x87654321;
    short al = a & 0x0000ffff;
    short ah = a >> 16;

    while (1)
        ;
}
```

```sh
# Description:
#	Separate the high 16 bits and low 16 bits of 32-bit
# Example:
#   0x87654321
#   low:    0x4321
#   high:   0x8765
#

    .text
    .global _start

_start:
    # x3 store 0x7654321
    # x4 store low
    # x5 store high
    li x3, 0x87654321
    li t1, 0xffff
    and x4, x3, t1
    srli x5, x3, 16

stop:
    j stop
    
    .end
```

```sh
# 部分调试结果
...
(gdb) 
22          j stop
=> 0x80000018 <stop+0>: 6f 00 00 00     j       0x80000018 <stop>
1: /z $x3 = 0x87654321
2: /z $x4 = 0x00004321
3: /z $x5 = 0x00008765
4: /z $x6 = 0x0000ffff
5: /z $x7 = 0x00000000
...
```



## 练习5-5

* 假设有如下一段 C 代码，尝试用汇编语句实现等效功能

```c
int array[2] = {0x11111111, 0xffffffff};
int i = array[0];
int j = array[1];
```

```sh
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
```

```sh
# 部分调试结果
...
(gdb) 
20          j stop
=> 0x80000010 <stop+0>: 6f 00 00 00     j       0x80000010 <stop>
   0x80000014 <_array+0>:       11 11   addi    sp,sp,-28
   0x80000016 <_array+2>:       11 11   addi    sp,sp,-28
   0x80000018 <_array+4>:       ff ff   0xffff
   0x8000001a <_array+6>:       ff ff   0xffff
1: /z $x3 = 0x80000014
2: /z $x4 = 0x11111111
3: /z $x5 = 0xffffffff
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000000
...
```



## 练习5-6

* 在内存中定义一个结构体变量，编写汇编程序，用宏方式（``.macro/.endm``）实现对结构体变量的成员赋值以及读取该结构体变量的成员的值到寄存器变量中。等价的 C 语言的示例代码如下：

```c
struct S {
    unsigned int a;
    unsigned int b;
};

struct S s = {0};

#define set_struct(s) \
    s.a = a; \
    s.b = b;

#define get_struct(s) \
    a = s.a; \
    b = s.b;

void foo()
{
    register unsigned int a = 0x12345678;
    register unsigned int b = 0x87654321;
    set_struct(s);
    a = 0;
    b = 0;
    get_struct(s);
}
```

```sh
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
```

```sh
# 部分調試結果
...
(gdb) 
59          j stop
=> 0x80000038 <stop+0>: 6f 00 00 00     j       0x80000038 <stop>
   0x8000003c <_struct_s+0>:    78 56   lw      a4,108(a2)
   0x8000003e <_struct_s+2>:    34 12   addi    a3,sp,296
   0x80000040 <_struct_s+4>:    21 43   li      t1,8
   0x80000042 <_struct_s+6>:    65 87   srai    a4,a4,0x19
1: /z $x3 = 0x12345678
2: /z $x4 = 0x87654321
3: /z $x5 = 0x8000003c
4: /z $x6 = 0x00000000
5: /z $x7 = 0x00000000
...
```



## 练习5-7

编写汇编指令，使用条件分支指令循环遍历一个字符串数组，获取该字符串的长度。等价 C 语言示例代码如下，供参考：

```C
char array[] = {'h', 'e', 'l', 'l', 'o', ',', 'w', 'o', 'r', 'l', 'd', '!', '\0'};
int len = 0;
while (arrar[len] != '\0') {
    len++;
}
```

```sh
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
```

```sh
# 部分调试结果
...
(gdb) 
26          j stop
=> 0x80000020 <stop+0>: 6f 00 00 00     j       0x80000020 <stop>
   0x80000024 <_array+0>:       68 65   flw     fa0,76(a0)
   0x80000026 <_array+2>:       6c 6c   flw     fa1,92(s0)
   0x80000028 <_array+4>:       6f 2c 77 6f     jal     s8,0x80072f1e
   0x8000002c <_array+8>:       72 6c   flw     fs8,28(sp)
   0x8000002e <_array+10>:      64 21   fld     fs1,192(a0)
   0x80000030 <_array+12>:      30 00   addi    a2,sp,8
1: /z $x3 = 0x8000002f
2: /z $x4 = 0x0000000b
3: /z $x5 = 0x00000030
4: /z $x6 = 0x00000030
5: /z $x7 = 0x00000000
...
```



## 练习5-8

要求：阅读``code/asm/cc_leaf`` 和 ``code/asm/cc_nested`` 的例子代码，理解 RISC-V 的函数调用约定。在此基础上编写汇编程序实现以下功能，等价的 C 语言的示例代码如下，供参考：

```c
unsigned int squre(unsigned int i)
{
    return i * i;
}

unsigned int sum_squres(unsigned int i)
{
    unsigned int sum = 0;
    for (int j = 0; j <= i; j++)
    {
        sum += squre(j);
    }
    return sum;
}

void _start()
{
    sum_squre(3);
}
```

```sh
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
    call sum_squre		# except a0 is 0 + 1 + 4 + 9 = 14

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
```

```sh
# 部分调试结果
...
(gdb) 
36          j stop
=> 0x80000010 <stop+0>: 6f 00 00 00     j       0x80000010 <stop>
1: /z $sp = 0x800000cc
2: /z $ra = 0x80000010
3: /z $a0 = 0x0000000e
4: /z $a1 = 0x87e00000
5: /z $s0 = 0x00000000
6: /z $s1 = 0x00000000
7: /z $s2 = 0x00000000
8: /z $s3 = 0x00000000
...
```



## 练习5-9

在 C 函数中嵌入一段汇编，实现 foo 函数中 ``c = a * a + b * b`` ，这句 C 语言的同等功能。

```c
int foo(int a, int b)
{
    int c;
    c = a * a + b * b;
    return c;
}
```

```sh
/*
* C code
* int foo(int a, int b)
* {
*     int c;
*     c = a * a + b * b;
*     return c;
* }
*/


int foo(int a, int b)
{
	int c;

	asm volatile (
        "mul %[add1], %[add1], %[add1]; mul %[add2], %[add2], %[add2];add %[sum], %[add1], %[add2]"
		:[sum]"=r"(c)
		:[add1]"r"(a), [add2]"r"(b)
	);

	return c;
}

```

```sh
# 部分调试结果
...
(gdb) 
15              j stop                  # Infinite loop to stop execution
=> 0x80000014 <stop+0>: 6f 00 00 00     j       0x80000014 <stop>
1: /z $sp = 0x8000004c
2: /z $ra = 0x80000014
3: /z $s0 = 0x00000000
4: /z $a0 = 0x0000000d
5: /z $a1 = 0x00000003
6: /z $a4 = 0x00000009
7: /z $a5 = 0x0000000d
...
```



