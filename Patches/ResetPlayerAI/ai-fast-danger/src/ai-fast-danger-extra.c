#include "gbafe.h"
//extern struct Vec2 gMapSize;
extern u8 * * gMapRange;
extern u8 * * gMapMovement2;

void NuAiFillDangerMap_ApplyDanger(int danger_gain)
{
    int ix, iy;

    int map_size_x_m1 = gMapSize.x - 1;
    int map_size_y_m1 = gMapSize.y - 1;

    for (iy = map_size_y_m1; iy >= 0; --iy)
    {
        u8 * map_range_row = gMapRange[iy];
        u8 * map_other_row = gMapMovement2[iy];

        for (ix = map_size_x_m1; ix >= 0; --ix)
        {
            if (map_range_row[ix] == 0)
                continue;

            map_other_row[ix] += danger_gain;
        }
    }
}
int IsUnitOnField(struct Unit* unit) 
{ 
    if (unit == NULL)
        return false;
	
    if (unit->pCharacterData == NULL)
        return false;
	
    if (unit->state & (US_HIDDEN | US_DEAD | US_NOT_DEPLOYED | US_BIT16)) { 
		return false; } 
	return true; 
} 

int GetItemEffMight(int item) { 
	int might = GetItemMight(item);
	if (IsItemEffectiveAgainst(item, gActiveUnit)) { 
	might += might*2; 
	}
	return might; 
} 
int GetCurrDanger(void) { 

	//asm("mov r11, r11");
	return gMapMovement2[gActiveUnit->yPos][gActiveUnit->xPos];


} 
