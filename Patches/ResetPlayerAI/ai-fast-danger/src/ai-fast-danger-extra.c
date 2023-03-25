#include "gbafe.h"
//extern struct Vec2 gMapSize;
extern u8 * * gMapRange;
extern u8 * * gMapMovement2;
void ActiveUnitEquipBestWepByRange(void) { 
  struct Unit* unit = gActiveUnit;
  int slot = GetUnitEquippedWeaponSlot(unit);
  if (slot>=0) { 
  int wep = unit->items[slot];
  int might = GetItemMight(wep);
  int minRange = GetItemMinRange(wep); 
  int maxRange = GetItemMaxRange(wep);
  int finalSlot = slot; 
  for (int i = 0; i < 5; i++) { 
  if (slot == i) { 
    continue; }
  int item = unit->items[i]; 
  if (!CanUnitUseWeapon(unit, item)) 
    continue;
  int newMinRange = GetItemMinRange(item);
  // Equip the weapon with the lowest min range. 
  // Then for weapons with more range or more might, equip those 
  if (newMinRange <= minRange) { 
    int newMaxRange = GetItemMaxRange(item);
    if (newMaxRange >= maxRange) { 
    int newMight = GetItemMight(item); 
    if ((newMinRange != minRange) || (newMaxRange != maxRange) || (newMight > might)) {  
      finalSlot = i; 
      might = newMight; 
      minRange = newMinRange; 
      maxRange = newMaxRange; 
    } 
  }
  } 
  }
  if (slot != finalSlot)
    EquipUnitItemSlot(unit, finalSlot);
  } 
  
} 

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
			//if ((ix == 8) && (iy == 5)) { asm("mov r11, r11"); } 
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
int GetUnitEffSpdWithWep(struct Unit* unit, int item) { 
	int weight = GetItemWeight(item);
	int spd = unit->spd; 
	int con = unit->conBonus + unit->pCharacterData->baseCon + unit->pClassData->baseCon; 
	if (weight>con) { 
		weight -= con; 
		spd -= weight; 
		if (spd < 0) { spd = 0; } 
	} 
	return spd; 
}
int GetUnitEffSpd(struct Unit* unit) { 
	int item = GetUnitEquippedWeapon(unit);
	return GetUnitEffSpdWithWep(unit, item); 
} 
int GetItemEffMight(int item, int unit_power, int battle_def, int spd, struct Unit* unit) { 
	int might = GetItemMight(item);
	if (IsItemEffectiveAgainst(item, gActiveUnit)) { might += might*2; }
	
	might += unit_power; 
	might -= battle_def; 
	if (GetUnitEffSpdWithWep(unit, item)-4 >= spd) { might += might; } // doubles 
	//asm("mov r11, r11");
	if (might<2) { might = 2; } 
	return ((might+1)/2); // assume WTD  
} 


int GetCurrDanger(void) { 

	//asm("mov r11, r11");
	return gMapMovement2[gActiveUnit->yPos][gActiveUnit->xPos];


} 

struct Vec2 FindClosestDangerousTileInRange(int x, int y) { 

    int ix, iy;
	struct Vec2 result;
	result.x = 0xFF;
	result.y = 0xFF;
	int currMov = gActiveUnit->movBonus + gActiveUnit->pClassData->baseMov; 
    int map_size_x_m1 = gMapSize.x - 1;
    int map_size_y_m1 = gMapSize.y - 1;
	for (int dist = 1; dist < 4; dist++) { 
	
	
	
 
	iy = y - dist; // above
	//FindDangerousTileInRow
	if (!((iy < 0) || (iy > map_size_y_m1))) { // y within boundaries 
		for (ix = x - (dist+1); ix < (dist*2)+1; ix++) {   // for each x along this row within distance 
			if ((ix < 0) || (ix > map_size_x_m1))
				continue; 
			u8 * map_range_row = gMapMovement[iy];
			u8 * map_other_row = gMapMovement2[iy];
			u8 * map_unit_row = gMapUnit[iy]; 
			if ((map_range_row[ix] == 0xFF) || (map_range_row[ix] > currMov) || (map_unit_row[ix] != 0))
				continue;
			if (map_other_row[ix] == 0) 
				continue; 
			result.x = ix; 
			result.y = iy;
		} 
	}
	
	iy = y; // beside 
	if (!((iy < 0) || (iy > map_size_y_m1))) { // y within boundaries 
		for (ix = x - (dist+1); ix < (dist*2)+1; ix++) {   // for each x along this row within distance 
			if ((ix < 0) || (ix > map_size_x_m1))
				continue; 
			u8 * map_range_row = gMapMovement[iy];
			u8 * map_other_row = gMapMovement2[iy];
			u8 * map_unit_row = gMapUnit[iy]; 
			if ((map_range_row[ix] == 0xFF) || (map_range_row[ix] > currMov) || (map_unit_row[ix] != 0))
				continue;
			if (map_other_row[ix] == 0) 
				continue; 
			result.x = ix; 
			result.y = iy;
		} 
	}
	
	iy = y + dist; // below 
	if (!((iy < 0) || (iy > map_size_y_m1))) { // y within boundaries 
		for (ix = x - (dist+1); ix < (dist*2)+1; ix++) {   // for each x along this row within distance 
			if ((ix < 0) || (ix > map_size_x_m1))
				continue; 
			u8 * map_range_row = gMapMovement[iy];
			u8 * map_other_row = gMapMovement2[iy];
			u8 * map_unit_row = gMapUnit[iy]; 
			if ((map_range_row[ix] == 0xFF) || (map_range_row[ix] > currMov) || (map_unit_row[ix] != 0))
				continue;
			if (map_other_row[ix] == 0) 
				continue; 
			result.x = ix; 
			result.y = iy;
		} 
	}
	if (result.x != 0xFF) 
		break; 
	
	} 
	return result; 
	
	//-----
	//--x--
	//-----
	

} 

