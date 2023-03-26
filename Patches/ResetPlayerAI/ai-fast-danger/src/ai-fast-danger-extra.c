#include "gbafe.h"
//extern struct Vec2 gMapSize;
extern u8 * * gMapRange;
extern u8 * * gMapMovement2;




u32 AddWeaponTypeAt(u32 weaponTypes, int ix, int iy) { 
    int map_size_x_m1 = gMapSize.x - 1;
    int map_size_y_m1 = gMapSize.y - 1;
	if (!((iy < 0) || (iy > map_size_y_m1))) { // y within boundaries 
		if (!(ix < 0) || (ix > map_size_x_m1)) { 
			u8 * map_range_row = gMapRange[iy];
			u8 * map_unit_row = gMapUnit[iy]; 
			if ((map_range_row[ix] != 0)) {
				u8 i = map_unit_row[ix];
				if (i != 0) {
					if (gActiveUnit->index>>7 != i>>7) { // are units allied 
						struct Unit* unit = gUnitLookup[i];
						int item = GetUnitEquippedWeapon(unit);
						u32 atrb = GetItemAttributes(item) & IA_REVERTTRIANGLE;
						u8 type = GetItemType(item);
						if (atrb) {
							if (type == 0) type = 2; // lancereaver becomes an axe 
							else { // we immediately change its type, so we must use else 
								if (type == 1) type = 0; // axereaver becomes a sword 
								else { 
									if (type == 2) type = 1; // swordreaver becomes a lance 
								}
							}
						}
						if (type < 8) { 
							u32 myNibble = ((weaponTypes & (0xF << (type*4))) + (1<<(type*4))) & (0xF << (type*4)); // add 1 to the nibble at whichever offset. ensure it doesn't exceed 0xF. 
							weaponTypes = (weaponTypes & ~(0xF << (type*4))) | myNibble; // remove all bits from the nibble in the original variable, then orr the new bits 
						} 
					}
				}
			}
		}
	}
	return weaponTypes; 

} 

int CountNearbyWeaponTypes(int x, int y) { 
	//struct Unit* unit = gActiveUnit; 
	u32 result = 0;
	//result.sword = 0x0;
	//result.lance = 0x0;
	//result.axe = 0x0;
	//result.bow = 0x0;
	//result.staff = 0x0;
	//result.anima = 0x0;
	//result.light = 0x0;
	//result.dark = 0x0;
	
	for (int dist = 1; dist < 7; dist++) { 
		for (int ix = x-dist; ix <= x+dist; ix++) {
			result = AddWeaponTypeAt(result, ix, y-dist);
			result = AddWeaponTypeAt(result, ix, y+dist);
		}
		for (int iy = y-(dist-1); iy <= y+(dist-1); iy++) {
			result = AddWeaponTypeAt(result, x-dist, iy);
			result = AddWeaponTypeAt(result, x+dist, iy);
		}
	}
	return result;
} 


/*
struct weaponTypes; 
{
	u8 sword:4; lance:4;
	u8 axe:4; bow:4; 
	u8 staff:4; anima:4; 
	u8 light:4; dark:4; 
};
*/ 
void TryEquipType(int itemType, struct Unit* unit) { 

	for (int i = 0; i < 5; i++) { 
		int item = unit->items[i]; 
		if (item) { 
			if (CanUnitUseWeapon(unit, item)) { 
				int type = GetItemType(item); 
				u32 atrb = GetItemAttributes(item); 
				if (atrb & IA_REVERTTRIANGLE) { // swap the "type" of the wep if weapon triangle is swapped  
					if (type == ITYPE_SWORD) { 
						type = ITYPE_AXE; 
					} 
					else if (type == ITYPE_LANCE) { 
						type = ITYPE_SWORD; 
					}
					else if (type == ITYPE_AXE) { 
						type = ITYPE_LANCE; 
					}
				
				} 
				if (type == itemType) { 
					EquipUnitItemSlot(unit, i);
					break; 
				}

			}
		}
	}


} 

void EquipOptimalWepType(struct Unit* unit, int x, int y) { 
	u32 weps = CountNearbyWeaponTypes(x, y); 
	int sword = weps 	& 0xF; 
	int lance = weps 	& 0xF0; 
	int axe = weps 		& 0xF00; 
	//int bow = weps 	& 0xF000; 
	//int staff = weps 	& 0xF0000; 
	
	//int anima = weps 	& 0xF00000; 
	//int light = weps 	& 0xF000000; 
	//int dark = weps 	& 0xF0000000;
	
	if ((sword > lance) && (sword > axe)) { 
		TryEquipType(ITYPE_LANCE, unit); 
	}
	if ((lance > sword ) && (lance > axe)) { 
		TryEquipType(ITYPE_AXE, unit); 
	} 
	if ((axe > sword ) && (axe > lance)) { 
		TryEquipType(ITYPE_SWORD, unit); 
	}
	


} 


