.thumb
.include "definitions.s"
.global HalfHpFunc
.type HalfHpFunc, %function 
HalfHpFunc: @ for hexing rod 
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r0, r4 @ unit 
bl GetUnitDebuffEntry 
@hp/2 Debuff NOTE TO SELF: off of base only.
ldrb r2, [r0, #MiscByte]
mov r1, #HexBit
tst r2, r1 
beq ExitHp 
lsr r2, r5, #0x1F
add r5, r2
asr r5, #0x1            @Signed divide by two.
ExitHp:
mov r0, r5
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2
.ltorg

.global HalfStrFunc
.type HalfStrFunc, %function 
HalfStrFunc: @ for hexing rod 
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r0, r4 @ unit 
bl GetUnitDebuffEntry 
@str/2 Debuff NOTE TO SELF: off of base only.
ldrb r2, [r0, #MiscByte]
mov r1, #StrBit
tst r2, r1 
beq ExitStr 
lsr r2, r5, #0x1F
add r5, r2
asr r5, #0x1            @Signed divide by two.
ExitStr:
mov r0, r5
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2
.ltorg

.global HalfMagFunc
.type HalfMagFunc, %function 
HalfMagFunc: @ for hexing rod 
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r0, r4 @ unit 
bl GetUnitDebuffEntry 
ldrb r2, [r0, #MiscByte]
mov r1, #MagBit
tst r2, r1 
beq ExitMag
lsr r2, r5, #0x1F
add r5, r2
asr r5, #0x1            @Signed divide by two.
ExitMag:
mov r0, r5
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2
.ltorg


