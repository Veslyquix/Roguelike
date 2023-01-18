
.thumb 

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
@ After defeating an enemy, gain +X Str. 
@ Config for amount and whether to be stackable or not. 
.global Moxie 
.type Moxie, %function 
Moxie: 
push {r7, lr} 


bl PostBattleFunc 
cmp r0, #0 
beq End 

@check if killed enemy
ldrb	r0, [r5,#0x13]	@currhp
cmp	r0, #0
bne	End

mov r0, r4 
bl GetUnitDebuffEntry 
mov r7, r0 

bl VeslyBoostCheck 
cmp r0, #0 
bne Moxie_True 

mov r0, r4 
ldr r1, =MoxieID 
lsl r1, #24 
lsr r1, #24 
bl SkillTester 
cmp r0, #0 
bne Moxie_True 
b End 

Moxie_True: 

mov r0, #0 
ldr r1, =BuffsStackable_Link
ldr r1, [r1] 
cmp r1, #1 
bne OverwriteAmount_Str


ldr r1, =DebuffStatBitOffset_Str
ldr r1, [r1] 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r0, r7 
bl UnpackData_Signed
OverwriteAmount_Str: 

ldr r3, =MoxieBuffAmount
ldr r3, [r3] 
add r3, r0 
ldr r1, =DebuffStatBitOffset_Str
ldr r1, [r1] 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r0, r7 @ debuff entry 
bl PackData_Signed 



@ bitfield of stats to raise 


End: 
pop {r7} 
pop {r0} 
bx r0 
.ltorg 

VeslyBoostCheck: 
ldr r0, =VeslyHack_Link
ldr r0, [r0] 
mov r0, #0 
bx lr 
.ltorg 


PostBattleFunc: @ all the post battle functions seem to do this 
@ idk why we don't just put this at the start of the loop *shrugs* 
@check if dead
ldrb	r0, [r4,#0x13]
cmp	r0, #0x00
beq	RetFalse

@check if attacked this turn
ldrb 	r0, [r6,#0x11]	@action taken this turn
cmp	r0, #0x2 @attack
bne	RetFalse
ldrb 	r0, [r6,#0x0C]	@allegiance byte of the current character taking action
ldrb	r1, [r4,#0x0B]	@allegiance byte of the character we are checking
cmp	r0, r1		@check if same character
bne	RetFalse 
mov r0, #1 
b Exit 
RetFalse: 
mov r0, #0 
Exit: 
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

