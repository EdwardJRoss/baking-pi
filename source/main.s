        .section .init
        .globl _start
_start:
        b main

.section .text
main:
        /* Move into the text section */
        mov sp,#0x8000

        /* Initialise OK LED */
        mov r0,#16
        mov r1,#1
        bl SetGpioFunction


        /* Initialise the frame buffer */
        mov r0,#1024
        mov r1,#768
        mov r2,#16
        bl InitialiseFrameBuffer

        /* Check for error */
        teq r0,#0
        bne noError$

        /* Turn on OK LED if Error */
        mov r0,#16
        mov r1,#0
        bl SetGpio

error$:
        b error$

noError$:
        /* The address of the Framebuffer is in r0
           Returned by InitialiseFrameBuffer.
           Store it as the Graphics Address */
        bl SetGraphicsAddress

        /* Initialise colour */
        mov r0,#0x10000
        sub r0,#1
        bl SetForeColour

        mov r0,#0
        mov r1,#70
        mov r2,#1024
        mov r3,#70
        bl DrawLine

        mov r0,#0
        mov r1,#30
        mov r2,#1024
        mov r3,#30
        bl DrawLine

        mov r0,#30
        mov r1,#0
        mov r2,#30
        mov r3,#768
        bl DrawLine

        mov r0,#70
        mov r1,#0
        mov r2,#70
        mov r3,#768
        bl DrawLine

        mov r0,#0x41
        mov r1,#50
        mov r2,#50
        bl DrawCharacter

        mov r0,#0x42
        mov r1,#58
        mov r2,#50
        bl DrawCharacter

        teq r0,#8
        bne render$

        /* Turn on OK LED when done */
        mov r0,#16
        mov r1,#0
        bl SetGpio

render$:
        b render$
