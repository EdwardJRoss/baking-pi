.section .data
.align 1
/* Colour to use for drawing */
foreColour:
.hword 0xFFFF

.align 2
/* Address to Draw to */
graphicsAddress:
.int 0

/* Fonts */
.align 4
font:
.incbin "font.bin"

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

/* DrawCharacter draws a character at x,y
     - r0 : ASCII character to draw (0-127)
     - r1 : x co-ordinate to draw at
     - r2 : y co-ordinate to draw at
*/
.globl DrawCharacter
DrawCharacter:
        char .req r0

        /* Validate character */
        cmp char,#128
        movhs pc,lr

        push {r4, r5, lr}

        /* Get character address */
        addr .req r4
        ldr addr,=font
        /* Each chacacter is 16=2^4 bytes */
        add addr, char, lsl #4
        .unreq char

        x .req r0
        y .req r1
        mov x, r1
        mov y, r2


        bits .req r5

        /* Loop through the rows and DrawPixel */
rowChar$:
        ldr bits, [addr]
        and bits, #0xFF
        orr bits, #0x1000

colChar$:
        tst bits, #1
        /* We could optimise a lot more by inlining DrawPixel */
        blne DrawPixel

        lsr bits, #1
        add x, #1
        teq bits, #0x10
        bne colChar$

        sub x, #8
        add y, #1
        add addr, #1
        /* Since font address is 4 bit aligned initially ends with 0000
           Know we have gone through every bit when ends with 1111
        */
        tst addr, #0b1111
        bne rowChar$

        .unreq addr
        .unreq bits
        .unreq x
        .unreq y

        mov r0,#8
        mov r1,#16

        pop {r4, r5, pc}


.globl DrawString

/* Draws a string of characters from memory
     r0 - address of string
     r1 - length of string
     x  - x coordinate to draw to
     y - y coordinate to draw to
*/
DrawString:
        push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}

        x .req r4
        y .req r5
        addr .req r6
        pos .req r7
        x0 .req r8
        length .req r9

        mov addr, r0
        mov length, r1
        mov x, r2
        mov y, r3
        mov x0, x

        mov pos, #0
eachChar$:
        char .req r10

        ldrb char, [addr]

        mov r0, char
        mov r1, x
        mov r2, y
        bl DrawCharacter

        cwidth .req r0
        cheight .req r1

        /* Linefeed */
        cmp char, #0x0a
        moveq x, x0
        addeq y, cheight
        beq endChar$
        .unreq cheight

        /* Horizontal Tab */
        cmp char, #0x09
        addeq cwidth, cwidth, lsl #2
        moveq r1, x0
        beq tabLoop$

        add x, cwidth
        b endChar$

tabLoop$:
        cmp r1, x
        movhi x, r1
        bhi endChar$
        add r1, cwidth
        b tabLoop$

        .unreq cwidth

endChar$:
        add pos,#1
        add addr,#1
        cmp pos, length
        bls eachChar$

        .unreq length
        .unreq pos
        .unreq x0
        .unreq x
        .unreq y
        .unreq addr
        .unreq char

        pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
