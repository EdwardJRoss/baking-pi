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

        /* Draw to the screen */
        colour .req r4
        mov colour,#0
render$:

        y .req r5
        /* We could read this in from the framebuffer info ...*/
        mov y,#768
        drawRow$:
            add colour,#1
            mov r0, colour
            cmp r0,#0x10000
            movhs r0,#0
            bl SetForeColour


            /* Draw a slightly sloped line */
            mov r0,#0
            mov r1,y
            mov r2,#1024
            sub r3,y,#50
            bl DrawLine




            sub y,#1
            teq y,#0
            bne drawRow$

        b render$

    .unreq y
    .unreq colour
