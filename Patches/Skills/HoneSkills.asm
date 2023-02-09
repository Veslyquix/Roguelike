.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ GetUnit, 0x8019430
.equ ChapterData, 0x202BCF0 

@ Hone _ : At the start of your turn, give adjacent allies up to +3 _
@ _ Oath : At the start of your turn, gain up to +4 _ if adjacent to an ally.
@ Rouse _ : At the start of your turn, gain up to +4 _ if not adjacent to an ally.
@ _ Init: Begin the chapter with +7 _. 


@ Cannot die. When they would die, they instead are debuffed by -5 in all stats. (Stackable) 
@.global PlotArmor
@.type PlotArmor, %function 
@PlotArmor: 
@push {r4-r5, lr} 



.equ StrAnim, 0x01 
.equ SklAnim, 0x02 
.equ SpdAnim, 0x04 
.equ DefAnim, 0x08 
.equ ResAnim, 0x10 
.equ LukAnim, 0x20 
.equ MovAnim, 0x40 
.equ SpecAnim, 0x80 
.equ MagAnim, 0x1


.global CleverInit 
.type CleverInit, %function 
CleverInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #MagAnim @ bits 
lsl r1, #8 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Mag @ bit offset 
ldr r1, [r1] 
ldr r2, =CleverInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global StrongInit 
.type StrongInit, %function 
StrongInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #StrAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Str @ bit offset 
ldr r1, [r1] 
ldr r2, =StrongInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global DeftInit 
.type DeftInit, %function 
DeftInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #SklAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Skl @ bit offset 
ldr r1, [r1] 
ldr r2, =DeftInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global QuickInit 
.type QuickInit, %function 
QuickInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #SpdAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Spd @ bit offset 
ldr r1, [r1] 
ldr r2, =QuickInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global LuckyInit 
.type LuckyInit, %function 
LuckyInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #LukAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Luk @ bit offset 
ldr r1, [r1] 
ldr r2, =LuckyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global SturdyInit 
.type SturdyInit, %function 
SturdyInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #DefAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Def @ bit offset 
ldr r1, [r1] 
ldr r2, =SturdyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 



.global CalmInit 
.type CalmInit, %function 
CalmInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #ResAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Res @ bit offset 
ldr r1, [r1] 
ldr r2, =CalmInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global NimbleInit 
.type NimbleInit, %function 
NimbleInit: 
push {lr} 
@ given r0 = unit 
push {r0} 
@ r0 = unit 
mov r1, #MovAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx
pop {r0} 
ldr r1, =DebuffStatBitOffset_Mov @ bit offset 
ldr r1, [r1] 
ldr r2, =NimbleInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
pop {r0} 
bx r0 
.ltorg 

.global SpectrumInit 
.type SpectrumInit, %function 
SpectrumInit: 
push {r4, lr} 
mov r4, r0 @ unit

mov r1, #SpecAnim @ bits 
mov r2, #0 @ range (self) 
bl StartBuffFx

mov r0, r4 @ unit 
ldr r1, =DebuffStatBitOffset_Mag @ bit offset 
ldr r1, [r1] 
ldr r2, =SturdyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Str @ bit offset 
ldr r1, [r1] 
ldr r2, =SturdyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Skl @ bit offset 
ldr r1, [r1] 
ldr r2, =SturdyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Spd @ bit offset 
ldr r1, [r1] 
ldr r2, =SturdyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Def @ bit offset 
ldr r1, [r1] 
ldr r2, =SturdyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Res @ bit offset 
ldr r1, [r1] 
ldr r2, =CalmInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Luk @ bit offset 
ldr r1, [r1] 
ldr r2, =LuckyInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat
mov r0, r4 
ldr r1, =DebuffStatBitOffset_Mov @ bit offset 
ldr r1, [r1] 
ldr r2, =NimbleInitAmount_Link
ldr r2, [r2] 
bl InitiativeForStat



pop {r4} 
pop {r0} 
bx r0 
.ltorg 



