.thumb

GetDebuffs = EALiterals+0x0
ItemTableLocation = EALiterals+0x4
WeaponDebuffTable = EALiterals+0x8

@push {r0, lr}
@@r5 = attacker
@@r4 = defender
@mov r0, r5
@mov r1, r4
@bl ApplyDebuffs
@mov r0, r4
@mov r1, r5
@bl ApplyDebuffs
@pop {r0}
@@From original routine
@lsl     r0,r0,#0x1
@mov     r1,r4
@add     r1,#0x1E
@add     r0,r0,r1
@add     r1,#0x2A
@ldrh    r1,[r1]
@
@pop {r2}
@BXR2:
@bx r2


.global ApplyWeaponDebuffs 
.type ApplyWeaponDebuffs, %function 
.ltorg 
ApplyWeaponDebuffs:
@ Apply debuffs based on each units weapon 
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
mov r1, #0x80 
tst r0, r1 
beq DontHalveStr 

mov r0, r6 
ldr r1, =HalfStrBitOffset_Link 
ldr r1, [r1] 
@ given r0 = address 
@ r1 = bitoffset 
bl SetBit
b FinishedHalfStr

DontHalveStr: 
@Str was possibly halved so unhalve it (no point checking) 
mov r0, r6 
ldr r1, =HalfStrBitOffset_Link 
ldr r1, [r1] 
@ given r0 = address 
@ r1 = bitoffset 
bl UnsetBit

FinishedHalfStr: 

mov r0, #0x48       @Equipped item after battle
ldrh r0, [r4, r0]   
bl GetWepDebuffByte
mov r1, #0x40 
tst r0, r1 
beq DontHalveMag 

mov r0, r6 
ldr r1, =HalfMagBitOffset_Link 
ldr r1, [r1] 
@ given r0 = address 
@ r1 = bitoffset 
bl SetBit
b FinishedHalfMag

DontHalveMag: 
@Mag was possibly halved so unhalve it (no point checking) 
mov r0, r6 
ldr r1, =HalfMagBitOffset_Link 
ldr r1, [r1] 
@ given r0 = address 
@ r1 = bitoffset 
bl UnsetBit
FinishedHalfMag: 


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
mov r5, r8 
push {r5} 

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
ldr r2, =DebuffNumberOfStats_Link
ldr r1, [r2] @ max 
mov r8, r1 

mov r2, #0x40 @ no 0x40 bitflag of Swap 
ldr r3, =NewWeaponDebuffTable
lsl r4, #2 @ 4 bytes per 
add r4, r3 @ entry we care about 

mov r5, #0 @ counter 
sub r5, #1 

Loop:

mov r2, #0x40 
add r5, #1 
cmp r5, r8 
bge BreakLoop  

ldrsb r3, [r4, r5] @ table data uses a byte per stat 

@ positive affects user 
@ positive swap affects opponent 
@ negative affects enemy 
@ negative swap affects self 

cmp r3, #0 
blt NegativeA 
tst r3, r2 
beq AffectUser
b AffectEnemy

NegativeA: 
tst r3, r2 
beq AffectEnemy 

AffectUser: 
bic r3, r2 @ remove the 0x40 - value to store 
mov r0, r6 @ debuff entry 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r1, r5 @ counter 
mul r1, r2 @ bit offset 
bl PackData_Signed 

b Loop 

AffectEnemy: 
bic r3, r2 @ remove the 0x40 - value to store 
mov r0, r7 @ debuff entry 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r1, r5 @ counter 
mul r1, r2 @ bit offset 
bl PackData_Signed 

b Loop 

BreakLoop: 
pop {r5} 
mov r8, r5 

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

