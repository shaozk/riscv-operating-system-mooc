# 第3章 编译与链接

## 练习3-1 

* 编写一个简答的打印“hello world!”的程序文件：```hello.c```

```c
#include <stdio.h>

int main()
{
    printf("hello world!\n");
    return 0;
}
```

* 对源文件进行本地编译，生成针对支持 x86_64 指令集架构处理器的目标文件```hello.o```

```shell
$ gcc -c hello.c -o hello.o

# -c: 编译或汇编源文件（不链接）并生成目标文件
# -o: 指定生成目标文件名
```

* 查看```hello.o```的文件的文件头信息

```sh
$ readelf -h hello.o	

# -h: --file-header 显示包含在ELF文件头中的信息
```

	* 查看```hello.o```的Section header table

```sh
$ readelf -SW hello.o

# -S: --sections --section-headers 显示包含在ELF文件Section头中的信息
# -W: --wide 不换行显示
```

* 对```hello.o```反汇编，并查看```hello.c```的C程序源码指令的对应关系

```sh
$ objdump -S hello.o

# -S: --source 显示反汇编后的源代码
```



## 练习3-2

请问编译为```.o```文件后```global_init, global_const, static_var, static_var_uninit, auto_var```这些变量分别存在哪些 section 里，```"hello world\n"```这个字符串又在哪里？并尝试用工具查看并验证的猜测。

```sh
global_init			# 已初始化全局变量 .data
global_const		# 已初始化全局常量 .rodata
static_var			# 已初始化静态局部变量 .data
static_var_uninit	# 未初始化静态局部变量 .bss
auto_var			# 局部变量 不在section中

# .rodata 	只读数据，如printf语句中的格式串和switch语句的跳转表
# .data		已初始化的全局和静态C变量（局部C变量在运行时保存在栈中）
# .bss		未初始化全局和静态C变量，以及所有被初始化为0的全局或静态变量
# 参考：CSAPP 第7章 链接
```

```sh
# 验证
$ readelf -SW example.o
$ 
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  ...
  [ 3] .data             PROGBITS        0000000000000000 000064 000008 00  WA  0   0  4
  [ 4] .bss              NOBITS          0000000000000000 00006c 000004 00  WA  0   0  4
  [ 5] .rodata           PROGBITS        0000000000000000 00006c 000011 00   A  0   0  4
  ...
# 得到section索引
# .data		--> 3
# .bss		--> 4
# .rodata	-->	5

$ readelf -s example.o
$ 
   Num:    Value          Size Type    Bind   Vis      Ndx Name
	...
     6: 0000000000000000     4 OBJECT  LOCAL  DEFAULT    4 stattic_var_uninit.2318
     7: 0000000000000004     4 OBJECT  LOCAL  DEFAULT    3 static_var.2317
	...
    12: 0000000000000000     4 OBJECT  GLOBAL DEFAULT    3 global_init
    13: 0000000000000000     4 OBJECT  GLOBAL DEFAULT    5 global_const
	...
# 得到symbol所在section
# .static_var_uninit	--> 4 --> .bss
# .static_var			--> 3 --> .data
# .global_init			--> 3 --> .data
# .global_const			--> 5 --> .rodata
# 无auto_var变量信息

# Tips:只截取重要section信息
```





