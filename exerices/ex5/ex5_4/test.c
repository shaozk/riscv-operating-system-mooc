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