.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ NextRN_N, 0x8000C80
.equ MakeShop,0x80b4240 @r0 = visiting unit, r1 = shop list(?), r2 = shop type, r3 = parent proc 
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

ShopUsability:
push {lr}
@ldr r0, =ShopTrapID @ turned into byte by bl'd function 
mov r1, #0 @ 0 on tile, 1 adjacent 
bl TrapUsabilityCompletionFlag 
pop {r1} 
bx r1 
.ltorg 

.type ShopTrapUsability, %function 
.type ArmouryTrapUsability, %function 
.type SecretShopTrapUsability, %function 
.global ShopTrapUsability
.global ArmouryTrapUsability
.global SecretShopTrapUsability
ShopTrapUsability:
push {lr} 
ldr r0, =ShopTrapID @ turned into byte by bl'd function 
bl ShopUsability 
pop {r1}
bx r1 
.ltorg 
ArmouryTrapUsability:
push {lr} 
ldr r0, =ArmouryTrapID @ turned into byte by bl'd function 
bl ShopUsability 
pop {r1}
bx r1 
.ltorg 
SecretShopTrapUsability:
push {lr} 
ldr r0, =SecretShopTrapID @ turned into byte by bl'd function 
bl ShopUsability 
pop {r1}
bx r1 
.ltorg 

.type ShopTrapEffect, %function 
.type ArmouryTrapEffect, %function 
.type TrapEffect, %function 
.global ShopTrapEffect
.global ArmouryTrapEffect
.global SecretShopTrapEffect
ShopTrapEffect:
push {lr} 
ldr r1, =ShopTrapID @ turned into byte by bl'd function 
mov r2, #1
bl ShopTrapEffectFunc 
pop {r1}
bx r1 
.ltorg 
ArmouryTrapEffect:
push {lr} 
ldr r1, =ArmouryTrapID @ turned into byte by bl'd function 
mov r2, #0
bl ShopTrapEffectFunc 
pop {r1}
bx r1 
.ltorg 
SecretShopTrapEffect:
push {lr} 
ldr r1, =SecretShopTrapID @ turned into byte by bl'd function 
mov r2, #2
bl ShopTrapEffectFunc 
pop {r1}
bx r1 
.ltorg 


ShopTrapEffectFunc:
@Basically the execute event routine.
push {r4-r6, lr} 
mov r6, r0 @ parent proc 
ldr r0, =CurrentUnit 
ldr r0, [r0] 
@ldr r1, =EnterTrapID 
mov r5, r2 @ what type of shop to create 
bl GetTrapAtUnit 
cmp r0, #0 
beq Continue 
Skip: 
mov r4, r0  @&The DV

mov r0, #29 @ some random # 
mov r1, #4 @ max 
bl HashByte
mov r2, r0 @ shop entry to use 

ldr r0, =CurrentUnit 
ldr r0, [r0] 

cmp r5, #0 
beq LoadArmouryTable
cmp r5, #1 
beq LoadShopTable 
cmp r5, #2 
beq LoadSecretShopTable 
b Continue 
LoadArmouryTable: 
ldr r1, =ArmouryTable 
b Next 
LoadShopTable: 
ldr r1, =ShopTable 
b Next 
LoadSecretShopTable: 
ldr r1, =SecretShopTable 

Next: 
@ldrb r2, [r4, #3] @ shop list id 
lsl r2, #2 @ 4 bytes per 
add r1, r2 
ldr r1, [r1] 
mov r2, r5 @ 0 = armoury, 1 = shop, 2 = secret shop 
mov r3, r6 @ parent proc 
@mov r3, #0 @ if no parent proc 
blh MakeShop, r5 @r0 = visiting unit, r1 = shop list(?), r2 = shop type, r3 = parent proc 

Continue:
ldr r1, =CurrentUnitFateData	@these four lines copied from wait routine
mov r0, #0x10
strb r0, [r1,#0x11]
@mov r0, #0x17	@makes the unit wait?? makes the menu disappear after command is selected??
mov r0,#0x94		@play beep sound & end menu on next frame & clear menu graphics

pop {r4-r6}
pop {r3}
goto_r3:
bx r3
.ltorg 






