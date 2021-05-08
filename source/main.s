        .section .init
        .globl _start
_start:

        # Store address of GPIO Controller
        ldr r0,=0x20200000

        # Enable output on 16th GPIO Pin
        # In 6th set of 3 bits (6*3=18)
        mov r1,#1
        lsl r1,#18
        str r1,[r0,#4]

        # Turn off GPIO Pin 16
        mov r1,#1
        lsl r1,#16
        str r1,[r0,#40]

loop$:
        b loop$
