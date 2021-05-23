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
/* Set the Pixel as (x,y)=(r0, r1) to foreColour at graphicsAddress.
Returns: Input coordinates (x,y)
 */
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
        mla r3, y, width, x
        .unreq width
        .unreq x
        .unreq y
        /* addr <- 2*(x + width * y) */
        add addr, r3, lsl #1

/* Load in the forecolour */
        colour .req r3
        ldr colour,=foreColour
        ldrh colour,[colour]

/* Set the pixel at (x,y) to Forecolour */
        strh colour,[addr]
        .unreq colour
        .unreq addr

        mov pc,lr

.globl DrawLine
/* Draw a line from (x0, y0) to (x1, y1)
   Uses Brenesham's Algorithm */
DrawLine:
        x0 .req r0
        y0 .req r1

        push {r4, r5, r6, r7, r8, r9, r10, lr}

        x1 .req r9
        y1 .req r10
        mov x1,r2
        mov y1,r3


        dx .req r4
        ndy .req r5
        sx .req r6
        sy .req r7
        error .req r8

        /* Initialise the direction of x */
        cmp x1,x0
        subgt dx, x1, x0
        movgt sx,#1
        suble dx, x0, x1
        movle sx,#-1

        /* Initialise the direction of y.
           Use negative dy for convenience. */
        cmp y1,y0
        subgt ndy, y0, y1
        movgt sy,#1
        suble ndy, y1,y0
        movle sy,#-1

        add error, dx, ndy

        add x1, sx
        add y1, sy

        /* Main loop */
lineLoop$:
        /* When we've reached the end then return */
        teq x0, x1
        teqne y0, y1
        popeq {r4, r5, r6, r7, r8, r9, r10, pc}

        /* Note: Since DrawPixel retuns its inputs x0 and y0 are preserved */
        bl DrawPixel

        cmp ndy, error, lsl #1
        addle x0, sx
        addle error, ndy

        cmp dx, error, lsl #1
        addge y0, sy
        addge error, dx

        b lineLoop$

        .unreq x0
        .unreq x1
        .unreq y0
        .unreq y1
        .unreq sx
        .unreq sy
        .unreq dx
        .unreq ndy
        .unreq error
