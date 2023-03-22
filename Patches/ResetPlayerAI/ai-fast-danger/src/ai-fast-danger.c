#include "gbafe.h"
#include "types.h"

extern void NuAiFillDangerMap_ApplyDanger(int danger_gain);

//int AreAllegiancesAllied(int uid_a, int uid_b);
//int CanUnitUseWeapon(struct Unit* unit, int item);
//int GetItemMight(int item);
//int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item);
//void FillMovementAndRangeMapForItem(struct Unit* unit, int item);
//int GetUnitPower(struct Unit* unit);

#define SHORTCALL __attribute__((short_call))
extern int IsUnitOnField(struct Unit* unit) SHORTCALL;
extern int GetCurrDanger(void) SHORTCALL; 
extern int GetItemEffMight(int item) SHORTCALL;
s8 AreAllegiancesAllied(int uid_a, int uid_b) SHORTCALL;
int CanUnitUseWeapon(const struct Unit* unit, int item) SHORTCALL;
int GetItemMight(int item) SHORTCALL;
int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item) SHORTCALL;
void FillMovementAndRangeMapForItem(struct Unit* unit, int item) SHORTCALL;
int GetUnitPower(const struct Unit* unit) SHORTCALL;
extern u8 * * gMapMovement2;


extern u8 gActiveUnitId;
extern struct Unit* gActiveUnit;
extern int IsUnitOnField(struct Unit* unit); 
extern struct Unit* const gUnitLookup[];

int NuAiFillDangerMap(void)
{
	//asm("mov r11, r11"); 
    int i, j; 
    //int active_unit_id = gActiveUnitId;
	int res = gActiveUnit->res; 
	int def = gActiveUnit->def; 

    for (i = 1; i < 0xC0; ++i)
    {
        struct Unit* unit = gUnitLookup[i];

		if (!IsUnitOnField(unit)) {
			continue; 
		}


        if ((gActiveUnitId >> 7) == (unit->index>>7)) { // AreAllegiancesAllied 
			continue; 
		} 

        int item = 0;
        int might = 0;
        int item_tmp;

        for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
        {
            if (!CanUnitUseWeapon(unit, item_tmp)) {
			continue; } 

            int might_tmp = GetItemEffMight(item_tmp); 

            if (might_tmp > might)
            {
                item = item_tmp;
                might = might_tmp;
            }
        }

        if (item == 0) {
		continue; }
		
        if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
			continue; 
		} 

        FillMovementAndRangeMapForItem(unit, item);
		u32 atrb = GetItemAttributes(item); 

		
		
		int unit_power = GetUnitPower(unit) + might;
		//asm("mov r11, r11");
		if (atrb & IA_MAGIC) { unit_power = unit_power - res; }
		else { unit_power = unit_power - def; }
		if (unit_power > 1) { 
		NuAiFillDangerMap_ApplyDanger(unit_power / 2); 
		} 
    }
	return GetCurrDanger(); 
}