int doesUnitHaveMoreThanOneWep(struct Unit* unit) { 
	int result = false; 
	int counter = 0; 
	for (int i = 0; i < 5; i++) { 
		int item = unit->items[i]; 
		if (item) { 
			if (CanUnitUseWeapon(unit, item)) { 
				if (counter) { 
					result = true; 
					break; 
				}
				counter++; 
			} 
		} 
	}
	return result; 

} 
int doesUnitHaveMoreThanOneWEXP(struct Unit* unit) { 
	int counter = 0; 
	for (int i = 0; i < 4; i++) {
		if (unit->ranks[i]) 
			counter++; 
	}
	// skip staves 
	for (int i = 5; i < 8; i++) { 
		if (unit->ranks[i]) 
			counter++; 
	}
	return (counter>=2); 

} 

void ActiveUnitEquipBestWepByRange(void) { 
  struct Unit* unit = gActiveUnit;
  if (doesUnitHaveMoreThanOneWep(unit)) { 
  
	int slot = GetUnitEquippedWeaponSlot(unit); // or just try to equip javelins etc 
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
				if (newMaxRange > maxRange) { // leave items alone but prefer better range weps over worse range weps 
				//if (newMaxRange >= maxRange) { // even at same range, equip highest mt wep (ignoring wep triangle) 
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
	
	  	if (doesUnitHaveMoreThanOneWEXP(unit)) { // try to win weapon triangle 
		struct AiDecision* decision = &gAiData.decision; 
		EquipOptimalWepType(unit, decision->xMovement, decision->yMovement); 
	} 
	} 

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
void RestoreActiveUnitOnUnitMap(void) { 
	gMapUnit[gActiveUnit->yPos][gActiveUnit->xPos] = gActiveUnit->index;

} 

int GetUnitEffSpd(struct Unit* unit) { 
	gMapUnit[gActiveUnit->yPos][gActiveUnit->xPos] = 0; // remove active unit from the unit map so danger map includes tiles past where you were blocking 
	int item = GetUnitEquippedWeapon(unit);
	return GetUnitEffSpdWithWep(unit, item); 
} 
int GetItemEffMight(int item, int unit_power, int battle_def, int spd, struct Unit* unit) { 
	int might = GetItemMight(item);
	if (IsItemEffectiveAgainst(item, gActiveUnit)) { might += might*2; }
	
	might += unit_power; 
	might -= battle_def; 
	if (GetUnitEffSpdWithWep(unit, item)-4 >= spd) { might += might; } // doubles 
	if (might<2) { might = 2; } 
	return ((might+1)/2); // assume WTD  
} 


int GetCurrDanger(void) { 

	return gMapMovement2[gActiveUnit->yPos][gActiveUnit->xPos];


} 


// so we don't repeat the same tiles 
struct Vec2 FindDangerousTileAt(struct Vec2 result, int ix, int iy) { 
	int currMov = gActiveUnit->movBonus + gActiveUnit->pClassData->baseMov; 
    int map_size_x_m1 = gMapSize.x - 1;
    int map_size_y_m1 = gMapSize.y - 1;
	if ((iy >= 0) && (iy <= map_size_y_m1)) { // y within boundaries 
		if ((ix >= 0) && (ix <= map_size_x_m1)) {
			u8 * map_move_row = gMapMovement[iy];
			u8 * map_other_row = gMapMovement2[iy];
			u8 * map_unit_row = gMapUnit[iy]; 
			if ((map_move_row[ix] != 0xFF) && (map_move_row[ix] <= currMov) && (map_unit_row[ix] == 0)) {
				if (map_other_row[ix] != 0) {
					result.x = ix; 
					result.y = iy;
				}
			}
		}
	}
	return result; 
}

struct Vec2 FindClosestDangerousTileInRange(int x, int y) { 
	struct Vec2 result;
	result.x = 0xFF;
	result.y = 0xFF;
	
	for (int dist = 1; dist < 7; dist++) { 
		if (result.x != 0xFF) break; 
		for (int ix = x-dist; ix <= (x+dist); ix++) { // left to right on row above and below 
			result = FindDangerousTileAt(result, ix, y-dist); 
			result = FindDangerousTileAt(result, ix, y+dist); 
		}
		for (int iy = y-(dist-1); iy <= (y+(dist-1)); iy++) {
			result = FindDangerousTileAt(result, x-dist, iy); 
			result = FindDangerousTileAt(result, x+dist, iy); 
		}
	}
	return result; 
} 
 
