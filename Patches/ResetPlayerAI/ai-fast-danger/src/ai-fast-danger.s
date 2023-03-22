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
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, lr}	@
	mov	lr, fp	@,
	mov	r7, r10	@,
	mov	r6, r9	@,
	mov	r5, r8	@,
@ ai-fast-danger.c:36: 	int res = gActiveUnit->res; 
	movs	r2, #24	@ res,
@ ai-fast-danger.c:37: 	int def = gActiveUnit->def; 
	movs	r1, #23	@ def,
@ ai-fast-danger.c:32: {
	push	{r5, r6, r7, lr}	@
@ ai-fast-danger.c:36: 	int res = gActiveUnit->res; 
	ldr	r7, .L27	@ tmp169,
	ldr	r3, [r7]	@ gActiveUnit.0_1, gActiveUnit
@ ai-fast-danger.c:36: 	int res = gActiveUnit->res; 
	ldrsb	r2, [r3, r2]	@ res,* res
@ ai-fast-danger.c:32: {
	sub	sp, sp, #28	@,,
@ ai-fast-danger.c:36: 	int res = gActiveUnit->res; 
	str	r2, [sp, #16]	@ res, %sfp
@ ai-fast-danger.c:37: 	int def = gActiveUnit->def; 
	ldrsb	r1, [r3, r1]	@ def,* def
	ldr	r3, .L27+4	@ ivtmp.24,
	mov	ip, r3	@ ivtmp.24, ivtmp.24
	str	r3, [sp]	@ ivtmp.24, %sfp
@ ai-fast-danger.c:48:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	ldr	r3, .L27+8	@ tmp170,
	movs	r2, #191	@ _77,
	mov	r9, r3	@ tmp170, tmp170
@ ai-fast-danger.c:78: 		u32 atrb = GetItemAttributes(item); 
	ldr	r3, .L27+12	@ tmp171,
	str	r3, [sp, #12]	@ tmp171, %sfp
@ ai-fast-danger.c:87: 		NuAiFillDangerMap_ApplyDanger(unit_power / 2); 
	ldr	r3, .L27+16	@ tmp172,
	lsls	r2, r2, #2	@ _77, _77,
	str	r3, [sp, #20]	@ tmp172, %sfp
	mov	r3, r9	@ tmp170, tmp170
	add	r2, r2, ip	@ _77, ivtmp.24
	mov	fp, r2	@ _77, _77
	mov	r9, r1	@ def, def
	str	r7, [sp, #8]	@ tmp169, %sfp
	str	r3, [sp, #4]	@ tmp170, %sfp
.L12:
@ ai-fast-danger.c:41:         struct Unit* unit = gUnitLookup[i];
	ldr	r3, [sp]	@ ivtmp.24, %sfp
	ldr	r6, [r3]	@ unit, MEM[(struct Unit * *)_75]
@ ai-fast-danger.c:43: 		if (!IsUnitOnField(unit)) {
	movs	r0, r6	@, unit
	bl	IsUnitOnField		@
@ ai-fast-danger.c:43: 		if (!IsUnitOnField(unit)) {
	cmp	r0, #0	@ tmp173,
	beq	.L3		@,
@ ai-fast-danger.c:48:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	ldr	r3, [sp, #4]	@ tmp170, %sfp
	ldrb	r2, [r3]	@ gActiveUnitId, gActiveUnitId
@ ai-fast-danger.c:48:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	movs	r3, #11	@ tmp157,
	ldrsb	r3, [r6, r3]	@ tmp157,
@ ai-fast-danger.c:48:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	lsrs	r2, r2, #7	@ tmp155, gActiveUnitId,
@ ai-fast-danger.c:48:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	asrs	r3, r3, #31	@ tmp159, tmp157,
@ ai-fast-danger.c:48:         if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
	cmp	r2, r3	@ tmp155, tmp159
	beq	.L3		@,
	movs	r3, #40	@ _70,
@ ai-fast-danger.c:53:         int might = 0;
	movs	r5, #0	@ might,
	mov	r8, r3	@ _70, _70
@ ai-fast-danger.c:52:         int item = 0;
	movs	r3, #0	@ item,
	movs	r4, r6	@ ivtmp.14, unit
	mov	r10, r3	@ item, item
	movs	r7, r5	@ might, might
	adds	r4, r4, #30	@ ivtmp.14,
	add	r8, r8, r6	@ _70, unit
.L5:
@ ai-fast-danger.c:56:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	ldrh	r5, [r4]	@ item_tmp, MEM[(short unsigned int *)_68]
@ ai-fast-danger.c:56:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	cmp	r5, #0	@ item_tmp,
	beq	.L8		@,
@ ai-fast-danger.c:58:             if (!CanUnitUseWeapon(unit, item_tmp)) {
	movs	r1, r5	@, item_tmp
	movs	r0, r6	@, unit
	bl	CanUnitUseWeapon		@
@ ai-fast-danger.c:58:             if (!CanUnitUseWeapon(unit, item_tmp)) {
	cmp	r0, #0	@ tmp174,
	beq	.L7		@,
@ ai-fast-danger.c:61:             int might_tmp = GetItemEffMight(item_tmp); 
	movs	r0, r5	@, item_tmp
	bl	GetItemEffMight		@
@ ai-fast-danger.c:63:             if (might_tmp > might)
	cmp	r0, r7	@ might_tmp, might
	ble	.L7		@,
	movs	r7, r0	@ might, might_tmp
	mov	r10, r5	@ item, item_tmp
.L7:
@ ai-fast-danger.c:56:         for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
	adds	r4, r4, #2	@ ivtmp.14,
	cmp	r4, r8	@ ivtmp.14, _70
	bne	.L5		@,
.L8:
@ ai-fast-danger.c:70:         if (item == 0) {
	mov	r3, r10	@ item, item
	cmp	r3, #0	@ item,
	beq	.L3		@,
@ ai-fast-danger.c:73:         if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
	ldr	r3, [sp, #8]	@ tmp169, %sfp
	mov	r2, r10	@, item
	movs	r1, r6	@, unit
	ldr	r0, [r3]	@ gActiveUnit, gActiveUnit
	bl	CouldUnitBeInRangeHeuristic		@
@ ai-fast-danger.c:73:         if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
	cmp	r0, #0	@ tmp176,
	beq	.L3		@,
@ ai-fast-danger.c:77:         FillMovementAndRangeMapForItem(unit, item);
	mov	r1, r10	@, item
	movs	r0, r6	@, unit
	bl	FillMovementAndRangeMapForItem		@
@ ai-fast-danger.c:78: 		u32 atrb = GetItemAttributes(item); 
	ldr	r3, [sp, #12]	@ tmp171, %sfp
	mov	r0, r10	@, item
	bl	.L29		@
	movs	r4, r0	@ atrb, tmp177
@ ai-fast-danger.c:82: 		int unit_power = GetUnitPower(unit) + might;
	movs	r0, r6	@, unit
	bl	GetUnitPower		@
@ ai-fast-danger.c:85: 		else { unit_power = unit_power - def; }
	mov	r3, r9	@ def, def
@ ai-fast-danger.c:82: 		int unit_power = GetUnitPower(unit) + might;
	adds	r0, r0, r7	@ unit_power, tmp178, might
@ ai-fast-danger.c:85: 		else { unit_power = unit_power - def; }
	subs	r3, r0, r3	@ unit_power, unit_power, def
@ ai-fast-danger.c:84: 		if (atrb & IA_MAGIC) { unit_power = unit_power - res; }
	lsls	r4, r4, #30	@ tmp180, atrb,
	bpl	.L11		@,
@ ai-fast-danger.c:84: 		if (atrb & IA_MAGIC) { unit_power = unit_power - res; }
	ldr	r3, [sp, #16]	@ res, %sfp
	subs	r3, r0, r3	@ unit_power, unit_power, res
.L11:
@ ai-fast-danger.c:86: 		if (unit_power > 1) { 
	cmp	r3, #1	@ unit_power,
	ble	.L3		@,
@ ai-fast-danger.c:87: 		NuAiFillDangerMap_ApplyDanger(unit_power / 2); 
	asrs	r0, r3, #1	@ tmp166, unit_power,
	ldr	r3, [sp, #20]	@ tmp172, %sfp
	bl	.L29		@
.L3:
@ ai-fast-danger.c:39:     for (i = 1; i < 0xC0; ++i)
	ldr	r3, [sp]	@ ivtmp.24, %sfp
	adds	r3, r3, #4	@ ivtmp.24,
	str	r3, [sp]	@ ivtmp.24, %sfp
	cmp	r3, fp	@ ivtmp.24, _77
	bne	.L12		@,
@ ai-fast-danger.c:90: 	return GetCurrDanger(); 
	bl	GetCurrDanger		@
@ ai-fast-danger.c:91: }
	add	sp, sp, #28	@,,
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
	.word	gUnitLookup+4
	.word	gActiveUnitId
	.word	GetItemAttributes
	.word	NuAiFillDangerMap_ApplyDanger
	.size	NuAiFillDangerMap, .-NuAiFillDangerMap
	.ident	"GCC: (devkitARM release 59) 12.2.0"
	.code 16
	.align	1
.L29:
	bx	r3
