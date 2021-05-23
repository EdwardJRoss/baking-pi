.globl Random
/* Generate a Random Number using Quadratic Congruence Generator
     x_{n+1} = a * x_{n}^2 + b * x_{n} + c     mod 2^{32}
    Where:
        1. a is even
        2. b = a + 1 mod 4
        3. c is odd

    This uses a = 0xEF00, b = 1, c = 73.

Arguments:
     - r0: The current seed x_{n}

Returns:
     - r0: The next random number x_{n+1}
        */

Random:
xn .req r0

/* Calculate (a * x_{n} + b) * x_{n} */
mov r1, #0xEF00
mul r1, xn
add r1, #1
mul r1, xn
/* Add c */
add r0,r1,#73
.unreq xn
mov pc,lr
