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