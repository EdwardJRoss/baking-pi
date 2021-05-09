        .section .init
        .globl _start
_start:
        b main

.section .text
main:
        # Move into the text section
        mov sp,#0x8000

        pinNum .req r0
        pinFunc .req r1
        mov pinNum,#16
        mov pinFunc,#1
        bl SetGpioFunction
        .unreq pinNum
        .unreq pinFunc

loop$:
        # Turn off pin (i.e. turn light on)
        pinNum .req r0
        pinVal .req r1
        mov pinNum,#16
        mov pinVal,#0
        bl SetGpio
        .unreq pinNum
        .unreq pinVal


        # Sleep for about 0.5s
        # 5e5 = 5e3 * 1000 ~ 500 * 2^10
        mov r0,#500
        lsl r0,#10
        bl Sleep

        # Turn on pin (i.e. turn light off)
        pinNum .req r0
        pinVal .req r1
        mov pinNum,#16
        mov pinVal,#1
        bl SetGpio
        .unreq pinNum
        .unreq pinVal

        mov r0,#500
        lsl r0,#10
        bl Sleep

        # Back to the start
        b loop$
