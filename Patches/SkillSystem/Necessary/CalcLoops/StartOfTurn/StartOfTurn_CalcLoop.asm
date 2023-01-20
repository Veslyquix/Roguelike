.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ ReturnAddress, 0x8015431
.equ BufferSize, 12 
.equ gAttackerSkillBuffer, 0x02026BB0
.equ gDefenderSkillBuffer, 0x02026C00
.equ gTempSkillBuffer, 0x02026B90
.equ gAuraSkillBuffer, 0x02027200
.equ gUnitRangeBuffer, 0x0202764C
.equ GetUnit, 0x8019430

.global StartOfTurn_CalcLoopHook // gets called twice on turn 2 of player phase for some reason 
.type StartOfTurn_CalcLoopHook, %function 
StartOfTurn_CalcLoopHook: 
cmp	r0,#1
beq	set0
mov	r0,#1
b	doneSet
set0:
mov	r0,#0
doneSet:
push	{r0} 


StartOfTurn_CalcLoop: 
push	{r4-r6, lr} 

ldr r4, =StartOfTurn_List
sub r4, #4 
Loop: 
add r4, #4 
ldr r3, [r4] 
cmp r3, #0 
beq Break 
mov r2, #1 
orr r3, r2 @ ensure the thumb bit is set 
mov lr, r3 
.short 0xF800 
b Loop 

Break: 
pop {r4-r6} 
pop {r1} @ lr (useless) 
pop	{r0} @ true or false 
ldr r1, =ReturnAddress 
bx r1 
.ltorg 

.type StartOfTurnUnitLoop, %function 
.global StartOfTurnUnitLoop 
StartOfTurnUnitLoop: 
push {r4-r7, lr} 
@ loop through units 
@ check for relevant skill(s) 
@ run a function for the skill 
mov r4, #0 
UnitLoop: 
add r4, #1 
cmp r4, #0xC0 
bge BreakLoop 
mov r0, r4 @ deployment id 
blh GetUnit 
mov r5, r0 @ unit 

ldr r0, [r0] 
cmp r0, #0 
beq UnitLoop 
ldrb r1, [r0, #4] @ unit id 
cmp r1, #0 
beq UnitLoop 
ldr r0, [r5, #0x0C] 
ldr r1, =0x1000C @ escaped, undeployed, dead 
tst r0, r1 
bne UnitLoop 
@bl IsUnitOnField @(Unit* unit)
@cmp r0, #0 
@beq UnitLoop 

mov r0, r5 @ unit 
ldr r1, =gAttackerSkillBuffer
bl MakeSkillBuffer @(Unit* unit, SkillBuffer* buffer)
mov r6, r0 @ skill buffer 
@ possibly need to remove duplicate skills here 
@ /*00*/  u8 lastUnitChecked;
@ /*01*/  u8 skills[11];
mov r7, #0 
BufferLoop: 
add r7, #1 
cmp r7, #BufferSize @ max size 
bgt UnitLoop 
ldrb r0, [r6, r7] 
cmp r0, #0 @ should not have any gaps 
beq UnitLoop 
ldr r3, =StartOfTurn_SkillTable
lsl r0, #2 @ 4 bytes per POIN 
add r3, r0 
ldr r0, [r3] @ specific entry 
cmp r0, #0 
beq BufferLoop @ do nothing if not a function 
mov lr, r0 
mov r0, r5 @ unit 
.short 0xF800 @ execute the function 
b BufferLoop 


BreakLoop: 


pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 




