# 第4章 嵌入式开发介绍

## 准备工作

[安装GCC和QEMU](../../howto-run-with-ubuntu1804_zh.md)



## 练习4-1 

* 编写一个简单的打印 “hello world!” 的程序源文件：```hello.c```

```c
#include <stdio.h>

int main()
{
    printf("hello world!\n");
    return 0;
}
```

* 对源文件进行编译，生成针对支持 **rv32ima** 指令集架构处理器的目标文件```hello.o```

```sh
$ riscv64-unknown-elf-gcc -march=rv32ima -mabi=ilp32 hello.c -c -o hello.o

# -march 指定生成目标文件的系统架构
# -mabi 指定生成基本类型数据位长度，"ilp32": 整形、长整形和指针都为32位
```

* 查看``hello.o``的文件的文件头信息

```sh
$ riscv64-unknown-elf-readelf -h hello.o
```

* 查看``hello.o``的 Section header data

```sh
$ riscv64-unknown-elf-readelf -S hello.o
```

* 对``hello.o``反汇编，并查看``hello.c``的 C 程序源码和机器指令的对应关系

```sh
$ riscv64-unknown-elf-objdump -S hello.o
```



## 练习4-2

* 将``hello.c``编译成可调式版本的可执行程序``a.out``

```sh
$ riscv64-unknown-elf-gcc hello.c -march=rv32ima -mabi=ilp32 -g -o a.out

# -g 生成调试信息
```

* 先执行``qemu-riscv32``运行``a.out``

```sh
$ qemu-riscv32 a.out 
```

* 使用``qemu-riscv32``和 gdb 调试``a.out``

```sh
$ qemu-riscv32 -g 1234 a.out

# -g port 等待GDB连接端口
```

```sh
# 启动另一个终端
$ riscv64-unknown-elf-gdb a.out
...
(gdb) target remote localhost:1234

# target remote 远程调试程序
```



## 练习4-3

* 理解执行根目录的make会发生什么

```makefile
# 设置变量SECTIONS为目录: code/asm 和 code/os 
SECTIONS = \
	code/asm \
	code/os \

# 设置默认目标为: all (在命令行中未指定目标，构建该目标)
.DEFAULT_GOAL := all

# 目标all构建规则
# 1 遍历变量SECTIONS所指定的目录
# 2 执行 make -C <dir> 命令
# 3 如果make命令执行失败，将执exit命令退出，并返回错误码
all :
	@echo "begin compile ALL exercises for assembly samples ......................."
	for dir in $(SECTIONS); do $(MAKE) -C $$dir || exit "$$?"; done
	@echo "compile ALL exercises finished successfully! ......"

# 伪造目标 clean
.PHONY : clean

# 目标clean构建规则
# 1 遍历变量SECTIONS所指定的目录
# 2 执行 make -C <dir> clean 命令
# 3 如果make命令执行失败，将执exit命令退出，并返回错误码
clean:
	for dir in $(SECTIONS); do $(MAKE) -C $$dir clean || exit "$$?"; done

# 伪造目标 slides
.PHONY : slides

# 目标slides构建规则
# 1 删除slides/文件夹下所有pdf文件
# 2 将PPT转化为PDF
slides:
	rm -f ./slides/*.pdf
	soffice --headless --convert-to pdf:writer_pdf_Export --outdir ./slides ./docs/ppts/*.pptx


# .DEFAULT_GOAL 	默认目标预设变量
# .PHONY			伪造目标
# ${MAKE}			命令行中的make
# @echo 			打印字符串，并且不会显示echo这条命令，只会显示后面要输出的内容
```



