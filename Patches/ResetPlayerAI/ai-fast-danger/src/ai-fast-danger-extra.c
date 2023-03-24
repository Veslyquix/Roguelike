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
			if ((ix == 8) && (iy == 5)) { asm("mov r11, r11"); } 
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
	if (IsItemEffectiveAgainst(item, gActiveUnit)) { 
		might += might*2; 
	}
	asm("mov r11, r11");
	might += unit_power; 
	might -= battle_def; 
	if (might<0) { might = 0; } 
	if (GetUnitEffSpdWithWep(unit, item)-4 >= spd) { might += might; } // doubles 
	return might; 
} 


int GetCurrDanger(void) { 

	//asm("mov r11, r11");
	return gMapMovement2[gActiveUnit->yPos][gActiveUnit->xPos];


} 
