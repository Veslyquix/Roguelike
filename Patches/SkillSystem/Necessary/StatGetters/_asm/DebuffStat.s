.thumb
.include "definitions.s"
GetDebuffAmount: 
push {r4, lr} 
mov r4, r2 @ stat 
mov r0, r1 @ unit 
bl GetUnitDebuffEntry 
mov r2,r0
ldrsb r0, [r2, r4]
pop {r4} 
pop {r1} 
bx r1 
.ltorg 

.global prDebuffMag
.type prDebuffMag, %function 
prDebuffMag:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #mag 
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg


.global prDebuffStr
.type prDebuffStr, %function 
prDebuffStr:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #str 
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg

.global prDebuffSkl
.type prDebuffSkl, %function 
prDebuffSkl:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #skl
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg


.global prDebuffSpd
.type prDebuffSpd, %function 
prDebuffSpd:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #spd 
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg

.global prDebuffDef
.type prDebuffDef, %function 
prDebuffDef:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #def 
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg

.global prDebuffRes
.type prDebuffRes, %function 
prDebuffRes:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #res
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg

.global prDebuffLuk
.type prDebuffLuk, %function 
prDebuffLuk:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #luk
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg

.global prDebuffMov
.type prDebuffMov, %function 
prDebuffMov:
push {r4-r5, lr}
mov r5, r0 @stat
mov r4, r1 @unit
mov r2, #spd 
bl GetDebuffAmount 
add r0, r5 
mov r1, r4
pop {r4-r5}
pop {r2} 
bx r2 
.ltorg


