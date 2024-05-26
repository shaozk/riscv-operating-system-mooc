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
