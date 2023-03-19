.thumb 
mov r4, r0 @ vanilla 
push {r4-r7} 
ldr r7, =0x202BE4C 
ldr r6, =0x202CC9C @ 50th player unit 
ldr r4, =0x10031 @ custom ai3, atk if safe to do so 
mov r5, #0x7 @ move with ai2 = safety (previously MoveTowardsEnemy except Joshua if within2 movements) 
b Loop 
@ 803F019
GotoNextUnit: 
add r7, #8 
cmp r7, r6 
bge Break 
@b Loop 

Loop: 
ldr r0, [r7, #4] 
add r7, #0x40 
add r0, #0x29
ldrb r0, [r0] @ is promoted?
mov r1, #1 @ is promoted? 
tst r0, r1 
bne PromotedAI
mov r1, #0x20 @ lord 
tst r0, r1 
bne LordAI
str r4, [r7] 
strh r5, [r7, #4] 
b GotoNextUnit 
PromotedAI: 
ldr r1, =0x20031
str r1, [r7] 
mov r1, #0xA @ move towards Eirika
strh r1, [r7, #4] 
b GotoNextUnit 

LordAI: 
@ search for an enemy unit 
ldr r1, =0x202CFBC
ldr r2, =0x202DDCC @ start of NPCs 
AnyEnemiesAliveLoop: 
ldr r0, [r1] 
add r1, #0x48 
cmp r0, #0 
bne EnemiesAreAlive
cmp r1, r2 
blt AnyEnemiesAliveLoop 


sub r7, #0x40 
ldrb r0, [r7, #0x10] @ XX 
ldrb r1, [r7, #0x11] 
add r7, #0x40 
ldr r2, =0x202E4DC @ TerrainMap 
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r0			@add x coordinate
ldrb	r0,[r2]			@load datum at those coordinates
cmp r0, #0x0B @ gate 
beq SetSeizeFlag 
cmp r0, #0x1F @ throne 
beq SetSeizeFlag 
cmp r0, #0x23 @ gate2 
beq SetSeizeFlag 
b MoveTowardsThrone 

SetSeizeFlag: 

ldr r0, =0x8083280 @ CallEndEvent 
mov lr, r0 
.short 0xf800 
@ldr r0, =0x202BCFE @ chapter ID 
@ldrb r0, [r0]
@ldr r1, =0x88B0890 @(MapSetting )
@mov r2, #0x94
@mul r0, r2
@add r0, r1
@add r0, #0x74
@ldrb r0, [r0]
@mov r1, #0x4
@mul r0, r1
@ldr r1, =0x88B363C @ (MAPPOINTERS )
@add r0 ,r0, R1
@ldr r0, [r0]
@mov r1, #0x4C
@ldr r0, [r0, r1]
@ldr r1, =0x800D07C @ EventEngine 
@mov lr, r1
@mov r1, #0x1
@.short 0xf800 

b BreakUnitLoop 

MoveTowardsThrone:
@ no enemies are alive, so move towards Throne/Gate 
str r4, [r7] 
mov r1, #0x0D @ target Throne/Gate 
strh r1, [r7, #4] 
b GotoNextUnit 

EnemiesAreAlive: @ part of LordAI 
ldr r1, =0x10031 @ custom ai3, atk if adjacent only 
str r4, [r7] 
mov r1, #0x07 @ previous Random, now RunAway 
strh r1, [r7, #4] 
b GotoNextUnit 

Break: 
@ldr r7, =0x202DDCC
@ldr r6, =0x202E09C @ 10th npc 
@NPC_AI_Loop:
@add r7, #0x40 
@str r4, [r7] 
@strh r5, [r7, #4] 
@add r7, #0x8
@cmp r7, r6 
@blt NPC_AI_Loop @ give all NPCs the same AI, too 



@ give all players a vulnerary 
ldr r3, =0x202BE6A 
ldr r2, =0x202CC8A 
mov r4, #3 
lsl r4, #8 
mov r1, #0x6C @ vuln 
orr r4, r1 
UnitLoop: 
mov r1, #0
sub r1, #2 
add r3, #0x48 
cmp r3, r2 
bgt BreakUnitLoop 
InvLoop: 
add r1, #2 
cmp r1, #10
bge UnitLoop 
ldrb r0, [r3, r1] 
cmp r0, #0x6C 
beq UnitLoop 
cmp r0, #0 
bne InvLoop 
strh r4, [r3, r1] 
b UnitLoop 

BreakUnitLoop: 
pop {r4-r7} 
ldr r3, =0x8083ED5 
bx r3 
.ltorg 

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.global CallAttack05_Promoted
.type CallAttack05_Promoted, %function 
CallAttack05_Promoted:
push {r4, lr} 

ldr r0, =0x3004E50 @ curr unit 
ldr r0, [r0] 
add r0, #0x43 @ AI1 Counter 

ldr r1, =0x30017D0 @ gpAiScriptCurrent 
ldr r2, =0x85A8870 
str r2, [r1] 
blh 0x803C5DC @ AiScript_Exec

@ did the attack function make a decision? 
ldr r0, =0x203AA94 
ldrb r0, [r0, #0xA] @ AiData.decisionBool 
cmp r0, #0 
beq SkipRunToLord

ldr r2, =0x3004E50 
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
lsr r1, r0, #2
sub r0, r1 @ 3/4 hp 
ldrb r1, [r2, #0x17] 
ldrb r3, [r2, #0x18] 
add r1, r3 @ def + res 
lsr r1, #1 @ /2 
add r0, r1 @ 3/4 + (def+res)/2
lsr r0, #1 
bl IsTargetCoordTooUnsafe 
cmp r0, #1 
bne SkipRunToLord 
ldr r0, =0x3004E50 
ldr r0, [r0] 
bl CanUnitRunToSafety 
cmp r0, #1 
bne SkipRunToLord
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
strb r1, [r0, #0xA] @ AiData.decisionBool @ no decision, so it should do AI2 instead 
SkipRunToLord: @returns r0 as t/f that we made a decision 
mov r0, #1 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 
.equ EventEngine, 0x800D07C
.global CallAttack05
.type CallAttack05, %function 
CallAttack05: 
push {r4, lr} 

ldr r0, =0x3004E50 @ curr unit 
ldr r0, [r0] 
add r0, #0x43 @ AI1 Counter 

ldr r1, =0x30017D0 @ gpAiScriptCurrent 
ldr r2, =0x85A8870 
str r2, [r1] 
blh 0x803C5DC @ AiScript_Exec

@ did the attack function make a decision? 
@ldr r1, =0x30017C8 @ s8 gAiScriptEndedFlag 
@ldrb r0, [r1] 
ldr r0, =0x203AA94 
ldrb r0, [r0, #0xA] @ AiData.decisionBool 
cmp r0, #0 
beq CheckForEvents

ldr r2, =0x3004E50 
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
lsr r1, r0, #1
sub r0, r1 @ 1/2 hp 
ldrb r1, [r2, #0x17] 
ldrb r3, [r2, #0x18] 
add r1, r3 @ def + res 
lsr r1, #1 @ /2 
add r0, r1 @ 3/4 + (def+res)/2
lsr r0, #1 
@ if the dmg we could take is more than r0, run away 
bl IsTargetCoordTooUnsafe
cmp r0, #1 
bne DontRunInsteadOfAttack
ldr r0, =0x3004E50 
ldr r0, [r0] 
bl CanUnitRunToSafety 
cmp r0, #1 
bne DontRunInsteadOfAttack 

@ CanUnitRunToSafety 
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
strb r1, [r0, #0xA] @ AiData.decisionBool @ no decision, so it should do AI2 instead 
b SkipRunAway 
CheckForEvents: 
bl TryEventInRange


@bl CallRunAway 
DontRunInsteadOfAttack: 
@returns r0 as t/f that we made a decision 
SkipRunAway: 
mov r0, #1 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 


TryEventInRange: 
push {r4-r7, lr} 

mov r4, r0 @ unit 
@ village, chest, door, talk 

ldr r0, =0x202BCF0 
ldrb r0, [r0, #0xE] @ chapter ID 
blh 0x80346B0 @ GetChapterEventsPointer
mov r5, r0 


mov r7, #0 @ yy 
sub r7, #1 
ldr r3, =0x202E4D4
ldrh r2, [r3] 
sub r2, #1 @ xx max 
ldrh r3, [r3, #2] 
sub r3, #1 @ yy max 



ldr		r4,=0x202E4E0	@ movement map 
ldr		r4,[r4]			@Offset of map's table of row pointers




NextTile_Y_Event: 
mov r6, #0 
sub r6, #1 
add r7, #1 
cmp r7, r3 
bgt Exit_Event

NextTile_X_Event: 
add r6, #1 
cmp r6, r2 
bgt NextTile_Y_Event 


lsl r0, r7, #2 
add r0, r4
ldr r0, [r0] 
add r0, r6 @ xx 
ldrb r0, [r0] 
cmp r0, #0xFF 
beq NextTile_X_Event

push {r2-r3} 
ldr r3, [r5, #8] @ LocationBasedEvents 
mov r2, #0 
sub r2, #12 
LocationBasedEventsLoop:
add r2, #12 
ldr r0, [r3, r2] 
cmp r0, #0 
beq BreakLocationLoop 
mov r0, r3 
add r0, r2 
ldrb r1, [r0, #9] @ yy 
ldrb r0, [r0, #8] @ xx 
cmp r0, r6 
bne LocationBasedEventsLoop 
cmp r1, r7 
bne LocationBasedEventsLoop

@ check unit map here 

ldr r0, =0x203AA96
strb r7, [r0, #1] @ yy 
strb r6, [r0] @ xx 
ldr r0, =0x203AA94 
mov r1, #0x0 @ wait
strb r1, [r0] 
strb r1, [r0, #0xB] @ visit 
mov r1, #1 
strb r1, [r0, #0xA] @ took decision bool 
ldr r1, =0x3004E50 
ldr r1, [r1] 
ldrb r1, [r1, #0x0B] @ unit 
strb r1, [r0, #1] @ unit index 

mov r0, r3 
add r0, r2 
ldr r0, [r0, #4] @ event 
mov r1, #1 
blh EventEngine 
pop {r2-r3} 



b Exit_Event

BreakLocationLoop: 
pop {r2-r3} 
b NextTile_X_Event 

Exit_Event: 

pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 



.global CanUnitRunToSafety
.type CanUnitRunToSafety, %function 
CanUnitRunToSafety:
push {r4-r7, lr} 
mov r4, r0 @ unit 
ldr r0, =0x203AA96
ldrb r1, [r0, #1] @ yy 
ldrb r0, [r0] @ xx 

ldr		r2,=0x202E4F0	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r0			@add x coordinate
ldrb	r5,[r2]			@load datum at those coordinates
lsr r5, #2 @ 1/4 is what we want or less 
@ r5 = current choice 
@ r6 = xx 
mov r7, #0 @ yy 
sub r7, #1 
ldr r3, =0x202E4D4
ldrh r2, [r3] 
sub r2, #1 @ xx max 
ldrh r3, [r3, #2] 
sub r3, #1 @ yy max 



ldr		r4,=0x202E4E0	@ movement map 
ldr		r4,[r4]			@Offset of map's table of row pointers




NextTile_Y: 
mov r6, #0 
sub r6, #1 
add r7, #1 
cmp r7, r3 
bgt False_CanUnitRunToSafety

NextTile_X: 
add r6, #1 
cmp r6, r2 
bgt NextTile_Y 


lsl r0, r7, #2 
add r0, r4
ldr r0, [r0] 
add r0, r6 @ xx 
ldrb r0, [r0] 
cmp r0, #0xFF 
beq NextTile_X
 
ldr		r1,=0x202E4F0	@ danger map 
ldr		r1,[r1]			@Offset of map's table of row pointers
lsl r0, r7, #2 
add r0, r1 
ldr r0, [r0] 
add r0, r6 @ xx 
ldrb r0, [r0] 
cmp r0, r5 
bge NextTile_X
mov r0, #1 
b Exit_CanUnitRunToSafety
False_CanUnitRunToSafety:
mov r0, #0 
Exit_CanUnitRunToSafety: 


pop {r4-r7} 
pop {r1} 
bx r1 
.ltorg 


.global TryMoveIfSafe
.type TryMoveIfSafe, %function 
TryMoveIfSafe: 
push {r4, lr} 

ldr r0, =0x803CE18 
mov lr, r0 
ldr r0, =0x3004E50 
ldr r0, [r0] 
add r0, #0x45
.short 0xf800 

ldr r2, =0x3004E50 
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
lsr r1, r0, #2
sub r0, r1 @ 3/4 hp 
ldrb r1, [r2, #0x17] 
ldrb r3, [r2, #0x18] 
add r1, r3 @ def + res 
lsr r1, #1 @ /2 
add r0, r1 @ 3/4 + (def+res)/2
lsr r0, #1 

@ if the dmg we could take is more than r0, run away 
bl IsTargetCoordTooUnsafe
cmp r0, #1 
bne DontRun
bl CallRunAway 
DontRun: 
mov r0, #1 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 

IsTargetCoordTooUnsafe:
mov r3, r0 @ safety threshold 
ldr r0, =0x203AA96
ldrb r1, [r0, #1] @ yy 
ldrb r0, [r0] @ xx 

ldr		r2,=0x202E4F0	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r0			@add x coordinate
ldrb	r0,[r2]			@load datum at those coordinates

cmp r0, r3
bgt TooUnsafe
mov r0, #0 @ It's fine 
b ExitUnsafe 
TooUnsafe: 
mov r0, #1 @ Too unsafe 
ExitUnsafe: 
bx lr 
.ltorg 



.global CallRunAway
.type CallRunAway, %function 
CallRunAway:

@ldr r0, =0x30017C8
@mov r1, #0 
@strb r1, [r0] 

ldr r0, =0x803CDD4 @ AI Script Function ASM 11 ( Run away ) 
mov lr, r0 
ldr r0, =0x3004E50 
ldr r0, [r0] 
add r0, #0x45
.short 0xf800 

ldr r1, =0x30017C8
mov r0, #1
strb r0, [r1] 

pop {r4} 
pop {r1} 
bx r1 
.ltorg 