InitiativeForStat: 
ldr r3, =ChapterData 
ldrh r3, [r3, #0x10] @ Turn # 
cmp r3, #1 @ turn starts at 1 
beq Proceed 
bx lr @ do nothing if not first turn 
Proceed: 
push {r4-r7, lr} 



mov r4, r0 @ unit 
mov r5, r1 @ bit offset 
mov r6, r2 @ amount 

mov r0, r4 
bl GetUnitDebuffEntry 
mov r7, r0 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
bl UnpackData_Signed 
cmp r0, r6 @ old value vs new value 
bgt NoBuffInitiative 
cmp r0, #0 
bge UseNewValueInitiative 
add r6, r0 @ negative, so reduce the debuff 
UseNewValueInitiative: 
mov r0, r7 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r3, r6 @ value 
bl PackData_Signed 
NoBuffInitiative: @ current stat is higher than what we'd set it to 

pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 



@ HoneStat, OathStat, and RouseStat functions are very similar 
@ Hone loops, Oath and Rouse check if the list is empty or not 

.type HoneStr, %function 
.global HoneStr 
HoneStr: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Str @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneStrAmount_Link 
ldr r2, [r2] 
mov r3, #StrAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathStr, %function 
.global OathStr 
OathStr: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Str @ bit offset 
ldr r1, [r1] 
ldr r2, =OathStrAmount_Link 
ldr r2, [r2] 
mov r3, #StrAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseStr, %function 
.global RouseStr 
RouseStr: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Str @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseStrAmount_Link 
ldr r2, [r2] 
mov r3, #StrAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 


.type HoneMag, %function 
.global HoneMag 
HoneMag: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Mag @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneMagAmount_Link 
ldr r2, [r2] 
mov r3, #MagAnim
lsl r3, #8  
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathMag, %function 
.global OathMag 
OathMag: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Mag @ bit offset 
ldr r1, [r1] 
ldr r2, =OathMagAmount_Link 
ldr r2, [r2] 
mov r3, #MagAnim
lsl r3, #8  
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseMag, %function 
.global RouseMag 
RouseMag: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Mag @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseMagAmount_Link 
ldr r2, [r2] 
mov r3, #MagAnim
lsl r3, #8  
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 


.type HoneSkl, %function 
.global HoneSkl 
HoneSkl: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Skl @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneSklAmount_Link 
ldr r2, [r2] 
mov r3, #SklAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathSkl, %function 
.global OathSkl 
OathSkl: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Skl @ bit offset 
ldr r1, [r1] 
ldr r2, =OathSklAmount_Link 
ldr r2, [r2] 
mov r3, #SklAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseSkl, %function 
.global RouseSkl 
RouseSkl: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Skl @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseSklAmount_Link 
ldr r2, [r2] 
mov r3, #SklAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 


.type HoneSpd, %function 
.global HoneSpd 
HoneSpd: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Spd @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneSpdAmount_Link 
ldr r2, [r2] 
mov r3, #SpdAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathSpd, %function 
.global OathSpd 
OathSpd: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Spd @ bit offset 
ldr r1, [r1] 
ldr r2, =OathSpdAmount_Link 
ldr r2, [r2] 
mov r3, #SpdAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseSpd, %function 
.global RouseSpd 
RouseSpd: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Spd @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseSpdAmount_Link 
ldr r2, [r2] 
mov r3, #SpdAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 



.type HoneDef, %function 
.global HoneDef 
HoneDef: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Def @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneDefAmount_Link 
ldr r2, [r2] 
mov r3, #DefAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathDef, %function 
.global OathDef 
OathDef: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Def @ bit offset 
ldr r1, [r1] 
ldr r2, =OathDefAmount_Link 
ldr r2, [r2] 
mov r3, #DefAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseDef, %function 
.global RouseDef 
RouseDef: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Def @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseDefAmount_Link 
ldr r2, [r2] 
mov r3, #DefAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 


.type HoneRes, %function 
.global HoneRes 
HoneRes: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Res @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneResAmount_Link 
ldr r2, [r2] 
mov r3, #ResAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathRes, %function 
.global OathRes 
OathRes: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Res @ bit offset 
ldr r1, [r1] 
ldr r2, =OathResAmount_Link 
ldr r2, [r2] 
mov r3, #ResAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseRes, %function 
.global RouseRes 
RouseRes: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Res @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseResAmount_Link 
ldr r2, [r2] 
mov r3, #ResAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 



.type HoneLuk, %function 
.global HoneLuk 
HoneLuk: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Luk @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneLukAmount_Link 
ldr r2, [r2] 
mov r3, #LukAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathLuk, %function 
.global OathLuk 
OathLuk: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Luk @ bit offset 
ldr r1, [r1] 
ldr r2, =OathLukAmount_Link 
ldr r2, [r2] 
mov r3, #LukAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseLuk, %function 
.global RouseLuk 
RouseLuk: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Luk @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseLukAmount_Link 
ldr r2, [r2] 
mov r3, #LukAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 


.type HoneMov, %function 
.global HoneMov 
HoneMov: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Mov @ bit offset 
ldr r1, [r1] 
ldr r2, =HoneMovAmount_Link 
ldr r2, [r2] 
mov r3, #MovAnim 
bl HoneStat 
pop {r0} 
bx r0 
.ltorg 

.type OathMov, %function 
.global OathMov 
OathMov: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Mov @ bit offset 
ldr r1, [r1] 
ldr r2, =OathMovAmount_Link 
ldr r2, [r2] 
mov r3, #MovAnim 
bl OathStat 
pop {r0} 
bx r0 
.ltorg 

.type RouseMov, %function 
.global RouseMov 
RouseMov: 
push {lr} 
@ given r0 = unit 
ldr r1, =DebuffStatBitOffset_Mov @ bit offset 
ldr r1, [r1] 
ldr r2, =RouseMovAmount_Link 
ldr r2, [r2] 
mov r3, #MovAnim 
mov r3, #MovAnim 
bl RouseStat 
pop {r0} 
bx r0 
.ltorg 




HoneStat: 
push {r4-r7, lr} 
mov r4, r0 @ unit 
mov r5, r1 @ bit offset 
mov r6, r2 @ amount 
mov r7, r8 
push {r7} 
mov r8, r3 @ rally anim bits 
mov r3, r9 
push {r3} 
mov r9, r4 @ unit 
mov r0, r4 @ unit 

mov r1, #0 @ can trade 
mov r2, #1 @ adjacent 
bl GetUnitsInRange @(Unit* unit, int allyOption, int range)
cmp r0, #0 
beq NoMoreHone
mov r4, r0 

AreaLoop: 
ldrb r0, [r4] 
cmp r0, #0 
beq NoMoreHone 
add r4, #1 
blh GetUnit 
mov r9, r0 
bl GetUnitDebuffEntry 
mov r7, r0 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
bl UnpackData_Signed 
cmp r0, r6 @ old value vs new value 
bgt NoBuff 
mov r3, r6 
cmp r0, #0 
bge UseNewValue 
add r3, r0 @ negative, so reduce the debuff 
UseNewValue: 
mov r0, r7 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
@ r3 = value 
bl PackData_Signed 
mov r0, r9 @ unit 
mov r1, r8 @ rally anim bits 
mov r2, #0 @ range adjacent 
bl StartBuffFx

NoBuff: @ current stat is higher than what we'd set it to 
b AreaLoop 

NoMoreHone: 
pop {r3} 
mov r9, r3 
pop {r7} 
mov r8, r7 
pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 


@ _ Oath : At the start of your turn, gain up to +4 _ if adjacent to an ally.
OathStat: 
push {r4-r7, lr} 
mov r4, r0 @ unit 
mov r5, r1 @ bit offset 
mov r6, r2 @ amount 
mov r7, r8 
push {r7} 
mov r8, r3 @ anim bits 

mov r0, r4 @ unit 
mov r1, #0 @ can trade 
mov r2, #1 @ adjacent 
bl GetUnitsInRange @(Unit* unit, int allyOption, int range)
cmp r0, #0 
beq NoBuff_Oath

mov r0, r4 @ unit 
bl GetUnitDebuffEntry 
mov r7, r0 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
bl UnpackData_Signed 
cmp r0, r6 @ old value vs new value 
bgt NoBuff_Oath
cmp r0, #0 
bge UseNewValue_Oath 
add r6, r0 @ negative, so reduce the debuff 
UseNewValue_Oath: 
mov r0, r7 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r3, r6 @ value 
bl PackData_Signed 

mov r0, r4 @ unit 
mov r1, r8 @ rally anim bits 
mov r2, #0 @ range self 
bl StartBuffFx

NoBuff_Oath: @ current stat is higher than what we'd set it to 

pop {r7} 
mov r8, r7 
pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 



@ Rouse _ : At the start of your turn, gain up to +4 _ if not adjacent to an ally.
RouseStat: 
push {r4-r7, lr} 
mov r4, r0 @ unit 
mov r5, r1 @ bit offset 
mov r6, r2 @ amount 
mov r7, r8 
push {r7} 
mov r8, r3 @ anim bits 


mov r1, #0 @ can trade 
mov r2, #1 @ adjacent 
bl GetUnitsInRange @(Unit* unit, int allyOption, int range)
cmp r0, #0 
bne NoBuff_Rouse

mov r0, r4 @ unit 
bl GetUnitDebuffEntry 
mov r7, r0 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
bl UnpackData_Signed 
cmp r0, r6 @ old value vs new value 
bgt NoBuff_Rouse
cmp r0, #0 
bge UseNewValue_Rouse 
add r6, r0 @ negative, so reduce the debuff 
UseNewValue_Rouse: 
mov r0, r7 @ debuff entry 
mov r1, r5 @ bit offset 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r3, r6 @ value 
bl PackData_Signed 

mov r0, r4 @ unit 
mov r1, r8 @ rally anim bits 
mov r2, #0 @ range self 
bl StartBuffFx

NoBuff_Rouse: @ current stat is higher than what we'd set it to 

pop {r7} 
mov r8, r7 
pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 


@GetUnitsInRange @(Unit* unit, int allyOption, int range)
@
@@get nearby units
@ldr	r0,AuraSkillCheck
@mov	lr,r0
@mov	r0,r5		@unit to check
@mov	r1,#0
@mov	r2,#0		@can_trade
@mov	r3,#1		@range
@.short	0xf800
@
@@check if any nearby unit is an armor
@ldr	r6,=#0x202B256	@bugger for the nearby units









