.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ MemorySlot,0x30004B8
.equ GetTrapAt,0x802e1f0
.equ gTerrainMap, 0x202E4DC
.equ MapSize, 0x202E4D4
.equ RemoveUnitBlankItems,0x8017984
.equ CheckEventId,0x8083da8
.equ GetItemAfterUse, 0x08016AEC
.equ SetFlag, 0x8083D80
.equ gMapUnit, 0x202E4D8
.equ CurrentUnit, 0x3004E50 
.equ GetTrap, 0x802EB8C
.equ SpawnTrap,0x802E2B8 @r0 = x coord, r1 = y coord, r2 = trap ID


.equ UpdateAllLightRunes, 0x802E470
.equ AddTrap, 0x802E2B8 
.equ gActionStruct, 0x203A958 




.type UpdateShopTraps, %function 
.global UpdateShopTraps
UpdateShopTraps: 
push {r4-r7, lr} 
ldr r6, =gTerrainMap 
ldr r6, [r6] 
ldr r4, =MapSize 
ldrh r5, [r4, #2] @ YY 
sub r5, #1 
ldrh r4, [r4] @ XX 

mov r3, #0 @ YY 
sub r3, #1 
YLoop: 
add r3, #1 
cmp r3, r5 
bgt Break 
mov r2, #0 
sub r2, #1 
XLoop: 
add r2, #1 
cmp r2, r4 
bgt YLoop
lsl r1, r3, #2 @ y * 4 
add r1, r6 @ location of X row 
ldr r1, [r1] 
add r1, r2 @ address of terrain 
ldrb r1, [r1] 
cmp r1, #6 @ is this a shop? 
beq FoundArmoury
cmp r1, #7 
beq FoundShop 
b XLoop 
FoundShop: 

push {r2-r3} 
mov r0, r2 
mov r1, r3 
blh GetTrapAt
pop {r2-r3} 
cmp r0, #0 
bne XLoop 
mov r0, r2 @ xx 
push {r2-r4}
ldr r2, =ShopTrapID 
b CreateShop 

FoundArmoury: 
push {r2-r3} 
mov r0, r2 
mov r1, r3 
blh GetTrapAt
pop {r2-r3} 
cmp r0, #0 
bne XLoop 
mov r0, r2 @ xx
push {r2-r4} 
ldr r2, =ArmouryTrapID 
b CreateShop 


CreateShop: 
mov r1, r3 @ yy 
 

lsl r2, #24 
lsr r2, #24 
mov r3, #0 
blh AddTrap, r4 
pop {r2-r4}  

b XLoop 

Break: 
mov r0, #0 
blh GetTrap 
mov r3, r0 
ldrb r0, [r3, #2] 

pop {r4-r7} 
pop {r1} 
ldr r1, =0x801A1B1 
bx r1
.ltorg 


