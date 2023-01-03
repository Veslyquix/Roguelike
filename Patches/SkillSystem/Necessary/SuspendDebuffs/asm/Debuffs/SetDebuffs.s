.thumb

GetDebuffs = EALiterals+0x0
ItemTableLocation = EALiterals+0x4
WeaponDebuffTable = EALiterals+0x8

push {r0, lr}
@r5 = attacker
@r4 = defender
mov r0, r5
mov r1, r4
bl ApplyDebuffs
mov r0, r4
mov r1, r5
bl ApplyDebuffs
pop {r0}
@From original routine
lsl     r0,r0,#0x1
mov     r1,r4
add     r1,#0x1E
add     r0,r0,r1
add     r1,#0x2A
ldrh    r1,[r1]

pop {r2}
BXR2:
bx r2

.ltorg 
ApplyDebuffs:
@First apply own debuffs
push {r4-r7,lr}
mov r4, r0          @r4 = unit to update
mov r5, r1          @r5 = other unit

bl GetUnitDebuffEntry 
mov r6,r0

mov r0, r5 @ other unit 
bl GetUnitDebuffEntry 
mov r7, r0 

mov r0, #0x48       @Equipped item after battle
ldrh r0, [r4, r0]   
bl GetWepDebuffByte
ldrb r1, [r6, #11]
mov r2, #0x1       @str/2 for status data
and r2, r1
cmp r2, #0x0
beq checkHalveStrength
@Str was already halved so unhalve it.
mov r2, #0xFE
and r1, r2
strb r1, [r6, #11]
b magicHalvingDebuff
checkHalveStrength:
mov r1, #0x80       @str/2 for weapon debuff data.
and r1, r0
cmp r1, #0x0        @No str/2 debuff
beq magicHalvingDebuff
ldrb r1, [r6, #11] @reload the debuff
mov r2, #0x1       @set the str/2 bit
orr r1, r2
strb r1, [r6, #11]

magicHalvingDebuff:
@TODO: Implement mag/2 debuffs

mov r0, #0x48       @Equipped item after battle
ldrh r0, [r4, r0]   
bl GetWepDebuffByte
@r0 @wep debuff byte 
mov r1, r4 @ unit 
mov r2, r6 @ ram 
mov r3, r7 @ ram 
bl OverwriteDebuffs 

mov r0, #0x48       @Equipped item after battle
ldrh r0, [r5, r0]   
bl GetWepDebuffByte
mov r1, #0x1F
and r0, r1 @wep debuff byte 
mov r1, r5 @ unit 
mov r2, r7 @ ram 
mov r3, r6 @ ram 
bl OverwriteDebuffs 


pop {r4-r7}
pop {r0}
bx r0
.ltorg 

OverwriteDebuffs: 
push {r4-r7, lr} 
mov r4, #0x1f 
and r4, r0 @ wep debuff entry 

mov r5, r1 @ unit 
mov r6, r2 @ unitA debuff ram 
mov r7, r3 @ unitB debuff ram 

mov r0, #0x7C       @damage/hit data
ldrb r0, [r5, r0]
mov r1, #0x2
and r0, r1

ldr r1, =RequireDamageToDebuff_Link 
ldr r1, [r1] 
cmp r1, #1 
bne AlwaysDebuff

cmp r0, #0x0
beq BreakLoop
AlwaysDebuff:


ldr r2, =DebuffEntrySize_Link
ldr r1, [r2] @ max 
mov r2, #0x40 @ no 0x40 bitflag of Swap 
ldr r3, =NewWeaponDebuffTable
lsl r4, #2 @ 4 bytes per 
add r4, r3 @ entry we care about 

mov r3, #0 @ counter 
sub r3, #1 

Loop:
add r3, #1 
cmp r3, r1 
bge BreakLoop  

ldrsb r0, [r4, r3] 

@ positive affects user 
@ positive swap affects opponent 
@ negative affects enemy 
@ negative swap affects self 

cmp r0, #0 
blt NegativeA 
tst r0, r2 
beq AffectUser
b AffectEnemy

NegativeA: 
tst r0, r2 
beq AffectEnemy 
@b AffectUser 

AffectUser: 
bic r0, r2 @ remove the 0x40 
strb r0, [r6, r3] 
b Loop 

AffectEnemy: 
bic r0, r2 @ remove the 0x40 
strb r0, [r7, r3] 
b Loop 

BreakLoop: 

pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 





GetWepDebuffByte: @ r0 = weapon id 
mov r1, #0xFF
and r0, r1
ldr r2, ItemTableLocation
mov r1, #0x24
mul r0, r1
add r2, r0          @r2 = &Item Data
mov r0, #0x21       @Offset of debuff data
ldrb r0, [r2, r0]
@r0 = debuff data.
bx lr 
.ltorg 

.align
EALiterals:
@.long GetDebuffs
@.long ItemTableLocation
@.long WeaponDebuffTable

@ ExtraDataLocation:
@ .long 0x0203F100
@ ItemTableLocation:
@ .long 0x08809B10
@ DebuffTableLocation:
@.long 0xDEADBEEF

