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
