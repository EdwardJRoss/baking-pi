        .globl Sleep
# Sleep for a time between 0 and 2^31-1 microseconds
#  r0: Time to sleep in microseconds
Sleep:
        sleepTime .req r0

        # Check sleep time is below 2^31
        cmp sleepTime,#0x80000000
        movhi pc,lr

        timerAddr .req r1
        ldr r1,=0x20003000

        ldrd r2,r3,[timerAddr,#4]
        add sleepTime, r2
        .unreq sleepTime
        endTime .req r0

wait$:
        ldrd r2,r3,[timerAddr,#4]
        sub r2,endTime
        # Interpret the first bit as a sign
        # This gives us plenty of time to check the condition
        cmp r2,#0x80000000
        bhi wait$
        .unreq timeraddr
        .unreq endTime

        mov pc,lr
