.section .data
.align 4
.globl FrameBufferInfo
FrameBufferInfo:
.int 1024 /* #0 Physical Width */
.int 768 /* #4 Physical Height */
.int 1024 /* #8 Virtual Width */
.int 768 /* #12 Virtual Height */
.int 0 /* #16 GPU - Pitch */
.int 16 /* #20 Bit Depth */
.int 0 /* #24 X */
.int 0 /* #28 Y */
.int 0 /* #32 GPU - Pointer */
.int 0 /* #36 GPU - Size */

.section .text
.globl InitialiseFrameBuffer
InitialiseFrameBuffer:
        width .req r0
        height .req r1
        bitDepth .req r2

        /* Validate inputs */
        cmp width,#4096
        cmpls height,#4096
        cmpls bitDepth,#32
        movhi r0,#0
        movhi pc, lr

        /* Write inputs to frame buffer */
        /* N.B. We need to use r4 because r0-r3 can be overwritten */
        fbInfoAddr .req r4
        push {r4, lr}
        ldr fbInfoAddr,=FrameBufferInfo
        str width, [fbInfoAddr, #0]
        str height, [fbInfoAddr, #4]
        str width, [fbInfoAddr, #8]
        str height, [fbInfoAddr, #12]
        str bitDepth, [fbInfoAddr, #20]
        .unreq width
        .unreq height
        .unreq bitDepth

        /* Send address of frame buffer + 0x40000000 to the mailbox. */
        mov r0, fbInfoAddr
        add r0, #0x40000000
        mov r1, #1
        bl MailboxWrite

        /* Receive the reply from the mailbox. */
        mov r0, #1
        bl MailboxRead
        result .req r0

        /* If the reply is not 0, the method has failed. We should return 0 to indicate failure. */
        teq result, #0
        movne result,#0
        popne {pc}


        /* Return a pointer to the frame buffer info. */
        mov result,fbInfoAddr
        pop {r4, pc}
        .unreq result
        .unreq fbInfoAddr
