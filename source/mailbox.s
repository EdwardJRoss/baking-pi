        .globl GetMailboxBase
GetMailboxBase:
        ldr r0,=0x2000B880
        mov pc,lr

        .global MailboxWrite

/*
* Write a message to the specified mailbox
* r0: The message to write (28 bits ending in 4 zeros)
* r1: The channel to write to 0-7
*/
MailboxWrite:
        message .req r0
        channel .req r1

        /* Check 4 lowest bits are 0 */
        tst message, #0b1111
        movne pc, lr

        /* Check channel is valid: 0-7 */
        cmp channel,#8
        movhi pc, lr

        mov r2, message
        .unreq message
        message .req r2

        /* Get base mailbox address */
        push {lr}
        bl GetMailboxBase
        mailbox .req r0

        /* Wait until top (31st) status bit of mailbox is 0 */
awaitMailbox$:
        status .req r3
        ldr status, [mailbox, #0x18]
        /* 0x8 = 0b1000; 1 in highest bit */
        tst status, #0x80000000
        .unreq status
        bne awaitMailbox$

        add message, channel
        .unreq channel

        str message, [mailbox, #0x20]
        .unreq message
        .unreq mailbox

        pop {pc}


        .globl MailboxRead
/* Read from mailbox; r0 is channel */
MailboxRead:
        channel .req r0

        /* Check channel is valid */
        cmp channel,#7
        movhi pc, lr

        mov r1, channel
        .unreq channel
        channel .req r1

        /* Get base mailbox address */
        push {lr}
        bl GetMailboxBase
        mailbox .req r0

        /* Wait until 30th bit of mailbox is 0 */
rightmail$:
        status .req r3
        ldr status, [mailbox, #0x18]
        /* 0x4 = 0b0100; 1 in highest bit */
        tst status, #0x40000000
        .unreq status
        bne rightmail$

        /* Read the message */
        mail .req r2
        readChannel .req r3
        ldr mail, [mailbox, #0]
        /* Bottom 4 bits are channel */
        and readChannel, mail, #0xF
        .unreq mailbox

        /* Check the channel is right, else read again */
        teq readChannel, channel
        bne rightmail$
        .unreq readChannel
        .unreq channel

        /* Return the mail */
        and r0, mail, #0xFFFFFFF0
        .unreq mail
        pop {pc}
