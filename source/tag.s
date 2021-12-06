/* Reading ARM Tag Information */
.section .data
tag_core: .int 0
tag_mem: .int 0
tag_videotext: .int 0
tag_ramdisk: .int 0
tag_initrd2: .int 0
tag_serial: .int 0
tag_revision: .int 0
tag_videolfb: .int 0
tag_cmdline: .int 0

.section text

/* Finds the Tag r0 (1-9) and returns the address of the data
   Caches the result in memory for future use.

Tags:
 1 - 'core'
 2 - 'mem'
 3 - 'videotext'
 4 - 'ramdisk'
 5 - 'initrd2'
 6 - 'serial'
 7 - 'revision'
 8 - 'videolfb'
 9 - 'cmdline'

   Returns 0 if tag is invalid
*/
        .globl FindTag
FindTag:
        tag .req r0
        tagCore .req r1

        sub tag, #1

        /* Check tag is valid */
        cmp tag, #8
        movhi 0, r0
        pophi lr

        /* Load from memory */
        ldr tagCore,=tag_core
        tagAddr .req r0
        add tagAddr, tagCore, tag, lsl #2
        .unreq tag
        /* If non-zero, return the value */
        cmp tagAddr, #0
        popne lr

        ldr r2, [tagCore]
        cmp r2, 0
        moveq r0, 0
        popeq lr

        push {lr, r4, r5, r6}
        mov r4, tagCore

        .unreq tagAddr
        .unreq r4
        tagCore .req r4
        tagAddr .req r5
        mov tagAddr, #0x100
tagLoop$:
        tagIndex .req r6
        ldrh tagIndex, [tagAddr, #4]
        cmp tagIndex, #0
        b
