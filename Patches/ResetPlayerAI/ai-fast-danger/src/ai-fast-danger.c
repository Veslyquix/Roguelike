#include "gbafe.h"
#include "types.h"

extern void NuAiFillDangerMap_ApplyDanger(int danger_gain);

//int AreAllegiancesAllied(int uid_a, int uid_b);
//int CanUnitUseWeapon(struct Unit* unit, int item);
//int GetItemMight(int item);
//int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item);
//void FillMovementAndRangeMapForItem(struct Unit* unit, int item);
//int GetUnitPower(struct Unit* unit);

//int AreAllegiancesAllied(int uid_a, int uid_b) SHORTCALL CONSTFUNC;
//int CanUnitUseWeapon(struct Unit* unit, int item) SHORTCALL CONSTFUNC;
//int GetItemMight(int item) SHORTCALL CONSTFUNC;
//int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item) SHORTCALL CONSTFUNC;
//void FillMovementAndRangeMapForItem(struct Unit* unit, int item) SHORTCALL;
//int GetUnitPower(struct Unit* unit) SHORTCALL CONSTFUNC;

extern u8 gActiveUnitId;
extern struct Unit* gActiveUnit;
extern int IsUnitOnField(struct Unit* unit); 
extern struct Unit* const gUnitLookup[];

void NuAiFillDangerMap(void)
{
    int i, j;

    int active_unit_id = gActiveUnitId;
	int res = gActiveUnit->res; 
	int def = gActiveUnit->def; 

    for (i = 1; i < 0xC0; ++i)
    {
        struct Unit* unit = gUnitLookup[i];

		if (!IsUnitOnField(unit)) 
			continue; 
        //if (unit == NULL)
        //    continue;
		//
        //if (unit->pCharacterData == NULL)
        //    continue;
		//
        //if (unit->state & (US_HIDDEN | US_DEAD | US_NOT_DEPLOYED | US_BIT16))
        //    continue;

        if (AreAllegiancesAllied(active_unit_id, (u8) unit->index))
            continue;

        int item = 0;
        int might = 0;
        int item_tmp;

        for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
        {
			if (item == 0) 
				break; 
            if (!CanUnitUseWeapon(unit, item_tmp))
                continue;

            int might_tmp = GetItemMight(item_tmp);
			if (IsItemEffectiveAgainst(item, gActiveUnit)) { might += might*2; }

            if (might_tmp > might)
            {
                item = item_tmp;
                might = might_tmp;
            }
        }

        if (item == 0)
            continue;

        if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item))
            continue;

        FillMovementAndRangeMapForItem(unit, item);
		u32 atrb = GetItemAttributes(item); 

		
		
		int unit_power = GetUnitPower(unit) + might;
		if (atrb && IA_MAGIC) { unit_power -= res; }
		else { unit_power -= def; }
		if (unit_power > 1) { NuAiFillDangerMap_ApplyDanger(unit_power > 1); } 
    }
}

