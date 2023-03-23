	.cpu arm7tdmi
	.arch armv4t
	.fpu softvfp
	.eabi_attribute 20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute 21, 1	@ Tag_ABI_FP_exceptions
	.eabi_attribute 23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute 24, 1	@ Tag_ABI_align8_needed
	.eabi_attribute 25, 1	@ Tag_ABI_align8_preserved
	.eabi_attribute 26, 1	@ Tag_ABI_enum_size
	.eabi_attribute 30, 2	@ Tag_ABI_optimization_goals
	.eabi_attribute 34, 0	@ Tag_CPU_unaligned_access
	.eabi_attribute 18, 4	@ Tag_ABI_PCS_wchar_t
	.file	"ai-fast-danger.c"
@ GNU C17 (devkitARM release 59) version 12.2.0 (arm-none-eabi)
@	compiled by GNU C version 10.3.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.18-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed: -mcpu=arm7tdmi -mthumb -mthumb-interwork -mtune=arm7tdmi -mlong-calls -march=armv4t -O2
	.text
	.align	1
	.p2align 2,,3
	.global	NuAiFillDangerMap
	.syntax unified
	.code	16
	.thumb_func
	.type	NuAiFillDangerMap, %function
NuAiFillDangerMap:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, lr}	@
	mov	lr, fp	@,
	mov	r7, r10	@,
	mov	r6, r9	@,
	mov	r5, r8	@,
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	movs	r3, #24	@ res,
@ ai-fast-danger.c:33: {
	push	{r5, r6, r7, lr}	@
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	ldr	r7, .L27	@ tmp171,
	ldr	r0, [r7]	@ gActiveUnit.0_1, gActiveUnit
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	ldrsb	r3, [r0, r3]	@ res,* res
@ ai-fast-danger.c:33: {
	sub	sp, sp, #44	@,,
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	str	r3, [sp, #24]	@ res, %sfp
@ ai-fast-danger.c:38: 	int def = gActiveUnit->def; 
	movs	r3, #23	@ def,
	ldrsb	r3, [r0, r3]	@ def,* def
	str	r3, [sp, #36]	@ def, %sfp
@ ai-fast-danger.c:39: 	int spd = GetUnitEffSpd(gActiveUnit); 
	bl	GetUnitEffSpd		@
	movs	r3, #191	@ _74,
	lsls	r3, r3, #2	@ _74, _74,
	mov	fp, r3	@ _74, _74
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	ldr	r3, .L27+4	@ tmp175,
	ldr	r6, .L27+8	@ ivtmp.25,
	str	r3, [sp, #20]	@ tmp175, %sfp
@ ai-fast-danger.c:64: 			u32 atrb = GetItemAttributes(item); 
	ldr	r3, .L27+12	@ tmp176,
@ ai-fast-danger.c:39: 	int spd = GetUnitEffSpd(gActiveUnit); 
	str	r0, [sp, #28]	@ tmp178, %sfp
@ ai-fast-danger.c:64: 			u32 atrb = GetItemAttributes(item); 
	str	r3, [sp, #32]	@ tmp176, %sfp
	add	fp, fp, r6	@ _74, ivtmp.25
	b	.L12		@
.L3:
@ ai-fast-danger.c:41:     for (i = 1; i < 0xC0; ++i)
	adds	r6, r6, #4	@ ivtmp.25,
	cmp	r6, fp	@ ivtmp.25, _74
	beq	.L26		@,
.L12:
@ ai-fast-danger.c:43:         struct Unit* unit = gUnitLookup[i];
	ldr	r4, [r6]	@ unit, MEM[(struct Unit * *)_72]
@ ai-fast-danger.c:45: 		if (!IsUnitOnField(unit)) {
	movs	r0, r4	@, unit
	bl	IsUnitOnField		@
@ ai-fast-danger.c:45: 		if (!IsUnitOnField(unit)) {
	cmp	r0, #0	@ tmp179,
	beq	.L3		@,
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	ldr	r3, [sp, #20]	@ tmp175, %sfp
	ldrb	r2, [r3]	@ gActiveUnitId, gActiveUnitId
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	movs	r3, #11	@ tmp158,
	ldrsb	r3, [r4, r3]	@ tmp158,
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	lsrs	r2, r2, #7	@ tmp156, gActiveUnitId,
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	asrs	r3, r3, #31	@ tmp160, tmp158,
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	cmp	r2, r3	@ tmp156, tmp160
	beq	.L3		@,
@ ai-fast-danger.c:57: 		int unit_power = GetUnitPower(unit);
	movs	r0, r4	@, unit
	bl	GetUnitPower		@
	movs	r3, #40	@ _67,
	mov	r9, r3	@ _67, _67
@ ai-fast-danger.c:55:         int might = 0;
	movs	r3, #0	@ might,
	add	r9, r9, r4	@ _67, unit
	movs	r5, r4	@ ivtmp.15, unit
	mov	r10, r7	@ tmp171, tmp171
@ ai-fast-danger.c:54:         int item = 0;
	mov	r8, r3	@ item, item
	mov	r7, r9	@ _67, _67
	mov	r9, r6	@ ivtmp.25, ivtmp.25
	movs	r6, r4	@ unit, unit
@ ai-fast-danger.c:57: 		int unit_power = GetUnitPower(unit);
	str	r0, [sp, #16]	@ tmp180, %sfp
	str	r3, [sp, #12]	@ might, %sfp
	adds	r5, r5, #30	@ ivtmp.15,
.L5:
@ ai-fast-danger.c:59:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	ldrh	r4, [r5]	@ item_tmp, MEM[(short unsigned int *)_5]
@ ai-fast-danger.c:59:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	cmp	r4, #0	@ item_tmp,
	beq	.L9		@,
@ ai-fast-danger.c:61:             if (!CanUnitUseWeapon(unit, item_tmp)) {
	movs	r1, r4	@, item_tmp
	movs	r0, r6	@, unit
	bl	CanUnitUseWeapon		@
@ ai-fast-danger.c:61:             if (!CanUnitUseWeapon(unit, item_tmp)) {
	cmp	r0, #0	@ tmp181,
	beq	.L8		@,
@ ai-fast-danger.c:64: 			u32 atrb = GetItemAttributes(item); 
	ldr	r3, [sp, #32]	@ tmp176, %sfp
	mov	r0, r8	@, item
	bl	.L29		@
@ ai-fast-danger.c:66: 			if (atrb & IA_MAGIC) { battle_def = res; }
	movs	r3, #2	@ tmp212,
@ ai-fast-danger.c:66: 			if (atrb & IA_MAGIC) { battle_def = res; }
	ldr	r2, [sp, #24]	@ battle_def, %sfp
@ ai-fast-danger.c:66: 			if (atrb & IA_MAGIC) { battle_def = res; }
	tst	r3, r0	@ tmp212, tmp182
	bne	.L7		@,
@ ai-fast-danger.c:65: 			int battle_def = def; 
	ldr	r2, [sp, #36]	@ battle_def, %sfp
.L7:
@ ai-fast-danger.c:69:             int might_tmp = GetItemEffMight(item_tmp, unit_power, battle_def, spd, unit); 
	ldr	r3, [sp, #28]	@, %sfp
	movs	r0, r4	@, item_tmp
	str	r6, [sp]	@ unit,
	ldr	r1, [sp, #16]	@, %sfp
	bl	GetItemEffMight		@
@ ai-fast-danger.c:71:             if (might_tmp > might)
	ldr	r3, [sp, #12]	@ might, %sfp
	cmp	r3, r0	@ might, might_tmp
	bge	.L8		@,
	mov	r8, r4	@ item, item_tmp
	str	r0, [sp, #12]	@ might_tmp, %sfp
.L8:
@ ai-fast-danger.c:59:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	adds	r5, r5, #2	@ ivtmp.15,
	cmp	r5, r7	@ ivtmp.15, _67
	bne	.L5		@,
.L9:
@ ai-fast-danger.c:78:         if (item == 0) {
	mov	r3, r8	@ item, item
	movs	r4, r6	@ unit, unit
	mov	r7, r10	@ tmp171, tmp171
	mov	r6, r9	@ ivtmp.25, ivtmp.25
	cmp	r3, #0	@ item,
	beq	.L3		@,
@ ai-fast-danger.c:81:         if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
	mov	r2, r8	@, item
	movs	r1, r4	@, unit
	ldr	r0, [r7]	@ gActiveUnit, gActiveUnit
	bl	CouldUnitBeInRangeHeuristic		@
@ ai-fast-danger.c:81:         if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
	cmp	r0, #0	@ tmp184,
	beq	.L3		@,
@ ai-fast-danger.c:85:         FillMovementAndRangeMapForItem(unit, item);
	movs	r0, r4	@, unit
	mov	r1, r8	@, item
	bl	FillMovementAndRangeMapForItem		@
@ ai-fast-danger.c:92: 		if (unit_power < 2) { unit_power = 2; } 
	ldr	r0, [sp, #16]	@ unit_power, %sfp
	cmp	r0, #2	@ unit_power,
	bge	.L11		@,
	movs	r0, #2	@ unit_power,
.L11:
@ ai-fast-danger.c:93: 		NuAiFillDangerMap_ApplyDanger(unit_power / 2); // minimum of 1 unit power 
	ldr	r3, .L27+16	@ tmp169,
	asrs	r0, r0, #1	@ tmp168, unit_power,
@ ai-fast-danger.c:41:     for (i = 1; i < 0xC0; ++i)
	adds	r6, r6, #4	@ ivtmp.25,
@ ai-fast-danger.c:93: 		NuAiFillDangerMap_ApplyDanger(unit_power / 2); // minimum of 1 unit power 
	bl	.L29		@
@ ai-fast-danger.c:41:     for (i = 1; i < 0xC0; ++i)
	cmp	r6, fp	@ ivtmp.25, _74
	bne	.L12		@,
.L26:
@ ai-fast-danger.c:98: 	return GetCurrDanger(); 
	bl	GetCurrDanger		@
@ ai-fast-danger.c:99: }
	add	sp, sp, #44	@,,
	@ sp needed	@
	pop	{r4, r5, r6, r7}
	mov	fp, r7
	mov	r10, r6
	mov	r9, r5
	mov	r8, r4
	pop	{r4, r5, r6, r7}
	pop	{r1}
	bx	r1
.L28:
	.align	2
.L27:
	.word	gActiveUnit
	.word	gActiveUnitId
	.word	gUnitLookup+4
	.word	GetItemAttributes
	.word	NuAiFillDangerMap_ApplyDanger
	.size	NuAiFillDangerMap, .-NuAiFillDangerMap
	.ident	"GCC: (devkitARM release 59) 12.2.0"
	.code 16
	.align	1
.L29:
	bx	r3
