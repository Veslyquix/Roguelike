.thumb 
.include "definitions.s"
.global prRallyMag
.type prRallyMag, %function
prRallyMag:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #MiscByte  
mov r3, #MagBit 
bl IsRallySet
cmp r0, #0 
beq ExitMag 
ldr r0, =MagRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitMag: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 

AddRallySpectrum: 
push {lr} 
mov r0, r1 @ unit 
bl GetUnitDebuffEntry 
mov r2, r0 
ldrb r2, [r2, #RallyByte] 
mov r3, #SpecBit 
tst r2, r3 
beq AddZero 
ldr r0, =RallySpectrumAmount_Link 
ldr r0, [r0] 

b ExitSpec 
AddZero: 
mov r0, #0 
ExitSpec: 
pop {r1} 
bx r1 
.ltorg 

IsRallySet: 
push {r4-r5, lr} 
mov r4, r2 @ offset of a unit's debuff ram 
mov r5, r3 @ bit 
mov r0, r1 @ unit 
bl GetUnitDebuffEntry 
mov r2, r0 
ldrb r0, [r2, r4] @ byte to check 
tst r0, r5 @ is this bit not set 
beq Exit @ no change 
mov r0, #1 
Exit: 
pop {r4-r5} 
pop {r1} 
bx r1 
.ltorg 



.global prRallyStr
.type prRallyStr, %function
prRallyStr:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #StrBit 
bl IsRallySet
cmp r0, #0 
beq ExitStr 
ldr r0, =StrRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitStr: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 



.global prRallySkl
.type prRallySkl, %function
prRallySkl:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #SklBit 
bl IsRallySet
cmp r0, #0 
beq ExitSkl 
ldr r0, =SklRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitSkl: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 



.global prRallySpd
.type prRallySpd, %function
prRallySpd:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #SpdBit 
bl IsRallySet
cmp r0, #0 
beq ExitSpd 
ldr r0, =SpdRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitSpd: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 



.global prRallyDef
.type prRallyDef, %function
prRallyDef:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #DefBit 
bl IsRallySet
cmp r0, #0 
beq ExitDef 
ldr r0, =DefRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitDef: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 



.global prRallyRes
.type prRallyRes, %function
prRallyRes:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #ResBit 
bl IsRallySet
cmp r0, #0 
beq ExitRes 
ldr r0, =ResRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitRes: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 



.global prRallyLuk
.type prRallyLuk, %function
prRallyLuk:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
bl AddRallySpectrum 
add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #LukBit 
bl IsRallySet
cmp r0, #0 
beq ExitLuk 
ldr r0, =LukRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitLuk: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 



.global prRallyMov
.type prRallyMov, %function
prRallyMov:
push { r4 - r6, lr }
mov r5, r0 @ Stat
mov r4, r1 @ Unit
@bl AddRallySpectrum 
@add r5, r0 
mov r1, r4 
mov r2, #RallyByte 
mov r3, #MovBit 
bl IsRallySet
cmp r0, #0 
beq ExitMov 
ldr r0, =MovRallyAmount_Link 
ldr r0, [r0] 
add r5, r0 
ExitMov: 
mov r0, r5
pop {r4-r6}
pop {r2} 
bx r2 
.ltorg 








