	.cpu arm7tdmi
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
@ GNU C17 (devkitARM release 56) version 11.1.0 (arm-none-eabi)
@	compiled by GNU C version 10.3.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.18-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed: -mcpu=arm7tdmi -mthumb -mthumb-interwork -mtune=arm7tdmi -mlong-calls -march=armv4t -O2
	.text
	.align	1
	.p2align 2,,3
	.global	NuAiFillDangerMap
	.arch armv4t
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	NuAiFillDangerMap, %function
NuAiFillDangerMap:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, lr}	@
	mov	lr, fp	@,
	mov	r7, r10	@,
	mov	r6, r9	@,
	mov	r5, r8	@,
	push	{r5, r6, r7, lr}	@
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	ldr	r3, .L26	@ tmp171,
@ ai-fast-danger.c:33: {
	sub	sp, sp, #36	@,,
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	str	r3, [sp, #28]	@ tmp171, %sfp
	ldr	r0, [r3]	@ gActiveUnit.0_1, gActiveUnit
@ ai-fast-danger.c:37: 	int res = gActiveUnit->res; 
	movs	r3, #24	@ res,
	ldrsb	r3, [r0, r3]	@ res,* res
	str	r3, [sp, #24]	@ res, %sfp
@ ai-fast-danger.c:38: 	int def = gActiveUnit->def; 
	movs	r3, #23	@ def,
	ldrsb	r3, [r0, r3]	@ def,* def
	str	r3, [sp, #12]	@ def, %sfp
@ ai-fast-danger.c:39: 	int spd = GetUnitEffSpd(gActiveUnit); 
	bl	GetUnitEffSpd		@
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	ldr	r3, .L26+4	@ tmp175,
	str	r3, [sp, #8]	@ tmp175, %sfp
@ ai-fast-danger.c:64: 			u32 atrb = GetItemAttributes(item); 
	ldr	r3, .L26+8	@ tmp176,
@ ai-fast-danger.c:39: 	int spd = GetUnitEffSpd(gActiveUnit); 
	str	r0, [sp, #16]	@ tmp178, %sfp
	ldr	r7, .L26+12	@ ivtmp.23,
@ ai-fast-danger.c:64: 			u32 atrb = GetItemAttributes(item); 
	str	r3, [sp, #20]	@ tmp176, %sfp
	b	.L11		@
.L3:
@ ai-fast-danger.c:41:     for (i = 1; i < 0xC0; ++i)
	ldr	r3, .L26+16	@ tmp213,
	adds	r7, r7, #4	@ ivtmp.23,
	cmp	r3, r7	@ tmp213, ivtmp.23
	beq	.L25		@,
.L11:
@ ai-fast-danger.c:43:         struct Unit* unit = gUnitLookup[i];
	ldr	r4, [r7]	@ unit, MEM[(struct Unit * *)_59]
@ ai-fast-danger.c:45: 		if (!IsUnitOnField(unit)) {
	movs	r0, r4	@, unit
	bl	IsUnitOnField		@
@ ai-fast-danger.c:45: 		if (!IsUnitOnField(unit)) {
	cmp	r0, #0	@ tmp179,
	beq	.L3		@,
@ ai-fast-danger.c:50:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	ldr	r3, [sp, #8]	@ tmp175, %sfp
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
	movs	r3, #40	@ _55,
	mov	r10, r3	@ _55, _55
@ ai-fast-danger.c:55:         int might = 0;
	movs	r3, #0	@ might,
	mov	fp, r3	@ might, might
@ ai-fast-danger.c:54:         int item = 0;
	mov	r9, r3	@ item, item
	movs	r3, r7	@ ivtmp.23, ivtmp.23
	add	r10, r10, r4	@ _55, unit
	movs	r5, r4	@ ivtmp.13, unit
	mov	r7, r10	@ _55, _55
@ ai-fast-danger.c:57: 		int unit_power = GetUnitPower(unit);
	mov	r8, r0	@ unit_power, tmp180
	mov	r10, r3	@ ivtmp.23, ivtmp.23
	adds	r5, r5, #30	@ ivtmp.13,
.L5:
@ ai-fast-danger.c:59:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	ldrh	r6, [r5]	@ item_tmp, MEM[(short unsigned int *)_66]
@ ai-fast-danger.c:59:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	cmp	r6, #0	@ item_tmp,
	beq	.L8		@,
@ ai-fast-danger.c:61:             if (!CanUnitUseWeapon(unit, item_tmp)) {
	movs	r1, r6	@, item_tmp
	movs	r0, r4	@, unit
	bl	CanUnitUseWeapon		@
@ ai-fast-danger.c:61:             if (!CanUnitUseWeapon(unit, item_tmp)) {
	cmp	r0, #0	@ tmp181,
	beq	.L6		@,
@ ai-fast-danger.c:64: 			u32 atrb = GetItemAttributes(item); 
	ldr	r3, [sp, #20]	@ tmp176, %sfp
	mov	r0, r9	@, item
	bl	.L28		@
@ ai-fast-danger.c:66: 			if (atrb & IA_MAGIC) { battle_def = res; }
	movs	r3, #2	@ tmp210,
@ ai-fast-danger.c:65: 			int battle_def = def; 
	ldr	r2, [sp, #12]	@ battle_def, %sfp
@ ai-fast-danger.c:66: 			if (atrb & IA_MAGIC) { battle_def = res; }
	tst	r3, r0	@ tmp210, tmp182
	beq	.L7		@,
@ ai-fast-danger.c:66: 			if (atrb & IA_MAGIC) { battle_def = res; }
	ldr	r2, [sp, #24]	@ battle_def, %sfp
.L7:
@ ai-fast-danger.c:69:             int might_tmp = GetItemEffMight(item_tmp, unit_power, battle_def, spd, unit); 
	mov	r1, r8	@, unit_power
	movs	r0, r6	@, item_tmp
	str	r4, [sp]	@ unit,
	ldr	r3, [sp, #16]	@, %sfp
	bl	GetItemEffMight		@
@ ai-fast-danger.c:71:             if (might_tmp > might)
	cmp	r0, fp	@ might_tmp, might
	ble	.L6		@,
	mov	fp, r0	@ might, might_tmp
	mov	r9, r6	@ item, item_tmp
.L6:
@ ai-fast-danger.c:59:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	adds	r5, r5, #2	@ ivtmp.13,
	cmp	r7, r5	@ _55, ivtmp.13
	bne	.L5		@,
.L8:
@ ai-fast-danger.c:78:         if (item == 0) {
	mov	r3, r9	@ item, item
	mov	r7, r10	@ ivtmp.23, ivtmp.23
	cmp	r3, #0	@ item,
	beq	.L3		@,
@ ai-fast-danger.c:81:         if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
	ldr	r3, [sp, #28]	@ tmp171, %sfp
	mov	r2, r9	@, item
	movs	r1, r4	@, unit
	ldr	r0, [r3]	@ gActiveUnit, gActiveUnit
	bl	CouldUnitBeInRangeHeuristic		@
@ ai-fast-danger.c:81:         if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
	cmp	r0, #0	@ tmp184,
	beq	.L3		@,
@ ai-fast-danger.c:85:         FillMovementAndRangeMapForItem(unit, item);
	movs	r0, r4	@, unit
	mov	r1, r9	@, item
	bl	FillMovementAndRangeMapForItem		@
@ ai-fast-danger.c:93: 		NuAiFillDangerMap_ApplyDanger(unit_power / 2); // minimum of 1 unit power 
	mov	r0, r8	@ unit_power, unit_power
	cmp	r0, #2	@ unit_power,
	bge	.L10		@,
	movs	r0, #2	@ unit_power,
.L10:
	ldr	r3, .L26+20	@ tmp169,
	asrs	r0, r0, #1	@ tmp168, unit_power,
	bl	.L28		@
@ ai-fast-danger.c:41:     for (i = 1; i < 0xC0; ++i)
	ldr	r3, .L26+16	@ tmp213,
	adds	r7, r7, #4	@ ivtmp.23,
	cmp	r3, r7	@ tmp213, ivtmp.23
	bne	.L11		@,
.L25:
@ ai-fast-danger.c:98: 	return GetCurrDanger(); 
	bl	GetCurrDanger		@
@ ai-fast-danger.c:99: }
	add	sp, sp, #36	@,,
	@ sp needed	@
	pop	{r4, r5, r6, r7}
	mov	fp, r7
	mov	r10, r6
	mov	r9, r5
	mov	r8, r4
	pop	{r4, r5, r6, r7}
	pop	{r1}
	bx	r1
.L27:
	.align	2
.L26:
	.word	gActiveUnit
	.word	gActiveUnitId
	.word	GetItemAttributes
	.word	gUnitLookup+4
	.word	gUnitLookup+768
	.word	NuAiFillDangerMap_ApplyDanger
	.size	NuAiFillDangerMap, .-NuAiFillDangerMap
	.ident	"GCC: (devkitARM release 56) 11.1.0"
	.code 16
	.align	1
.L28:
	bx	r3
