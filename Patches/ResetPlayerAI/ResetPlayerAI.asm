.thumb 
mov r4, r0 @ vanilla 
ldr r3, =0x202BE8C 
ldr r2, =0x202CC9C // final player unit 
mov r0, #0x31 @ ai3  
Loop: 
str r0, [r3] 
add r3, #0x48 
cmp r3, r2 
bge Break 
b Loop
Break: 
@ give all players a vulnerary 
push {r4} 
ldr r3, =0x202BE6A 
ldr r2, =0x202CC8A 
mov r4, #3 
lsl r4, #8 
mov r1, #0x6C @ vuln 
orr r4, r1 
UnitLoop: 
mov r1, #0
sub r1, #2 
add r3, #0x48 
cmp r3, r2 
bgt BreakUnitLoop 
InvLoop: 
add r1, #2 
cmp r1, #10
bge UnitLoop 
ldrb r0, [r3, r1] 
cmp r0, #0x6C 
beq UnitLoop 
cmp r0, #0 
bne InvLoop 
strh r4, [r3, r1] 
b UnitLoop 

BreakUnitLoop: 
pop {r4} 
ldr r3, =0x8083ED5 
bx r3 
.ltorg 

