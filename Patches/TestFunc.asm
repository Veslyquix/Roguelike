.thumb 

Vesly_StrTakerCheck: 
ldr r0, =VeslyHack_Link
ldr r0, [r0] 
mov r0, #0 
bx lr 
.ltorg 


.equ GetUnitByEventParameter, 0x0800BC51
.global TestFunc 
.type TestFunc, %function
TestFunc: 
push {r4-r7, lr} 
mov r0, #1 @ eirika 
blh GetUnitByEventParameter
bl GetUnitDebuffEntry 
mov r4, r0 
ldr r1, =DebuffStatBitOffset_Str
ldr r1, [r1] 
mov r0, r4 @ unit debuff entry ram 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r3, #4 
bl PackData_Signed

ldr r1, =DebuffStatBitOffset_Str
ldr r1, [r1] 
mov r0, r4 @ unit debuff entry ram 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r3, #2 
bl PackData_Signed

ldr r1, =DebuffStatBitOffset_Str
ldr r1, [r1] 
mov r0, r4 @ unit debuff entry ram 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
bl UnpackData_Signed 
mov r5, r0 

mov r11, r11 

pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 

