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

        # Load in the pattern
        ptrn .req r4
        ldr ptrn,=pattern
        ldr ptrn,[ptrn]
        seq .req r5
        mov seq,#0

loop$:
        # Set the pinVal to the pattern at seq
        pinVal .req r1
        mov pinVal,#1
        lsl pinVal,seq
        and pinVal,ptrn

        # seq += 1 (mod 32)
        add seq, seq, #1
        and seq, #0b11111


        # Set the pin
        pinNum .req r0
        mov pinNum,#16
        bl SetGpio
        .unreq pinNum
        .unreq pinVal

        # Sleep for about 0.25s
        mov r0,#250
        lsl r0,#10
        bl Sleep

        # Back to the start
        b loop$

.section .data
.align 2
pattern:
    .int 0b11111111101010100010001000101010
