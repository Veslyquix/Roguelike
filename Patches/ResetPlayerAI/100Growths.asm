.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ BWL_AddBattle, 0x80A44C8
.equ Atkr, 0x203A4EC
.equ Dfdr, 0x203A56C
push {lr} 
mov r0, r6 
blh BWL_AddBattle 
mov r0, r7 
blh BWL_AddBattle 
ldr r3, =Atkr 
ldrb r0, [r3, #8] @ lvl 
mov r1, #0x70 
add r1, r3 
ldrb r1, [r1] 
cmp r0, r1 
ble TryDfdr @ for promotions you'll have a lower or equal level 
mov r2, #0x73 
add r3, r2 
mov r0, #1 
strb r0, [r3] 
strb r0, [r3, #1] 
strb r0, [r3, #2] 
strb r0, [r3, #3] 
strb r0, [r3, #4] 
strb r0, [r3, #5] 
strb r0, [r3, #6] 
strb r0, [r3, #7] @ con change / mag change with skillsys  

TryDfdr: 
ldr r3, =Dfdr  
ldrb r0, [r3, #8] @ lvl 
mov r1, #0x70 
add r1, r3 
ldrb r1, [r1] 
cmp r0, r1 
ble Exit @ for promotions you'll have a lower or equal level 
mov r2, #0x73 
add r3, r2 
mov r0, #1 
strb r0, [r3] 
strb r0, [r3, #1] 
strb r0, [r3, #2] 
strb r0, [r3, #3] 
strb r0, [r3, #4] 
strb r0, [r3, #5] 
strb r0, [r3, #6] 
strb r0, [r3, #7] @ con change / mag change with skillsys  
Exit: 
pop {r0} 
bx r0 
.ltorg 










