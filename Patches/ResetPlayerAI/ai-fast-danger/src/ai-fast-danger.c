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
int GetItemMinRange(int item) SHORTCALL CONSTFUNC; //! FE8U = 0x801766D
int GetItemMaxRange(int item) SHORTCALL CONSTFUNC; //! FE8U = 0x8017685
extern int IsUnitOnFieldAndNotAllied(struct Unit* unit) SHORTCALL CONSTFUNC;
extern int GetCurrDanger(void) SHORTCALL CONSTFUNC; 
extern int GetItemEffMight(int item, int unit_power, int def, int res, int spd, struct Unit* unit) SHORTCALL CONSTFUNC;
extern int GetUnitEffSpd(struct Unit* unit) SHORTCALL CONSTFUNC;
extern int GetMaxRangeIfItemExists(int item) SHORTCALL CONSTFUNC; 
extern int GetMinRangeIfItemExists(int item) SHORTCALL CONSTFUNC; 
extern int GetHighestRange(int item, int currentMinRange) SHORTCALL CONSTFUNC;
extern int GetLowestRange(int item, int currentMinRange) SHORTCALL CONSTFUNC;

s8 Range_AiCouldReachByBirdsEyeDistance(struct Unit* unit, struct Unit* other, int maxRange) SHORTCALL CONSTFUNC; 
extern int WhichWepHasBetterRange(int itemA, int itemB) SHORTCALL CONSTFUNC; 
//void BmMapFill(MapData, u8 value) SHORTCALL CONSTFUNC;
s8 AreAllegiancesAllied(int uid_a, int uid_b) SHORTCALL CONSTFUNC;
int CanUnitUseWeapon(const struct Unit* unit, int item) SHORTCALL CONSTFUNC;
int GetItemMight(int item) SHORTCALL CONSTFUNC;
int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item) SHORTCALL CONSTFUNC;
int GetUnitPower(const struct Unit* unit) SHORTCALL CONSTFUNC;

// Probably not CONSTFUNCs 
void FillMovementAndRangeMapForItem(struct Unit* unit, int item) SHORTCALL;
void FillMovementAndRangeMapForItem_PassableDoors(struct Unit* unit, int minRange, int maxRange, int might) SHORTCALL;
void RefreshUnitsOnBmMap(void) SHORTCALL; 
extern void InitDangerMap(void) SHORTCALL; 
extern int FillRangeForBallista(struct Unit* unit) SHORTCALL; 

extern u8 * * gMapMovement2;
extern u8 * * gMapUnit;
extern u8 gActiveUnitId;
extern struct Unit* gActiveUnit;
extern struct Unit* const gUnitLookup[];

void NuAiFillDangerMap(void)
{
	//asm("mov r11, r11"); 
    int i, j; 
    //int active_unit_id = gActiveUnitId;
	struct Unit* actor = gActiveUnit; 
	int res = actor->res; 
	int def = actor->def; 
	//BmMapFill(gMapUnit, 0);
	InitDangerMap(); 
	int spd = GetUnitEffSpd(actor); 
	

    for (i = 1; i < 0xC0; ++i)
    {
        struct Unit* unit = gUnitLookup[i];

		if (!IsUnitOnFieldAndNotAllied(unit)) {
			continue; 
		}
		int unit_power = GetUnitPower(unit);
		int item = FillRangeForBallista(unit); 
		int item_max_range = GetMaxRangeIfItemExists(item); 
		int item_min_range = GetMinRangeIfItemExists(item); 
        int might = GetItemEffMight(item, unit_power, def, res, spd, unit);
        int item_tmp;
        for (j = 0; j < 5 && (item_tmp = unit->items[j]); ++j)
        {
            if (!CanUnitUseWeapon(unit, item_tmp)) {
				continue; 
			} 
            int might_tmp = GetItemEffMight(item_tmp, unit_power, def, res, spd, unit); 
			item_max_range = GetHighestRange(item_tmp, item_max_range); 
			item_min_range = GetLowestRange(item_tmp, item_min_range); 
            if (might_tmp > might) {
                might = might_tmp; }
			
        }

        if (!Range_AiCouldReachByBirdsEyeDistance(actor, unit, item_max_range)) {
			continue; 
		} 
        FillMovementAndRangeMapForItem_PassableDoors(unit, item_min_range, item_max_range, might); 
		//NuAiFillDangerMap_ApplyDanger(might); // minimum of 1 unit power 

    }
	RefreshUnitsOnBmMap();
	//asm("mov r11, r11");
	//return GetCurrDanger(); 
}

