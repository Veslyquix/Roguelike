.thumb

.macro blh2 to, reg=r3
	ldr \reg, \to
	mov lr, \reg
	.short 0xF800
.endm

.type RelicsMag, %function 
.global RelicsMag 
RelicsMag:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsMagRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsStr, %function 
.global RelicsStr 
RelicsStr:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsStrRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsSkl, %function 
.global RelicsSkl 
RelicsSkl:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsSklRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsSpd, %function 
.global RelicsSpd 
RelicsSpd:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsSpdRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsDef, %function 
.global RelicsDef 
RelicsDef:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsDefRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsRes, %function 
.global RelicsRes 
RelicsRes:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsResRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsLuk, %function 
.global RelicsLuk 
RelicsLuk:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsLukRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsHP, %function 
.global RelicsHP 
RelicsHP:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsHPRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsMov, %function 
.global RelicsMov 
RelicsMov:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsMovRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg

.type RelicsCon, %function 
.global RelicsCon 
RelicsCon:
push {r4, lr}
@r0 stat
mov r4, r1 @unit
ldr r2, =RelicsConRam_Link
bl ApplyRelicsPlayer
mov r1, r4
pop {r4}
pop {r2} 
bx r2 
.ltorg


ApplyRelicsPlayer:
ldrb r3, [r1, #0x0B] 
lsr r3, #6 
cmp r3, #0 
bne NotPlayer
ldr r2, [r2] @ the ram address 
mov r3, #0 
ldrsb r3, [r2, r3] 
add r0, r3 
NotPlayer: 
bx lr
.ltorg 

.global CallFunction 
.type CallFunction, %function 
CallFunction:
push {lr} 
mov lr, r0 
.short 0xf800 
pop {r0} 
bx r0 
.ltorg 


.global SlimBuildFunc
.type SlimBuildFunc, %function 
SlimBuildFunc:
bx lr 
.ltorg 
.global WeaponsExpertFunc
.type WeaponsExpertFunc, %function 
WeaponsExpertFunc:
bx lr 
.ltorg 
.global HawkeyeFunc
.type HawkeyeFunc, %function 
HawkeyeFunc:
bx lr 
.ltorg 

.global CelerityFunc
.type CelerityFunc, %function 
CelerityFunc:
ldr r3, =RelicsMovRam_Link 
ldr r3, [r3] 
mov r1, #0 
ldrsb r0, [r3, r1] 
add r0, #1 
strb r0, [r3] 
bx lr 
.ltorg 


