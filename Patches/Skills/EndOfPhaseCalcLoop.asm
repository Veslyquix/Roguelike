.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ AiData, 0x203AA04
.equ ProcStartBlocking, 0x8002CE0 
.equ ProcStart, 0x8002C7C
.equ ProcBreakLoop, 0x8002E94 
.equ ActionData, 0x203A958 
.global EndOfPhaseCalcLoop_Hook
.type EndOfPhaseCalcLoop_Hook, %function 
EndOfPhaseCalcLoop_Hook: 
push {r4, lr} 
mov r4, r0 @ parent proc 
ldr r0, =EndOfPhaseCalcLoop_Proc 
mov r1, r4 
blh ProcStartBlocking


@ vanilla 
ldr r0, =AiData 
mov r2, r0 
add r2, #0x7B 
mov r1, #4 
strb r1, [r2] 
add r2, #3 
pop {r4} 
pop {r3} 
bx r3
.ltorg 

.global EndOfPhaseCalcLoop_Init 
.type EndOfPhaseCalcLoop_Init, %function 
EndOfPhaseCalcLoop_Init: 
add r0, #0x2C @ counter 
mov r1, #0 
str r1, [r0] 
bx lr 
.ltorg 

.global EndOfPhaseCalcLoop_Main
.type EndOfPhaseCalcLoop_Main, %function 
EndOfPhaseCalcLoop_Main: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 
add r0, #0x2C @ counter 
ldr r1, [r0] 
add r1, #1 
str r1, [r0] 
sub r1, #1 @ current one to care about 
ldr r3, =EndOfPhaseCalcLoop 
lsl r1, #2 @ 4 bytes per entry 
ldr r5, [r3, r1] 
cmp r5, #0 
bne RunFunc 

mov r0, r4 
blh ProcBreakLoop 
b ExitLoop 

RunFunc: 
ldr r0, =EndOfPhaseCalcLoop_SomeFunctionProc
mov r1, r4 @ parent proc 
blh ProcStartBlocking 
add r0, #0x2C 
str r5, [r0] 

ExitLoop: 

pop {r4-r7} 
pop {r1} 
bx r1 
.ltorg 

.global EndOfPhaseCalcLoop_SomeFunction
.type EndOfPhaseCalcLoop_SomeFunction, %function 
EndOfPhaseCalcLoop_SomeFunction: 
push {r4, lr}
mov r4, r0 

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
	
.global HoardersBane
.type HoardersBane, %function 
HoardersBane: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 

mov r1, #25 @ X 
mov r2, #0 @ Y 
blh EnsureCameraOntoPosition

mov r0, #1 @ has a child proc 
pop {r4-r7} 
pop {r1} 
bx r1
.ltorg 

.global HoardersBane2
.type HoardersBane2, %function 
HoardersBane2: 
push {r4-r7, lr} 
mov r4, r0 @ parent proc 

mov r0, #2 
blh  0x0800BC50   @GetUnitFromEventParam	{U}
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
blh ASMC_HealLikeVulnerary

mov r0, #2 
blh  0x0800BC50   @GetUnitFromEventParam	{U}
mov r1, #23 
strb r1, [r0, #0x13] @ current hp 


mov r0, #1 @ has a child proc 
pop {r4-r7} 
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












