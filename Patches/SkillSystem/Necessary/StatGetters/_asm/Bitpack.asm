.thumb 
@ given r0 = address, r1 = bit offset, r2 = number of bits, load only that data 
@ return the data we asked for 
@ top bit of the data makes the whole int negative 
.global UnpackData_Signed 
.type UnpackData_Signed, %function 
UnpackData_Signed: 
push {r4-r5}
mov r4, r1 
cmp r2, #32 
blt NoCapBits 
mov r2, #32 
NoCapBits: 
mov r5, r2 

sub r4, r1 @ starting bit of the offset 
lsr r1, #3 @ 8 bits per byte 
add r0, r1 @ starting address 

mov r3, #7 
add r3, r2 
lsr r3, #3 @ bits / 8 rounded up as # of bytes to load 
@ r3 as the number of bytes to load
cmp r3, #3 
ble NoCap 
mov r3, #3 @ only load up to 4 bytes 
NoCap: 
sub r3, #1 @ 0-indexed 
mov r2, r0 @ starting address 

mov r1, #0 
Loop: 
ldrb r0, [r2, r3] 
sub r3, #1 
lsl r1, #8 
orr r1, r0 
cmp r3, #0 
blt Break 
b Loop 

Break: 
@ r1 has the data we need 
@ r4 = bit to start at 
@ r5 = number of bits to load 
lsr r1, r4 
mov r2, #32 
sub r2, r5 

mov r0, #1 
mov r3, r5 
sub r3, #1 
lsl r0, r3 @ only top bit set 

lsl r1, r2 
lsr r1, r2 @ data we asked for not yet signed 

tst r1, r0 
beq ReturnData
bic r1, r0 @ remove top bit 
mov r0, #0 
sub r0, r1 @ negative 
mov r1, r0 

ReturnData: 
mov r0, r1
pop {r4-r5} 
bx lr
.ltorg 


@ given r0 = address, r1 = bit offset, r2 = number of bits, r3 = data to store
@ return nothing
@ if data exceeds the space, cap it at all bits set for negative, or all bits except top bit if positive 
@ top bit of the data makes the whole int negative 
.global PackData_Signed 
.type PackData_Signed, %function 
PackData_Signed: 
push {r4-r7}


mov r4, r1 
mov r6, r3 @ data to store 

cmp r2, #32 
blt NoCapBitsStore 
mov r2, #32 
NoCapBitsStore: 
mov r5, r2 

sub r4, r1 @ starting bit of the offset 
lsr r1, #3 @ 8 bits per byte 
add r0, r1 @ starting address 


mov r3, #7 
add r3, r2 
lsr r3, #3 @ bits / 8 rounded up as # of bytes to load 
@ r3 as the number of bytes to load
cmp r3, #3 
ble NoCap2 
mov r3, #4 @ only load up to 4 bytes 
NoCap2: 
mov r2, r0 @ starting address 
sub r3, #1 @ 0-indexed 
mov r7, r3 @ number of bytes - 1 

mov r1, #0 
Loop2: 
ldrb r0, [r2, r3] 
sub r3, #1 
lsl r1, #8 
orr r1, r0 
cmp r3, #0 
blt Break2 
b Loop2 

Break2: 
@ r1 has the data we need 
@ r4 = bit to start at 
@ r5 = number of bits to store
mov r0, #1 
mov r3, r5 
sub r3, #1 
lsl r0, r3 @ only top bit set 

cmp r6, #0 
blt Negative 
@ positive 
cmp r6, r0 
blt NoCapStorePositiveData 
sub r0, #1 
mov r6, r0 @ maximum possible positive value 
NoCapStorePositiveData: 
b StoreData 
Negative: 

neg r6, r6 @ swap negative into positive 
mov r3, r6 @ value to add 
cmp r6, r0 
blt NoCapStoreNegativeData
mov r3, r0 
sub r3, #1 @ all bits except top 
NoCapStoreNegativeData: 
add r0, r3 @ capped or just our negative value 
mov r6, r0 @ 

StoreData: 
@ don't lsr chop anything off in loaded data, just bic the bits we are going to store to 
@ remove any set bits in original data 
mov r3, #1 
lsl r3, r5 @ # of bits 
sub r3, #1 @ all bits to remove are set 
bic r1, r3 @ remove any set bits for what we're overwriting 

@ r1 as data 
@ r2 as address to store into 
@ r6 as new data 
lsl r6, r4 @ bit offset 
orr r1, r6 @ new data is here! 

@ now store them back byte by byte 
mov r3, #0 
Loop3: 
strb r1, [r2, r3] 
cmp r3, r7 
bgt Exit 
add r3, #1 
b Loop3 

Exit: 
pop {r4-r7} 
bx lr
.ltorg 













