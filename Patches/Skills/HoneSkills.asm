.thumb 

@ Hone _ : At the start of your turn, give adjacent allies up to +3 _
@ _ Oath : At the start of your turn, gain up to +4 _ if adjacent to an ally.
@ Rouse _ : At the start of your turn, gain up to +4 _ if not adjacent to an ally.

.type HoneStr, %function 
.global HoneStr 

HoneStr: 
push {r4, lr} 

mov r4, r0 @ unit 
bl GetUnitDebuffEntry 
ldr r1, =DebuffStatBitOffset_Str @ bit offset 
ldr r1, [r1] 
ldr r2, =DebuffStatNumberOfBits_Link
ldr r2, [r2] 
mov r3, #9 
bl PackData_Signed 
pop {r4} 
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









