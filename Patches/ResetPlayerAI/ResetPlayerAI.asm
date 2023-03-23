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


ldr r0, =gMapMovement 
ldr r0, [r0] 
mov r1, #0xFF 
blh BmMapFill
ldr r0, =gCurrentUnit 
ldr r0, [r0] 
blh FillMovementMapForUnit 

@ did the attack function make a decision? 
ldr r0, =0x203AA94 
ldrb r0, [r0, #0xA] @ AiData.decisionBool 
cmp r0, #0 
beq SkipRunToLord

ldr r3, =gChapterData
ldrb r0, [r3, #0x0E] @ chapter ID 
cmp r0, #8 
bgt NoAntiJeiganAI
mov r0, #3 
bl IsTargetCoordTooUnsafe 
cmp r0, #0 
bne SkipRunToLord 
@ it is so safe that we might as well not kill with our jeigan(s) 
ldr r3, =Defender 
ldr r0, [r3] 
ldr r1, [r3, #4] 
ldr r0, [r0, #0x28] @ char abilities 
ldr r1, [r1, #0x28] @ class abilities 
orr r0, r1 
mov r1, #0x80 @ boss 
lsl r1, #8 
tst r0, r1 
beq JeiganDontAttack
b JeiganAttack



NoAntiJeiganAI: 
ldr r2, =gCurrentUnit
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
sub r0, #1 @ assume we're at WTD 
lsr r0, #2 
bl IsTargetCoordTooUnsafe 
cmp r0, #1 
bne SkipRunToLord 


ldr r0, =0x3004E50 
ldr r0, [r0] 
@bl CanUnitRunToSafety 
@cmp r0, #0 
@beq JeiganAttack

ldr r3, =Defender 
mov r1, #0x52 
ldsb r1, [r3, r1] 
cmp r1, #0 
beq JeiganAttack @ so we attack archers etc 
JeiganDontAttack:
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
str r1, [r0]
str r1, [r0, #4]
str r1, [r0, #8]

@strb r1, [r0, #0xA] @ AiData.decisionBool @ no decision, so it should do AI2 instead 
@b SkipEventStuff

SkipRunToLord: @returns r0 as t/f that we made a decision 
bl ActiveUnitEquipBestWepByRange
bl TryEventInRange

ldr r2, =gCurrentUnit
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
sub r0, #2 
@ if the dmg we could take is more than r0, run away 
bl IsTargetCoordTooUnsafe
cmp r0, #1 
bne SkipEventStuff
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
str r1, [r0, #0] @ AiData.decisionBool @ no decision, so it should do AI2 instead 
str r1, [r0, #4] @ 
str r1, [r0, #8] @ 

SkipEventStuff: 
JeiganAttack:
mov r0, #1 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 
.equ gChapterData, 0x202BCF0 
.equ EventEngine, 0x800D07C
.equ BmMapFill, 0x80197E4
.equ gMapMovement, 0x0202E4E0
.equ FillMovementMapForUnit, 0x801A38C

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


ldr r0, =gMapMovement 
ldr r0, [r0] 
mov r1, #0xFF 
blh BmMapFill
ldr r0, =gCurrentUnit 
ldr r0, [r0] 
blh FillMovementMapForUnit 

@ did the attack function make a decision? 
@ldr r1, =0x30017C8 @ s8 gAiScriptEndedFlag 
@ldrb r0, [r1] 
ldr r0, =0x203AA94 
ldrb r0, [r0, #0xA] @ AiData.decisionBool 
cmp r0, #0 
beq CheckForEvents

ldr r2, =gCurrentUnit
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp  
sub r0, #1 @ assume we're at WTD 
lsr r0, #2 @ 1/2 hp  
@ if the dmg we could take is more than r0, run away 
bl IsTargetCoordTooUnsafe
cmp r0, #1 
bne JustAttack

ldr r2, =gCurrentUnit
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp  
sub r0, #2 @ assume we're at WTD and want to live with at least 1 hp 
lsr r0, #1 @ hp-1 
@ if the dmg we could take is more than r0, run away 
bl IsTargetCoordTooUnsafe
cmp r0, #1 
bne AttackIfTheyCannotCounter 
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
str r1, [r0]
str r1, [r0, #4]
str r1, [r0, #8]
b CheckForEvents 


@ coord is unsafe, and there's nowhere to run 
@ if opponent cannot counter, attack! 
.equ Defender, 0x203A56C

AttackIfTheyCannotCounter:
ldr r3, =Defender 
mov r1, #0x52 
ldsb r1, [r3, r1] 
cmp r1, #0 
beq JustAttack @ so we attack archers etc 

ldr r0, =gCurrentUnit 
ldr r0, [r0] 

@bl CanUnitRunToSafety 
@cmp r0, #1 
@beq DoNotAttack 
@b CheckForEvents 
DoNotAttack: 
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
str r1, [r0]
str r1, [r0, #4]
str r1, [r0, #8]
@strb r1, [r0, #0xA] @ AiData.decisionBool @ no decision, so it should do AI2 instead 
@b SkipRunAway 

CheckForEvents: 
bl TryEventInRange
bl ActiveUnitEquipBestWepByRange
ldr r2, =gCurrentUnit
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
sub r0, #2 
@ if the dmg we could take is more than r0, run away 
bl IsTargetCoordTooUnsafe
cmp r0, #1 
bne SkipRunAway 
ldr r0, =0x203AA94 
mov r1, #0 @ no decision made 
str r1, [r0, #0] @ AiData.decisionBool @ no decision, so it should do AI2 instead 
str r1, [r0, #4] @ 
str r1, [r0, #8] @ 
@bl CallRunAway 
JustAttack: 
@returns r0 as t/f that we made a decision 
SkipRunAway: 

mov r0, #1 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 

.equ GetUnitEquippedWepSlot, 0x08016B58 @ (const struct Unit*);
.equ EquipUnitItemSlot, 0x08016BC0 @ (struct Unit*, int slot)
@ doors are adjacent 
	.equ MemorySlot,0x30004B8
@SET_FUNC IsThereClosedDoorAt, 0x80831F1
.equ IsThereClosedChestAt, 0x80831AC 
.equ AiDecision, 0x203AA94
.equ TryAddClosedDoorToTargetList, 0x8025794 
.equ ForEachAdjacentPos, 0x8024FA4
.equ RunLocationEvents, 0x80840C4
.equ gActionData, 0x203A958 
.equ CheckEventId, 0x8083da8
.equ UseKeyOrLockpick, 0x802F510 
.equ gCurrentUnit, 0x3004E50 
.equ CpPerform_TalkWait, 0x803A274
.equ GetUnit, 0x8019430
TryEventInRange: 
push {r4-r7, lr} 
mov r4, r8 
mov r5, r9 
mov r6, r10 
mov r7, r11 
push {r4-r7} 

ldr r0, =0x202BCF0 
ldrb r0, [r0, #0xE] @ chapter ID 
blh 0x80346B0 @ GetChapterEventsPointer
mov r11, r0 


mov r7, #0 @ yy 
sub r7, #1 
ldr r3, =0x202E4D4
ldrh r2, [r3] 
sub r2, #1 @ xx max 
ldrh r3, [r3, #2] 
sub r3, #1 @ yy max 
mov r8, r2 @ xx max 
mov r9, r3 @ yy max 


ldr		r4,=0x202E4E0	@ movement map 
ldr		r4,[r4]			@Offset of map's table of row pointers
mov r10, r4 



NextTile_Y_Event: 
mov r6, #0 
sub r6, #1 
add r7, #1 
cmp r7, r9
bgt Goto_Exit_Event

NextTile_X_Event: 
add r6, #1 
cmp r6, r8 
bgt NextTile_Y_Event 

cmp r6, #6 
bne NoBreak
cmp r7, #12
bne NoBreak 
@mov r11, r11 

NoBreak: 

lsl r0, r7, #2 
add r0, r10
ldr r0, [r0] 
add r0, r6 @ xx 
ldrb r0, [r0] 
cmp r0, #0xFF 
beq NextTile_X_Event
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldr r2, [r1, #4] @ class 
ldrb r2, [r2, #0x12] @ base mov 
ldrb r1, [r1, #0x1D] @ bonus mov 
add r1, r2 
cmp r0, r1 
bgt NextTile_X_Event 

.equ UnitMap, 0x202E4D8
@ check unit map here 
ldr		r1,=UnitMap	@Load the location in the table of tables of the map you want
ldr		r1,[r1]			@Offset of map's table of row pointers
lsl		r0, r7,#0x2			@multiply y coordinate by 4
add		r1,r0			@so that we can get the correct row pointer
ldr		r1,[r1]			@Now we're at the beginning of the row data
add		r1,r6			@add x coordinate
ldrb	r0,[r1]			@load datum at those coordinates
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldrb r1, [r1, #0x0B] @ current unit 
cmp r0, r1 
beq GotoNoUnitHere 


cmp r0, #0 
beq GotoNoUnitHere 
blh GetUnit 
ldr r0, [r0] 
cmp r0, #0 
beq GotoNoUnitHere 
ldrb r0, [r0, #4] 

mov r5, r11 @ 
ldr r5, [r5, #4] @ TalkEvents 
sub r5, #16 
TalkEventLoop: 
add r5, #16 
ldr r1, [r5] 
cmp r1, #0 
beq NextTile_X_Event
ldrb r1, [r5, #9] @ talk to this unit 
cmp r0, r1 
bne TalkEventLoop 
ldr r2, =gCurrentUnit 
ldr r2, [r2] 
ldr r2, [r2] @ unit table 
ldrb r2, [r2, #4] 
ldrb r1, [r5, #8] 
cmp r1, r2 
bne GotoTalkEventLoop 
push {r0-r1} 
@ we found a match 
ldrb r0, [r5, #2] @ flag 
blh CheckEventId 
mov r2, r0 
pop {r0-r1} 
cmp r2, #0 
bne TalkEventLoop 
b CheckCoords 
GotoNoUnitHere:
b NoUnitHere 
Goto_Exit_Event:
b Exit_Event 
GotoTalkEventLoop:
b TalkEventLoop 

CheckCoords: 

ldr r3, =gCurrentUnit @ get movement 
ldr r3, [r3] 
ldr r2, [r3, #4] @ class 
ldrb r2, [r2, #0x12] @ base mov 
ldrb r3, [r3, #0x1D] @ bonus mov 
add r3, r2 @ movement  

@ check adjacent coords 
sub r6, #1 
cmp r6, #0 
blt CheckRight 
lsl r1, r7, #2 
add r1, r10
ldr r1, [r1] 
add r1, r6 @ xx 
ldrb r1, [r1] 
cmp r1, #0xFF 
beq CheckRight 
cmp r1, #0 
beq CheckRight
cmp r1, r3
bgt CheckRight

ldr		r2,=UnitMap	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1, r7,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r6			@add x coordinate
ldrb	r1,[r2]			@load datum at those coordinates
cmp r1, #0 
beq FoundValidCoordMove 
ldr r2, =gCurrentUnit 
ldr r2, [r2] 
ldrb r2, [r2, #0x0B] 
cmp r1, r2 
beq FoundValidCoordMove 

CheckRight: 
add r6, #2
cmp r6, r8 
bgt CheckUp 
lsl r1, r7, #2 
add r1, r10
ldr r1, [r1] 
add r1, r6 @ xx 
ldrb r1, [r1] 
cmp r1, #0xFF 
beq CheckUp
cmp r1, #0 
beq CheckUp
cmp r1, r3
bgt CheckUp

ldr		r2,=UnitMap	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1, r7,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r6			@add x coordinate
ldrb	r1,[r2]			@load datum at those coordinates
cmp r1, #0 
beq FoundValidCoordMove 
ldr r2, =gCurrentUnit 
ldr r2, [r2] 
ldrb r2, [r2, #0x0B] 
cmp r1, r2 
beq FoundValidCoordMove 
CheckUp:
sub r6, #1
sub r7, #1
cmp r7, #0 
blt CheckDown 
lsl r1, r7, #2 
add r1, r10
ldr r1, [r1] 
add r1, r6 @ xx 
ldrb r1, [r1] 
cmp r1, #0xFF 
beq CheckDown
cmp r1, #0 
beq CheckDown
cmp r1, r3
bgt CheckDown
ldr		r2,=UnitMap	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1, r7,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r6			@add x coordinate
ldrb	r1,[r2]			@load datum at those coordinates
cmp r1, #0 
beq FoundValidCoordMove 
ldr r2, =gCurrentUnit 
ldr r2, [r2] 
ldrb r2, [r2, #0x0B] @ D3232 
cmp r1, r2 
beq FoundValidCoordMove 
CheckDown: 
add r7, #2
cmp r7, r9 
bgt NoUnitHere 
lsl r1, r7, #2 
add r1, r10
ldr r1, [r1] 
add r1, r6 @ xx 
ldrb r1, [r1] 
cmp r1, #0xFF 
beq NoUnitHere 
cmp r1, #0 
beq NoUnitHere
cmp r1, r3
bgt NoUnitHere
ldr		r2,=UnitMap	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1, r7,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r6			@add x coordinate
ldrb	r1,[r2]			@load datum at those coordinates
cmp r1, #0 
beq FoundValidCoordMove 
ldr r2, =gCurrentUnit 
ldr r2, [r2] 
ldrb r2, [r2, #0x0B] 
cmp r1, r2 
beq FoundValidCoordMove 
b NoUnitHere 

FoundValidCoordMove: 
ldr r2, =gCurrentUnit 
ldr r2, [r2] 
ldr r2, [r2] @ char table 
ldrb r1, [r2, #4] @ unit id 

ldr r2, =AiDecision 
mov r1, #0 
str r1, [r2]
str r1, [r2, #4]
str r1, [r2, #8]
strb r7, [r2, #3] @ yy 
strb r6, [r2, #2] @ xx 
.equ GetUnitByCharId, 0x801829C
blh GetUnitByCharId 
ldrb r1, [r0, #0x0B] 
ldr r2, =AiDecision 

strb r1, [r2, #8] @ xOther 
strb r1, [r2, #9] @ yOther 
mov r1, #0 
strb r1, [r2, #6] @ targetIndex 

strb r1, [r2, #0x07] @ usedItemSlot is Actor Deployment Byte 
@strb r0, [r2, #0x08] @ xOther (but in this case the target's unit id) 


mov r1, #0x8 @ talk
strb r1, [r2] 
strb r1, [r2, #0xB] @ talk
mov r1, #1 
strb r1, [r2, #0xA] @ took decision bool 
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldrb r1, [r1, #0x0B] @ unit 
strb r1, [r2, #1] @ unit index 
strb r1, [r2, #7] @ usedItemSlot is Deployment byte of actor 

@ldr r1, =gActionData 
@strb r0, [r1, #0x12] @ inventory slot # (0-4) 
@strb r6, [r1, #0x0E] @ xx 
@mov r0, #0x14 @ chest 
@strb r0, [r1, #0x11] @ action type: chest 
@
@strb r7, [r1, #0x0F] @ yy 
@ldr r0, =gCurrentUnit 
@ldr r0, [r0] 
@ldrb r0, [r0, #0x0B] @ unit 
@strb r0, [r1, #1] @ unit index 

b Exit_Event 


NoUnitHere: 


mov r5, r11 
ldr r5, [r5, #8] @ LocationBasedEvents 
mov r4, #0 
sub r4, #12 
LocationBasedEventsLoop:
add r4, #12 

ldr r0, [r5, r4] 
cmp r0, #0 
bne ContinueLocationBasedEventsLoop 
b BreakLocationLoop 
ContinueLocationBasedEventsLoop: 

mov r0, r5 
add r0, r4 
ldrb r1, [r0, #8] @ xx
cmp r1, r6 
bne LocationBasedEventsLoop 
ldrb r1, [r0, #9] @ yy 
cmp r1, r7 
bne LocationBasedEventsLoop
ldrb r1, [r0, #0] 
cmp r1, #6 @ Visit Village 
bne TryChest
ldrb r1, [r0, #0xA] @ type 
cmp r1, #0x10 
bne LocationBasedEventsLoop 
ldrb r0, [r0, #2] @ completion flag 
blh CheckEventId
cmp r0, #0 
bne LocationBasedEventsLoop 
ldr r2, =0x202E4DC @ terrain map 
ldr r2, [r2] 
lsl r1, r7, #2 
add r2, r1 
ldr r2, [r2] 
add r2, r6 
ldrb r0, [r2] 
cmp r0, #3 @ village (open) 
bne LocationBasedEventsLoop 

ldr r0, =0x203AA94 
strb r7, [r0, #3] @ yy 
strb r6, [r0, #2] @ xx 
mov r1, #0x0 @ wait
strb r1, [r0] 
strb r1, [r0, #0xB] @ visit 
mov r1, #1 
strb r1, [r0, #0xA] @ took decision bool 
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldrb r1, [r1, #0x0B] @ unit 
strb r1, [r0, #1] @ unit index 

ldr r0, =gActionData 
strb r1, [r0, #0x0C] @ unit index 
strb r6, [r0, #0x0E] @ xx 
strb r7, [r0, #0x0F] @ yy 

ldr r3, =MemorySlot 
strh r6, [r3, #4*0x0B]
strh r7, [r3, #4*0x0B+2]


mov r1, #3
ldr r0, =WaitUntilAIMovesProc
blh pr6C_New, r2
	.equ pr6C_New,                   0x08002C7C


add r0, #0x2C
str r6, [r0] @ param 1 
str r7, [r0, #4] @ param 2 
ldr r1, =RunLocationEvents 
str r1, [r0, #20] @ 


b Exit_Event

TryChest: 
cmp r1, #7 @ chest 
bne LocationBasedEventsLoop 
ldrb r1, [r0, #0xA] 
cmp r1, #0x14 @ type is always 0x14 when closed 
bne LocationBasedEventsLoop

bl GetActiveUnitChestKeySlot
cmp r0, #0 
blt LocationBasedEventsLoop 

ldr r1, =AiDecision 
mov r2, #0 
str r2, [r1]
str r2, [r1, #4]
str r2, [r1, #8]

strb r0, [r1, #0x07] @ usedItemSlot 
ldr r1, =gActionData 
strb r0, [r1, #0x12] @ inventory slot # (0-4) 

@mov r0, r6 
@mov r1, r7 @ coords 
@blh IsThereClosedChestAt
@cmp r0, #0 
@beq LocationBasedEventsLoop 
ldr r3, =0x202E4DC @ TerrainMap 
ldr r2, [r3] 
lsl r1, r7, #2 
add r2, r1 
ldr r2, [r2] 
ldrb r0, [r2, r6] 
cmp r0, #0x21 
bne LocationBasedEventsLoop 

strb r6, [r1, #0x0E] @ xx 
mov r0, #0x14 @ chest 
strb r0, [r1, #0x11] @ action type: chest 

strb r7, [r1, #0x0F] @ yy 
ldr r0, =gCurrentUnit 
ldr r0, [r0] 
ldrb r0, [r0, #0x0B] @ unit 
strb r0, [r1, #1] @ unit index 

ldr r0, =AiDecision  
strb r7, [r0, #3] @ yy 
strb r6, [r0, #2] @ xx 
mov r1, #0x6 @ use item 
strb r1, [r0] 
strb r1, [r0, #0xB] @ visit 
mov r1, #1 
strb r1, [r0, #0xA] @ took decision bool 
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldrb r1, [r1, #0x0B] @ unit 
strb r1, [r0, #1] @ unit index 

@mov r1, #3
@ldr r0, =WaitUntilAIMovesProc
@blh pr6C_New, r2
@	.equ pr6C_New,                   0x08002C7C
@
@
@add r0, #0x2C
@str r6, [r0] @ param 1 
@str r7, [r0, #4] @ param 2 
@ldr r1, =RunLocationEvents 
@str r1, [r0, #20] @ 
@
@
@blh UseKeyOrLockpick 

b Exit_Event 
FoundClosedDoor: 
bl GetActiveUnitDoorKeySlot

cmp r0, #0 
blt NoKeyForDoor

ldr r1, =AiDecision 
mov r2, #0 
str r2, [r1]
str r2, [r1, #4]
str r2, [r1, #8]

strb r0, [r1, #0x07] @ usedItemSlot 
ldr r1, =gActionData 
strb r0, [r1, #0x12] @ inventory slot # (0-4) 
strb r6, [r1, #0x0E] @ xx 
strb r7, [r1, #0x0F] @ yy 
mov r0, #0x12 
strb r0, [r1, #0x11] @ action type: door 
ldr r0, =gCurrentUnit 
ldr r0, [r0] 
ldrb r0, [r0, #0x0B] @ unit 
strb r0, [r1, #1] @ unit index 

ldr r0, =AiDecision
strb r7, [r0, #3] @ yy 
strb r6, [r0, #2] @ xx 
mov r1, #0x6 @ use item 
strb r1, [r0] 
strb r1, [r0, #0xB] @ visit 
mov r1, #1 
strb r1, [r0, #0xA] @ took decision bool 
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldrb r1, [r1, #0x0B] @ unit 
strb r1, [r0, #1] @ unit index 

@mov r1, #3
@ldr r0, =WaitUntilAIMovesProc
@blh pr6C_New, r2
@	.equ pr6C_New,                   0x08002C7C
@
@
@add r0, #0x2C
@str r6, [r0] @ param 1 
@str r7, [r0, #4] @ param 2 
@ldr r1, =RunLocationEvents 
@str r1, [r0, #20] @ 
@
blh UseKeyOrLockpick 

b Exit_Event 


BreakLocationLoop: 
mov r0, r6 
mov r1, r7 
mov r2, r8 
mov r3, r9 
bl TryAddClosedDoorToTargetListNew 
ldr r0, =gTargetArraySize
.equ gTargetArraySize, 0x203E0EC 
ldrb r0, [r0] 
cmp r0, #0 
bne FoundClosedDoor 

NoKeyForDoor:



@ https://github.com/FireEmblemUniverse/fireemblem8u/blob/8a04f056602fb6f1db1a8f6aebed0f8d383ac420/src/bmusemind.c#L556
@ rescue? 
@ if rescuing a unit, run away and drop somewhere 



b NextTile_X_Event 

Exit_Event: 

pop {r4-r7} 
mov r8, r4 
mov r9, r5 
mov r10, r6 
mov r11, r7 
pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 

TryAddClosedDoorToTargetListNew:
push {r4-r7, lr}
mov r6, r0 @ xx 
mov r7, r1 @ yy 
mov r4, r2 @ xx boundary 
mov r5, r3 @ yy boundary 

mov r0, r6 
sub r0, #1 
cmp r0, #0 
blt SkipLeftSide 
mov r1, r7 
blh TryAddClosedDoorToTargetList 
SkipLeftSide: 
mov r0, r6 
add r0, #1 
cmp r0, r4 
bgt SkipRightSide 
mov r1, r7 
blh TryAddClosedDoorToTargetList 
SkipRightSide: 
mov r0, r6 
mov r1, r7 
sub r1, #1 
cmp r1, #0 
blt SkipAboveSide
blh TryAddClosedDoorToTargetList 
SkipAboveSide: 
mov r0, r6 
mov r1, r7 
add r1, #1 
cmp r1, r5 
bgt SkipBelowSide 
blh TryAddClosedDoorToTargetList 
SkipBelowSide: 

pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 

.ltorg
.global WaitUntilAIMoves
.type WaitUntilAIMoves, %function
WaitUntilAIMoves:
push {r4-r5, lr} 
mov r4, r0 @ Parent? 
ldr r0, =0x85a8024 @gProc_CpPerform
blh ProcFind, r1 
cmp r0, #0 
beq ProcStateError 



.equ IsThereAMovingMoveunit, 0x8078738 
blh IsThereAMovingMoveunit 
cmp r0, #0 
bne ProcStateError 
.equ gProcCameraMovement, 0x859A548 
ldr r0, =gProcCameraMovement 
blh ProcFind 
cmp r0, #0 
bne ProcStateError 
b ReturnProcStateRight 

@ldr r1, [r0, #4] @ Code Cursor 
@ldr r2, =0x85A8068 @ wait 0x85a8024 + 0x40 @gProc_CpPerform
@cmp r1, r2 
@beq ReturnProcStateRight 

ProcStateError:
mov r0, #0 


b EndIfProcStateWrongThenYield

ReturnProcStateRight: 


mov r0, r4 @  @ parent to break from 
blh BreakProcLoop
mov r0, #1

EndIfProcStateWrongThenYield:
pop {r4-r5}
pop {r1}
bx r1 
.ltorg 

	.equ BreakProcLoop, 0x08002E94
	.equ ProcFind, 0x08002E9C
.global CallProvidedRoutine
.type CallProvidedRoutine, %function 
CallProvidedRoutine: 
push {r4, lr} 
mov r4, #0x2C 
add r4, r0 
ldr r0, [r4, #20] @ routine 
mov r1, #1 
orr r0, r1 
mov lr, r0 

ldr r0, [r4] 
ldr r1, [r4, #4] @ param 2 
.short 0xf800 



pop {r4} 
pop {r0} 
bx r0 
.ltorg 


.equ GetItemData, 0x80177B0
GetActiveUnitDoorKeySlot:
push {r4-r5, lr} 
ldr r4, =gCurrentUnit 
ldr r4, [r4] 
mov r5, #0x1C 

InvLoop_DoorKey: 
add r5, #2 
cmp r5, #0x28 
bge BreakDoorKeySlot 
ldrb r0, [r4, r5] 
blh GetItemData 
ldrb r1, [r0, #0x1e] @ WhenUsed 
cmp r1, #0x1F @ door key 
beq FoundValidDoorKey 
cmp r1, #0x0E @ unlock staff 
beq FoundValidDoorKey 
cmp r1, #0x20 @ lockpick 
bne InvLoop_DoorKey 
ldr r2, [r4, #4] @ class 
ldr r2, [r2, #0x28] @ ability 
ldr r3, [r4] 
ldr r3, [r4, #0x28] @ ability 
orr r2, r3 
mov r3, #8 @ can use lockpicks 
tst r2, r3 
bne FoundValidDoorKey @ they can use lockpicks 
b InvLoop_DoorKey 

FoundValidDoorKey: 
sub r5, #0x1e 
lsr r0, r5, #1 @ inv slot # 
b ExitDoorKeySlot 

BreakDoorKeySlot: 
mov r0, #0 
sub r0, #1 

ExitDoorKeySlot: 

pop {r4-r5} 
pop {r1} 
bx r1 
.ltorg 



GetActiveUnitChestKeySlot:
push {r4-r5, lr} 
ldr r4, =gCurrentUnit 
ldr r4, [r4] 
mov r5, #0x1C 

InvLoop_ChestKey: 
add r5, #2 
cmp r5, #0x28 
bge BreakChestKeySlot 
ldrb r0, [r4, r5] 
blh GetItemData 
ldrb r1, [r0, #0x1e] @ WhenUsed 
cmp r1, #0x1e @ Chest key 
beq FoundValidChestKey 
cmp r1, #0x26 @ Chest key 2 
beq FoundValidChestKey 
cmp r1, #0x20 @ lockpick 
bne InvLoop_ChestKey 
ldr r2, [r4, #4] @ class 
ldr r2, [r2, #0x28] @ ability 
ldr r3, [r4] 
ldr r3, [r4, #0x28] @ ability 
orr r2, r3 
mov r3, #8 @ can use lockpicks 
tst r2, r3 
bne FoundValidChestKey @ they can use lockpicks 
b InvLoop_ChestKey 

FoundValidChestKey: 
sub r5, #0x1e 
lsr r0, r5, #1 @ inv slot # 
b ExitChestKeySlot 

BreakChestKeySlot: 
mov r0, #0 
sub r0, #1 

ExitChestKeySlot: 

pop {r4-r5} 
pop {r1} 
bx r1 
.ltorg 



.global CanUnitRunToSafety
.type CanUnitRunToSafety, %function 
CanUnitRunToSafety:
push {r4-r7, lr} 
mov r4, r8 
mov r5, r9 
push {r4-r5} 
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
@mov r11, r11 
lsr r3, r5, #1 @ 1/2 
sub r5, r3 @ 1/2 
lsr r3, r5, #1 @ 1/4 
sub r5, r3 @ 1/4 with friendly rounding 
@ r5 = current choice 
@ r6 = xx 
mov r7, #0 @ yy 
sub r7, #1 
ldr r3, =0x202E4D4
ldrh r2, [r3] 
sub r2, #1 @ xx max 
mov r8, r2 
ldrh r3, [r3, #2] 
sub r3, #1 @ yy max 
mov r9, r3 


ldr		r4,=0x202E4E0	@ movement map 
ldr		r4,[r4]			@Offset of map's table of row pointers




NextTile_Y: 
mov r6, #0 
sub r6, #1 
add r7, #1 
cmp r7, r9
bgt False_CanUnitRunToSafety

NextTile_X: 
add r6, #1 
cmp r6, r8 
bgt NextTile_Y 


lsl r0, r7, #2 
add r0, r4
ldr r0, [r0] 
add r0, r6 @ xx 
ldrb r0, [r0] 
cmp r0, #0xFF 
beq NextTile_X
cmp r0, #0 
beq NextTile_X
ldr r1, =gCurrentUnit 
ldr r1, [r1] 
ldr r2, [r1, #4] @ class 
ldrb r2, [r2, #0x12] @ base mov 
ldrb r1, [r1, #0x1D] @ bonus mov 
add r1, r2 
cmp r0, r1 
bgt NextTile_X

 
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

pop {r4-r5} 
mov r8, r4 
mov r9, r5 
pop {r4-r7} 
pop {r1} 
bx r1 
.ltorg 


.global TryMoveIfSafe
.type TryMoveIfSafe, %function 
TryMoveIfSafe: 
push {r4, lr} 

.equ gpAiScriptCurrent, 0x30017D0 
ldr r0, =gpAiScriptCurrent
ldr r0, [r0] 
mov r1, #6 @ safety 
strb r1, [r0, #2] @ safety 


ldr r0, =0x803CE18 
mov lr, r0 
ldr r0, =0x3004E50 
ldr r0, [r0] 
add r0, #0x45
.short 0xf800 

ldr r2, =gCurrentUnit
ldr r2, [r2] 
ldrb r0, [r2, #0x13] @ current hp 
@sub r0, #3
lsr r1, r0, #2
sub r0, r1 @ 3/4 hp 
@mov r11, r11 
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
ldr r0, =AiDecision
ldr r2, [r0] 
cmp r2, #0 
beq SafeEnough 
ldrb r1, [r0, #3] @ yy 
ldrb r0, [r0, #2] @ xx 

ldr		r2,=0x202E4F0	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of map's table of row pointers
lsl		r1,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now we're at the beginning of the row data
add		r2,r0			@add x coordinate
ldrb	r0,[r2]			@load datum at those coordinates
@mov r11, r11 
cmp r0, #0 
beq SafeEnough
cmp r0, r3
bge TooUnsafe
SafeEnough: 
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
@mov r11, r11 
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



