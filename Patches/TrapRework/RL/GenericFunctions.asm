.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ MakeShop,0x80b4240 @r0 = visiting unit, r1 = shop list(?), r2 = shop type, r3 = ???
.equ MemorySlot,0x30004B8
.equ GetTrapAt,0x802e1f0
.equ CheckEventId,0x8083da8
.equ SetFlag, 0x8083D80
.equ SpawnTrap,0x802E2B8 @r0 = x coord, r1 = y coord, r2 = trap ID
.equ Init_ReturnPoint,0x8037901
.equ CurrentUnit, 0x3004E50
.equ RemoveTrap, 0x802EA90 
.equ EventEngine, 0x800D07C 
.equ CurrentUnitFateData, 0x203A958

.type TrapUsabilityCompletionFlag, %function 
.global TrapUsabilityCompletionFlag 
TrapUsabilityCompletionFlag: 
push {r4-r5, lr} 
mov r2, r1 @ adjacent true? 
lsl r1, r0, #24 
lsr r1, #24 @ trap ID 
ldr r0, =CurrentUnit 
ldr r5,[r0]
mov r0, r5 

cmp r2, #1 
beq AdjacentInstead 
bl GetTrapAtUnit
b GotTrap 
AdjacentInstead: 
bl GetAdjacentTrap 

GotTrap: 
mov r4, r0  @&The DV

cmp r0,#0
beq Usability_RetFalse


ldrb r0, [r4, #0x3]     @Completion flag
blh CheckEventId 
cmp r0, #0
bne Usability_RetFalse

@can't use if cantoing
ldr r0,[r5,#0xC]
mov r1,#0x40
and r0,r1
cmp r0,#0
beq Usability_RetTrue

Usability_RetFalse:
mov r0,#3
b Usability_GoBack

Usability_RetTrue:
mov r0,#1


Usability_GoBack:
pop {r4-r5}
pop {r1}
bx r1
.ltorg 

.type GetTrapAtUnit, %function 
.global GetTrapAtUnit 
GetTrapAtUnit: 
push {r4-r7,r14}

mov r4,r0	@r0 = unit we're checking for adjacency to
lsl r7, r1, #24 
lsr r7, #24 @r1 = trap ID to check for 	
ldrb r5,[r4,#0x10] @x coord
ldrb r6,[r4,#0x11] @y coord


mov r0,r5
mov r1,r6
blh GetTrapAt
cmp r0, #0 
beq ReturnFalse2
ldrb r1,[r0,#2]

mov r2, r7
cmp r1, r2
beq RetTrapIndividual
ReturnFalse2:
mov r0,#0x0	@no trap so return 0x0

RetTrapIndividual:
pop {r4-r7}
pop {r1}
bx r1

.ltorg 


.type GetAdjacentTrap, %function 
.global GetAdjacentTrap 
GetAdjacentTrap: 
push {r4-r7,r14}
mov r4, r0 @r0 = unit we're checking for adjacency to
mov r7, r1 @r1 = trap ID we want to match to 
ldrb r5,[r4,#0x10] @x coord
ldrb r6,[r4,#0x11] @y coord


mov r0,r5
sub r0,#1
mov r1,r6
blh GetTrapAt
cmp r0, #0 
beq SkipLeft 
ldrb r1,[r0,#2]
cmp r1, r7
beq RetTrap

SkipLeft: 
mov r0,r5
mov r1,r6
sub r1,#1
blh GetTrapAt
cmp r0, #0 
beq SkipAbove 
ldrb r1,[r0,#2]
cmp r1, r7
beq RetTrap
SkipAbove: 
mov r0,r5
add r0,#1
mov r1,r6
blh GetTrapAt
cmp r0, #0 
beq SkipRight 
ldrb r1,[r0,#2]
cmp r1, r7
beq RetTrap
SkipRight: 
mov r0,r5
mov r1,r6
add r1,#1
blh GetTrapAt
cmp r0, #0 
beq SkipBelow 
ldrb r1,[r0,#2]
cmp r1, r7
beq RetTrap
SkipBelow: 
mov r0,#0	@no trap so return 0


RetTrap:
pop {r4-r7}
pop {r1}
bx r1

.ltorg

.global CompletionFlagTrapInitialization
.type CompletionFlagTrapInitialization, %function
CompletionFlagTrapInitialization:
mov r0, #0x3
ldrb r0, [r5, r0]     @Completion flag
blh CheckEventId
cmp r0, #1 
beq ReturnPoint @if completion flag is true, then we do not spawn this trap :-) 

@r5 = pointer to trap data in events
ldrb r0,[r5,#1] @x coord
ldrb r1,[r5,#2] @y coord
ldrb r2,[r5] @trap ID
blh SpawnTrap @returns pointer to trap data in RAM

@give it our data
ldrb r1,[r5,#3] @save byte 0x3
strb r1,[r0,#3] 
ldrb r1,[r5,#4] @save byte 0x4
strb r1,[r0,#4]
ldrb r1,[r5,#5] @save byte 0x5
strb r1,[r0,#5]

ReturnPoint:
ldr r3,=Init_ReturnPoint
bx r3

.ltorg 












