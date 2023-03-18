.thumb 
mov r4, r0 @ vanilla 
push {r4-r7} 
ldr r7, =0x202BE4C 
ldr r6, =0x202CC9C @ 50th player unit 
ldr r4, =0xC0031 @ custom ai3, atk if within half range
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
mov r1, #0x31 
str r1, [r7] 
mov r1, #0x8 @ destroy walls etc   
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
ldr r1, =0x30031 @ custom ai3, atk if adjacent only 
str r4, [r7] 
mov r1, #0x09 @ previous Random, now RunAway 
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

.global IfUnsafeRunAway
.type IfUnsafeRunAway, %function 
IfUnsafeRunAway:
push {r4, lr} 

ldr r0, =0x803CE18 
mov lr, r0 
ldr r0, =0x3004E50 
ldr r0, [r0] 
add r0, #0x42
.short 0xf800 

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

cmp r0, #0xF 
blt DoNothing 
mov r11, r11 

ldr r0, =0x803CDD4 @ AI Script Function ASM 11 ( Run away ) 
mov lr, r0 
ldr r0, =0x3004E50 
ldr r0, [r0] 
add r0, #0x42
.short 0xf800 

DoNothing: 
mov r0, #1
pop {r4} 
pop {r1} 
bx r1 
.ltorg 


