.thumb 

.type InitializeRamHook, %function 
.global InitializeRamHook 
InitializeRamHook: 
mov r11, r11 
bl InitializeCharacterRam
pop {r0} 
bx r0 

.ltorg 

