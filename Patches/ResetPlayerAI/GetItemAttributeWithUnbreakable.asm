.thumb 
lsl r1, #2 
ldr r0, =0x8017580 
ldr r0, [r0] 
add r1, r0 
ldr r0, [r1, #8] 
mov r1, #8 
orr r0, r1 
bx lr 
.ltorg 
