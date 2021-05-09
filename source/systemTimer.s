        .globl Sleep
Sleep:
        mov r0,#0x3F0000
wait$:
        sub r0,#1
        cmp r0,#0
        bne wait$

        mov pc,lr
