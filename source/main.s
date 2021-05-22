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
        fbInfoAddr .req r4
        mov fbInfoAddr,r0

        /* Draw to the screen */
render$:
        fbAddr .req r3
        ldr fbAddr,[fbInfoAddr,#32]

        /* Arbitrary colour */
        colour .req r0
        y .req r1
        /* We could read this in from the framebuffer info ...*/
        mov y,#768
        drawRow$:
            x .req r2
            /* We could read this in from the framebuffer info ...*/
            mov x, #1024
            drawPixel$:
                strh colour,[fbAddr]
                add fbAddr,#2
                sub x,#1
                teq x,#0
                bne drawPixel$

            sub y,#1
            add colour,#1
            teq y,#0
            bne drawRow$

        b render$

    .unreq fbAddr
    .unreq fbInfoAddr
