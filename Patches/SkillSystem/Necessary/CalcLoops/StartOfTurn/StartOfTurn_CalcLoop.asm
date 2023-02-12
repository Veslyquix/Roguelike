.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ BufferSize, 12 
.equ gAttackerSkillBuffer, 0x02026BB0
.equ gDefenderSkillBuffer, 0x02026C00
.equ gTempSkillBuffer, 0x02026B90
.equ gAuraSkillBuffer, 0x02027200
.equ gUnitRangeBuffer, 0x0202764C
.equ GetUnit, 0x8019430
.equ ChapterData, 0x202BCF0 
.equ Delete6C, 0x8002D6C 
.equ AiData, 0x203AA04
.equ ProcStartBlocking, 0x8002CE0 
.equ ProcStart, 0x8002C7C
.equ ProcBreakLoop, 0x8002E94 
.equ ActionData, 0x203A958 
.equ ChapterData, 0x202BCF0 
.equ Delete6C, 0x8002D6C 
.equ GetPhaseAbleUnitCount, 0x8024CEC 
.equ NextRN_N, 0x8000C80 

.global StartOfTurnCalcLoop_Init 
.type StartOfTurnCalcLoop_Init, %function 
StartOfTurnCalcLoop_Init: 
push {r4, lr} 
mov r4, r0 
add r0, #0x2C @ counter 
mov r1, #0 
str r1, [r0]
add r0, #4 
str r1, [r0] @ exit 

