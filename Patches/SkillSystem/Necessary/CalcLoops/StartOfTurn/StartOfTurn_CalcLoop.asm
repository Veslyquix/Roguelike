.thumb 

.set gChapterData,                 0x0202BCF0
.global StartOfTurn_CalcLoopHook
.type StartOfTurn_CalcLoopHook, %function 
StartOfTurn_CalcLoopHook: 
@my really ugly hook
push	{lr}
ldr	r1,=#0x8015395
mov	lr,r1
ldr	r2,=gChapterData
ldrb	r0,[r2,#0xF]
mov	r1,pc
add	r1,#7
push	{r1}
cmp	r0,#0x40
bx	lr

StartOfTurn_CalcLoop: 
push	{r4-r6} @ no lr is intentional here lol 

bl ArmorMarch_StartOfTurn 

pop {r4-r6} 
pop	{r0}
bx	r0
.ltorg 

