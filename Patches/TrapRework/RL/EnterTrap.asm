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








.type EnterTextUsability, %function 
.global EnterTextUsability 

EnterTextUsability:
push {lr}
@ldr r0, =EnterTrapID @ turned into byte by bl'd function 
mov r1, #0 @ 0 on tile, 1 adjacent 
bl TrapUsabilityCompletionFlag 
pop {r1} 
bx r1 
.ltorg 

.type CGTextTrapUsability, %function 
.type RegTextTrapUsability, %function 
.type TutTextTrapUsability, %function 
.type WallTextTrapUsability, %function 
.global CGTextTrapUsability
.global RegTextTrapUsability
.global TutTextTrapUsability
.global WallTextTrapUsability
CGTextTrapUsability:
push {lr} 
ldr r0, =CGTextEnterTrapID @ turned into byte by bl'd function 
bl EnterTextUsability 
pop {r1}
bx r1 
.ltorg 
RegTextTrapUsability:
push {lr} 
ldr r0, =RegTextEnterTrapID @ turned into byte by bl'd function 
bl EnterTextUsability 
pop {r1}
bx r1 
.ltorg 
TutTextTrapUsability:
push {lr} 
ldr r0, =TutTextEnterTrapID @ turned into byte by bl'd function 
bl EnterTextUsability 
pop {r1}
bx r1 
.ltorg 
WallTextTrapUsability:
push {lr} 
ldr r0, =WallTextEnterTrapID @ turned into byte by bl'd function 
bl EnterTextUsability 
pop {r1}
bx r1 
.ltorg 

.type CGTextTrapEffect, %function 
.type RegTextTrapEffect, %function 
.type TutTextTrapEffect, %function 
.type WallTextTrapEffect, %function 
.global CGTextTrapEffect
.global RegTextTrapEffect
.global TutTextTrapEffect
.global WallTextTrapEffect
CGTextTrapEffect:
push {lr} 
ldr r1, =CGTextEnterTrapID @ turned into byte by bl'd function 
mov r2, #1
bl EnterTextEffect 
pop {r1}
bx r1 
.ltorg 
RegTextTrapEffect:
push {lr} 
ldr r1, =RegTextEnterTrapID @ turned into byte by bl'd function 
mov r2, #2
bl EnterTextEffect 
pop {r1}
bx r1 
.ltorg 
TutTextTrapEffect:
push {lr} 
ldr r1, =TutTextEnterTrapID @ turned into byte by bl'd function 
mov r2, #3
bl EnterTextEffect 
pop {r1}
bx r1 
.ltorg 
WallTextTrapEffect:
push {lr} 
ldr r1, =WallTextEnterTrapID @ turned into byte by bl'd function 
mov r2, #4
bl EnterTextEffect 
pop {r1}
bx r1 
.ltorg 



EnterTextEffect:
@Basically the execute event routine.
push {r4-r5, lr} 
ldr r0, =CurrentUnit 
ldr r0, [r0] 
@ldr r1, =EnterTrapID 
mov r5, r2 @ what type of text to show 
bl GetTrapAtUnit 
cmp r0, #0 
beq Continue 
Skip: 
mov r4, r0  @&The DV
mov r1, #0x4 
ldrh r2, [r4, r1]     @textID
cmp r2, #0
beq Continue 
ldr r1,=MemorySlot
str r2,[r1, #4*2]		@overwrite s2



cmp r5, #1 
beq CGText 
cmp r5, #2
beq RegText 
cmp r5, #3 
beq TutText 
cmp r5, #4 
beq WallText 
b Continue 

CGText:
ldr r0, =ShowTextEvent
b DoTheEvent

WallText:
ldr r0, =WallTextEvent
b DoTheEvent
RegText:
ldr r0, =TextEvent
b DoTheEvent
TutText:
ldr	r0, =TutTextEvent	

DoTheEvent:
mov	r1, #0x01		@0x01 = wait for events
blh EventEngine 
b Continue 

DeleteTrap:
@Remove the DV trap from the map.
mov r0, r4
blh RemoveTrap

Continue:
ldr r1, =CurrentUnitFateData	@these four lines copied from wait routine
mov r0, #0x10
strb r0, [r1,#0x11]
@mov r0, #0x17	@makes the unit wait?? makes the menu disappear after command is selected??
mov r0,#0x94		@play beep sound & end menu on next frame & clear menu graphics

pop {r4-r5}
pop {r3}
goto_r3:
bx r3
.ltorg 