ldr r0, =ChapterData 
ldrb r0, [r0, #0xF] 
@ next phase 
@ 0x80 was 0 
@ 0x40 was 0x80 
@ 0 was 0x40 
cmp r0, #0 
beq EndOfNPC 
cmp r0, #0x40 
beq EndOfEnemy 
cmp r0, #0x80 
beq EndOfPlayer 

EndOfNPC: 
mov r1, #0x40 @ npc 
str r1, [r4, #0x34] 
b CheckIfPhaseExists 
EndOfEnemy: 
mov r1, #0x80 @ enemy 
str r1, [r4, #0x34] 
b CheckIfPhaseExists 
EndOfPlayer: 
mov r1, #0x0 @ player  
str r1, [r4, #0x34] 
b CheckIfPhaseExists 


CheckIfPhaseExists: @ r0 as ChData+0xF 
blh GetPhaseAbleUnitCount 
cmp r0, #0 
bne ContinueProc 
mov r0, r4 
add r0, #0x30 
mov r1, #1 
str r1, [r0] @ skip loop 
@b ExitThisProc 
ContinueProc: 

ExitThisProc: 
pop {r4} 
pop {r0} 
bx r0 
.ltorg 

.global StartOfTurnCalcLoop_Main
.type StartOfTurnCalcLoop_Main, %function 
StartOfTurnCalcLoop_Main: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 
add r0, #0x2C @ counter 
ldr r1, [r0] 
ldr r2, [r0, #4] @ destructor if phase is to be skipped over 
cmp r2, #0 
bne GotoBreakProcLoop 


add r1, #1 
str r1, [r0] 
sub r1, #1 @ current one to care about 
ldr r3, =StartOfTurnCalcLoop 
lsl r1, #2 @ 4 bytes per entry 
ldr r5, [r3, r1] 
cmp r5, #0 
bne RunFunc 

GotoBreakProcLoop: 
mov r0, r4 
blh ProcBreakLoop 
b ExitLoop 

RunFunc: 
ldr r0, =StartOfTurnCalcLoop_SomeFunctionProc
mov r1, r4 @ parent proc 
blh ProcStartBlocking 
add r0, #0x2C 
str r5, [r0] 
ldr r1, [r4, #0x34] @ end of which phase? 
str r1, [r0, #8] @ end of which phase? 

ExitLoop: 

pop {r4-r7} 
pop {r1} 
bx r1 
.ltorg 

.global StartOfTurnCalcLoop_SomeFunction
.type StartOfTurnCalcLoop_SomeFunction, %function 
StartOfTurnCalcLoop_SomeFunction: 
push {r4, lr}
mov r4, r0 
mov r1, #0
str r1, [r4, #0x38] @ init some variable 

OptionalLoop:  
mov r1, #0x2C 
add r1, r4 
ldr r2, [r1] 
mov r3, #0 
str r3, [r1] 
cmp r2, #0 
beq BreakSomeFunc 
mov lr, r2
.short 0xf800 
@ run whatever function was in proc + 0x2c 
@ r0 = parent proc 
@ child function should call a blocking proc if desired ? 
@ if not, return 0 in r0 
cmp r0, #0 
beq OptionalLoop 
b ExitSomeFunc 
BreakSomeFunc: 
mov r0, r4 
blh ProcBreakLoop 


ExitSomeFunc: 

pop {r4} 
pop {r0} 
bx r0 
.ltorg 

	.equ EnsureCameraOntoPosition,0x08015e0d
.equ ProcFind, 0x8002E9C
.equ ProcGoto, 0x8002F24 

.global CallRallyChaosProc
.type CallRallyChaosProc, %function 
CallRallyChaosProc: 
push {lr} 
mov r1, r0 @ to block 
ldr r0, =RallyChaosProc
blh ProcStartBlocking 
mov r0, #1 @ has blocking proc 
pop {r1} 
bx r1 
.ltorg 


.global RallyChaosIdle
.type RallyChaosIdle, %function 
RallyChaosIdle: 
push {r4, lr} 
mov r4, r0 @ parent proc 
ldr r0, [r4, #0x30] 
cmp r0, #0 
bne Destruct 
bl FindMapAuraProc
cmp r0, #0 
bne ContinueIdle 
mov r0, r4 @ proc 
mov r1, #0 @ wait for rally anim 
blh ProcGoto 
@ProcGoto((Proc*)proc,1);
b ContinueIdle 
Destruct: 
mov r0, r4 @ proc 
mov r1, #1 @ label 
blh ProcGoto 

ContinueIdle:
pop {r4}  
pop {r0} 
bx r0 
.ltorg 

.global RallyChaosInit
.type RallyChaosInit, %function 
RallyChaosInit: 
mov r1, #0 
str r1, [r0, #0x2C] @ unit deployment byte 
str r1, [r0, #0x30] @ destructor = false 
bx lr 
.ltorg 


.global RallyChaosFunc
.type RallyChaosFunc, %function 
RallyChaosFunc: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 


ldr r3, =ChapterData 
ldrb r0, [r3, #0xF] @ phase 
mov r5, r0 @ starting unit deployment id 
mov r6, #0x40 @ ending point 
add r6, r5 @ only one allegiance 
ldr r1, [r4, #0x2C] @ stopping point 
add r5, r1 @ where to start our loop 

cmp r0, #0 
beq RallyChaos_Loop 
sub r5, #1 @ so we start at 0x40 / 0x80 while players start at 0x1 

RallyChaos_Loop: 
add r5, #1 
cmp r5, r6 
bge Break_RallyChaos 
mov r0, r5 
blh GetUnit 
mov r7, r0 @ unit 
bl IsUnitOnField 
cmp r0, #0 
beq RallyChaos_Loop 
mov r0, r7 @ unit 
ldr r1, =RallyChaosID_Link 
ldr r1, [r1] 
bl SkillTester 
cmp r0, #0 
beq RallyChaos_Loop 

mov r0, #8 
blh NextRN_N
mov r1, #1 
lsl r1, r0 @ some random rally bit to set  

mov r0, r7
bl RallyCommandEffect_NoneActive
@bl StartBuffFx
@ now wait for rally before continuing the loop 
@bl RallyCommandEffect_NoneActive @ r0 = unit, r1 = rally bits 
@b RallyChaos_Loop 
str r5, [r4, #0x2C] @ where to continue our loop after the rally anim is done 
b Exit_RallyChaos 
Break_RallyChaos: 
mov r0, #1 @ destructor = true 
str r0, [r4, #0x30] 

Exit_RallyChaos: 

pop {r4-r7} 
pop {r0} 
bx r0
.ltorg 

.global HoardersBane
.type HoardersBane, %function 
HoardersBane: 
push {r4-r5, lr} 
mov r4, r0 @ parent proc 

mov r0, #2 
blh  0x0800BC50   @GetUnitFromEventParam	{U}
mov r5, r0 @ unit 

ldrb r1, [r0, #0x0B] @ deployment byte 
ldr r2, [r4, #0x34] @ end of what phase 
mov r3, #0xC0 
and r1, r3 
cmp r2, r1 
bne HoardersBane_False 


mov r1, #5 
strb r1, [r0, #0x13] @ current hp 
ldrb r1, [r0, #0x0B] @ deployment byte 
ldr r2, =ActionData 
strb r1, [r2, #0x0C] @ deployment byte 



ldr  r3, =0x30004B8	@MemorySlot	{U}
mov r0, #2 
str r0, [r3, #4] 
mov r0, #18 
str r0, [r3, #4*6] @ slot6 HealValue 
@blh ASMC_HealLikeVulnerary

mov r0, #2 
blh  0x0800BC50   @GetUnitFromEventParam	{U}
@mov r1, #23 
@strb r1, [r0, #0x13] @ current hp 
ldr r0, =0x03004E50
str r5, [r0] 




HoardersBane_True: 
mov r0, #1 @ has a child proc 
b ExitHoardersBane 
HoardersBane_False: 
mov r0, #0 @ skipped this time 

ExitHoardersBane: 
pop {r4-r5} 
pop {r1} 
bx r1
.ltorg 

.global HoardersBane3
.type HoardersBane3, %function 
HoardersBane3: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 

mov r1, #0 @ X 
mov r2, #25 @ Y 
blh EnsureCameraOntoPosition

mov r0, #1 @ has a child proc 
pop {r4-r7} 
pop {r1} 
bx r1
.ltorg 



.global BreakHere
.type BreakHere, %function 
BreakHere: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 

mov r0, #0 @ no child proc 
pop {r4-r7} 
pop {r1} 
bx r1 
.ltorg 


.type CallBuffAnimationSkillLoop, %function 
.global CallBuffAnimationSkillLoop
CallBuffAnimationSkillLoop: 
push {lr} 
mov r1, r0 @ to block 
ldr r0, =BuffAnimationSkillProc
blh ProcStartBlocking 
mov r0, #1 @ has blocking proc 
pop {r1} 
bx r1 
.ltorg 


.global BuffAnimationIdle
.type BuffAnimationIdle, %function 
BuffAnimationIdle: 
push {r4, lr} 
mov r4, r0 @ parent proc 
ldr r0, [r4, #0x30] 
cmp r0, #0 
bne DestructBuffAnimation 
bl FindMapAuraProc
cmp r0, #0 
bne ContinueIdleBuffAnimation 
mov r0, r4 @ proc 
mov r1, #0 @ wait for rally anim 
blh ProcGoto 
@ProcGoto((Proc*)proc,1);
b ContinueIdleBuffAnimation 
DestructBuffAnimation: 
mov r0, r4 @ proc 
mov r1, #1 @ label 
blh ProcGoto 

ContinueIdleBuffAnimation:
pop {r4}  
pop {r0} 
bx r0 
.ltorg 

.global BuffAnimationSkillInit
.type BuffAnimationSkillInit, %function 
BuffAnimationSkillInit: 
mov r1, #0 
str r1, [r0, #0x2C] @ unit deployment byte & mid-loop counter 
str r1, [r0, #0x30] @ destructor = false 
str r1, [r0, #0x34] @ skill buffer 
bx lr 
.ltorg 

.type Buff_EnsureCamera, %function 
.global Buff_EnsureCamera 
Buff_EnsureCamera: 
push {r4, lr} 
mov r4, r0 @ proc 
add r4, #0x2c 
ldrb r0, [r4] 
blh GetUnit 
ldrb r1, [r0, #0x10] @ xx 
ldrb r2, [r0, #0x11] @ yy 
mov r0, #0 
@mov r0, r4 @ proc 
blh EnsureCameraOntoPosition 
mov r0, #0 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 

.type BuffAnimationSkillLoop, %function 
.global BuffAnimationSkillLoop
BuffAnimationSkillLoop: 
push {r4-r7, lr} 
mov r4, r0 @ proc 
add r4, #0x2C 
ldrb r7, [r4, #1] @ buffer ? 
cmp r7, #0 
beq UnitLoop 
ldr r6, [r4, #8] @ buffer itself 
ldrb r0, [r4] 
blh GetUnit 
mov r5, r0 @ unit 
b BufferLoop @ we just came out of pausing for some animation 
@ loop through units 
@ check for relevant skill(s) 
@ run a function for the skill 
UnitLoop: 
ldrb r0, [r4] 
add r0, #1 
cmp r0, #0xC0 
bge BreakLoop 
strb r0, [r4] @ deployment id 
blh GetUnit 
mov r5, r0 @ unit 
bl IsUnitOnField @(Unit* unit)
cmp r0, #0 
beq UnitLoop 

mov r0, r5 @ unit 
ldr r1, =gAttackerSkillBuffer
bl MakeSkillBuffer @(Unit* unit, SkillBuffer* buffer)
mov r6, r0 @ skill buffer 
str r6, [r4, #8] @ buffer 
@ possibly need to remove duplicate skills here 
@ /*00*/  u8 lastUnitChecked;
@ /*01*/  u8 skills[11];
BufferLoop: 
add r7, #1 
cmp r7, #BufferSize @ max size 
bgt GotoUnitLoop 
ldrb r0, [r6, r7] 
cmp r0, #0 @ should not have any gaps 
beq GotoUnitLoop 
ldr r3, =StartOfTurn_SkillTable
lsl r0, #2 @ 4 bytes per POIN 
add r3, r0 
ldr r0, [r3] @ specific entry 
cmp r0, #0 
beq BufferLoop @ do nothing if not a function 
strb r7, [r4, #1] @ we're in the buffer loop atm 

mov lr, r0 
mov r0, r5 @ unit 
.short 0xF800 @ execute the function 

@ need to pause here and resume after animation 
b ExitAnimationSkillLoop 

GotoUnitLoop: 
mov r7, #0 
strb r7, [r4, #1] @ not in buffer loop atm 
b UnitLoop 


BreakLoop: 
mov r0, #1 @ break loop 
str r0, [r4, #4] @ +0x30 as destructor 

ExitAnimationSkillLoop:
pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 

.global IsUnitOnField 
.type IsUnitOnField, %function 
IsUnitOnField: 
cmp r0, #0 
beq RetFalse 
ldr r1, [r0] 
cmp r1, #0 
beq RetFalse 
ldrb r1, [r1, #4] @ unit id 
cmp r1, #0 
beq RetFalse
ldr r1, [r0, #0x0C] 
ldr r2, =0x1000C @ escaped, undeployed, dead 
tst r1, r2 
bne RetFalse
RetTrue: 
mov r0, #1 
b Exit_IsUnitOnField 
RetFalse: 
mov r0, #0 
Exit_IsUnitOnField: 
bx lr 
.ltorg 



