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

        # Store adress of GPIO 16 in r1
        mov r1,#1
        lsl r1,#16
loop$:
        # Turn off pin (i.e. turn light on)
        str r1,[r0,#40]

        # Wait a little while
        mov r2,#0x3F0000
wait1$:
        sub r2,#1
        cmp r2,#0
        bne wait1$

        # Turn on pin (i.e. turn light off)
        str r1,[r0,#28]

        # Wait a little while
        mov r2,#0x3F0000
wait2$:
        sub r2,#1
        cmp r2,#0
        bne wait2$

        # Back to the start
        b loop$
