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

        colour .req r4
        x .req r5
        y .req r6
        lastx .req r7
        lasty .req r8
        seed .req r9
        /* Initialise to 0 */
        mov colour,#0
        mov lastx,#0
        mov lasty,#0
        mov seed,#0
render$:
        /* Increment the colour */
        add colour,#1
        cmp colour,#0x10000
        movhs colour,#0
        mov r0, colour
        bl SetForeColour


        /* Generate random x and y */
        mov r0,seed
        bl Random
        mov x,r0

        bl Random
        mov y,r0
        mov seed,r0

        /* Shift x and y to valid range */
        lsr x,#22
        lsr y,#22
        /* If y not in 0-767 then try again */
        cmp y,#768
        bhs render$


        mov r0, lastx
        mov r1, lasty
        mov r2, x
        mov r3, y
        bl DrawLine

        mov lastx, x
        mov lasty, y


        b render$

    .unreq x
    .unreq y
    .unreq colour
    .unreq lastx
    .unreq lasty
    .unreq seed
