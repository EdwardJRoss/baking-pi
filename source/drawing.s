.section .data
.align 1
/* Colour to use for drawing */
foreColour:
.hword 0xFFFF

.align 2
/* Address to Draw to */
graphicsAddress:
.int 0

.section .text
.globl SetForeColour
/* Set the foreground colour to r0 */
SetForeColour:
/* Check valid colour (High Colour: 16 bits) */
cmp r0,#0x10000
movhs pc,lr
/* Store the foreground colour */
ldr r1,=foreColour
strh r0,[r1]
mov pc,lr

.globl SetGraphicsAddress
/* Set the Graphics Address to r0 */
SetGraphicsAddress:
ldr r1,=graphicsAddress
str r0,[r1]
mov pc,lr

.globl DrawPixel
/* Set the Pixel as (x,y)=(r0, r1) to foreColour at graphicsAddress */
DrawPixel:
        x .req r0
        y .req r1
/* Load the Graphics Address */
        addr .req r2
        ldr addr,=graphicsAddress
        ldr addr,[addr]
        /* TODO: Should we do something if not initialised? */

/* Validate y is less than height*/
        height .req r3
        /* TODO: Should this be the virtual height??*/
        ldr height,[addr,#4]
        sub height,#1
        cmp y,height
        movhi pc,lr
        .unreq height

/* Validate x is less than width*/
        width .req r3
        ldr width,[addr,#0]
        sub width,#1
        cmp x,width
        movhi pc,lr

        add width, #1

        /* Get address of (x,y) pixel */
        /* First load in pointer to screen */
        ldr addr, [addr, #32]
        /* Assume high colour */
        /* address = baseAddress + 2 * (x + width * y) */
        /* x <- x + width * y */
        mla x, y, width, x
        .unreq y
        .unreq width
        /* addr <- 2*(x + width * y) */
        add addr, x, lsl #1
        .unreq x

/* Load in the forecolour */
        colour .req r0
        ldr colour,=foreColour
        ldrh colour,[colour]

/* Set the pixel at (x,y) to Forecolour */
        strh colour,[addr]
        .unreq colour
        .unreq addr

        mov pc,lr
