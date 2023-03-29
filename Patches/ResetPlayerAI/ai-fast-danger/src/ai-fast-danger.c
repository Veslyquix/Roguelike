#include "gbafe.h"
#include "types.h"

extern void NuAiFillDangerMap_ApplyDanger(int danger_gain);

//int AreAllegiancesAllied(int uid_a, int uid_b);
//int CanUnitUseWeapon(struct Unit* unit, int item);
//int GetItemMight(int item);
//int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item);
//void FillMovementAndRangeMapForItem(struct Unit* unit, int item);
//int GetUnitPower(struct Unit* unit);

#define CONSTFUNC __attribute__((const))
#define SHORTCALL __attribute__((short_call))
extern int IsUnitOnFieldAndNotAllied(struct Unit* unit) SHORTCALL CONSTFUNC;
extern int GetCurrDanger(void) SHORTCALL; 
extern int GetItemEffMight(int item, int unit_power, int def, int res, int spd, struct Unit* unit) SHORTCALL;
extern int GetUnitEffSpd(struct Unit* unit) SHORTCALL;
extern int WhichWepHasBetterRange(int itemA, int itemB) SHORTCALL; 
//void BmMapFill(MapData, u8 value) SHORTCALL;
s8 AreAllegiancesAllied(int uid_a, int uid_b) SHORTCALL;
int CanUnitUseWeapon(const struct Unit* unit, int item) SHORTCALL;
int GetItemMight(int item) SHORTCALL;
int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item) SHORTCALL;
void FillMovementAndRangeMapForItem(struct Unit* unit, int item) SHORTCALL;
void FillMovementAndRangeMapForItem_PassableDoors(struct Unit* unit, u16 item) SHORTCALL;
int GetUnitPower(const struct Unit* unit) SHORTCALL;
void RefreshUnitsOnBmMap(void) SHORTCALL; 
extern void removeActiveAllegianceFromUnitMap(void) SHORTCALL; 

extern u8 * * gMapMovement2;
extern u8 * * gMapUnit;
extern u8 gActiveUnitId;
extern struct Unit* gActiveUnit;
extern struct Unit* const gUnitLookup[];
extern void FillRangeForBallista(struct Unit* unit) SHORTCALL; 
void NuAiFillDangerMap(void)
{
	//asm("mov r11, r11"); 
    int i, j; 
    //int active_unit_id = gActiveUnitId;
	struct Unit* actor = gActiveUnit; 
	int res = actor->res; 
	int def = actor->def; 
	//BmMapFill(gMapUnit, 0);
	removeActiveAllegianceFromUnitMap(); 
	int spd = GetUnitEffSpd(actor); 
	

    for (i = 1; i < 0xC0; ++i)
    {
        struct Unit* unit = gUnitLookup[i];

		if (!IsUnitOnFieldAndNotAllied(unit)) {
			continue; 
		}



		FillRangeForBallista(unit); 
        int item = 0;
		int item_best_range = 0; 
        int might = 0;
        int item_tmp;
		int unit_power = GetUnitPower(unit);

        for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
        {
            if (!CanUnitUseWeapon(unit, item_tmp)) {
				continue; 
			} 

			

            int might_tmp = GetItemEffMight(item_tmp, unit_power, def, res, spd, unit); 
			item_best_range = WhichWepHasBetterRange(item_tmp, item);
            if (might_tmp > might)
            {
                item = item_tmp;
                might = might_tmp;
            }
			
        }

        if (item == 0) {
		continue; }
		
        if (!CouldUnitBeInRangeHeuristic(actor, unit, item_best_range)) {
			continue; 
		} 


        FillMovementAndRangeMapForItem_PassableDoors(unit, item_best_range); 
		// this won't work properly for enemeis with non 1-2 range weps 
		// eg. an enemy with an axe and a bow 
		NuAiFillDangerMap_ApplyDanger(might); // minimum of 1 unit power 

    }
	RefreshUnitsOnBmMap();
	//asm("mov r11, r11");
	//return GetCurrDanger(); 
}

