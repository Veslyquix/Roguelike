.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ GetGameClock, 0x8000D28 
.type SaveGameSeed, %function 
.global SaveGameSeed 
SaveGameSeed: 
push {lr} 
blh GetGameClock 
ldr r3, =StartTimeSeedRamLabel
ldr r3, [r3] 
str r0, [r3] 
pop {r0} 
bx r0 
.ltorg 


.equ UnitLoadBufferAddress, 0x203EFB8
.equ EndOfRam, 0x2040000 
.type InitLoadBufferRam, %function 
.global InitLoadBufferRam 
InitLoadBufferRam: 
ldr r2, =UnitLoadBufferAddress-4
ldr r3, =EndOfRam 
mov r0, #0 
Loop:
add r2, #4 
cmp r2, r3 
bge Break 
str r0, [r2] 
b Loop 
Break: 



bx lr 
.ltorg 

