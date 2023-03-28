#include "gbafe.h"
//extern struct Vec2 gMapSize;
#include "stdlib.h" 
extern u8 * * gMapRange;
extern u8 * * gMapMovement2;
extern u8 * * gMapMovement;
extern u8 * * gMapUnit;
extern u8 * * gMapTerrain;
int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item);
void FillMovementAndRangeMapForItem(struct Unit* unit, int item);
extern struct AiState gAiState;
struct AiState
{
    /* 00 */ u8 units[116];
    /* 74 */ u8* unitIt;
    /* 78 */ u8 orderState;
    /* 79 */ u8 decideState;
    /* 7A */ s8 dangerMapFilled; // bool
    /* 7B */ u8 flags;
    /* 7C */ u8 unk7C;
    /* 7D */ u8 combatWeightTableId;
    /* 7E */ u8 unk7E;
    /* 7F */ u8 unk7F;
    /* 80 */ u32 specialItemFlags;
    /* 84 */ u8 unk84;
    /* 85 */ u8 bestBlueMov;
    /* 86 */ u8 unk86[8];
};
enum
{
    AI_FLAGS_NONE = 0,

    AI_FLAG_0 = (1 << 0),
    AI_FLAG_1 = (1 << 1), // do not move 
    AI_FLAG_BERSERKED = (1 << 2),
    AI_FLAG_3 = (1 << 3),
};
extern u8** gWorkingBmMap;
inline void SetWorkingBmMap(u8** map)
{
    gWorkingBmMap = map;
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

int GetItemEffMight(int item, int unit_power, int def, int res, int spd, struct Unit* unit) { 

	u32 atrb = GetItemAttributes(item); 
	int battle_def = def; 
	if (atrb & IA_MAGIC) { battle_def = res; }
	int might = GetItemMight(item);
	if (IsItemEffectiveAgainst(item, gActiveUnit)) { might += might*2; }
	
	might += unit_power; 
	might -= battle_def; 
	if (GetUnitEffSpdWithWep(unit, item)-4 >= spd) { might += might; } // doubles 
	if (might<2) { might = 2; } 
	return ((might+1)/2); // assume WTD  
} 


extern void AiSetMovCostTableWithPassableWalls(const s8* cost); 
void GenerateUnitMovementMap_PassableWalls(struct Unit* unit) {
    AiSetMovCostTableWithPassableWalls((const s8*)GetUnitMovementCost(unit));

    SetWorkingBmMap(gMapMovement);

    MapFillMovement(unit->xPos, unit->yPos, UNIT_MOV(unit), unit->index);
    return;
}
int WhichWepHasBetterRange(int item_tmp, int item) { 

	int minRange = GetItemMinRange(item_tmp); 
	int maxRange = GetItemMaxRange(item_tmp);
	int newMinRange = GetItemMinRange(item);
	// Find the weapon with the lowest min range. 
	// Then find weps with greater range 
	if (newMinRange <= minRange) { 
		int newMaxRange = GetItemMaxRange(item);
		if (newMaxRange > maxRange) { // leave items alone but prefer better range weps over worse range weps 
			return item; 
		}
	} 
	return item_tmp; 
} 

void FillMovementAndRangeMapForItem_PassableWalls(struct Unit* unit, u16 item) {
    int ix;
    int iy;
	if (!(unit->ai3And4 & 0x2000)) { // for boss AI, they cannot move 
		GenerateUnitMovementMap_PassableWalls(unit);
	}
	else {
		BmMapFill(gMapMovement, 0xFF); // Cannot move anywhere except where they are already 
		gMapMovement[unit->yPos][unit->xPos] = 0; 
	}
    BmMapFill(gMapRange, 0);

    for (iy = gMapSize.y - 1; iy >= 0; iy--) {
		u8* moveRow = gMapMovement[iy]; 
        for (ix = gMapSize.x - 1; ix >= 0; ix--) {

            if (moveRow[ix] > 120) {
                continue;
            }

            MapIncInBoundedRange(ix, iy, GetItemMinRange(item), GetItemMaxRange(item));
        }
    }

    return;
}

void TryMoveTowardsLeader() { 
	struct Unit* target = 0; 
	for (int i = 1; i <= 50; i++) { 
		target = gUnitLookup[i]; 
		if ((target->pCharacterData->attributes | target->pClassData->attributes) & CA_LORD) { 
			break; 
		} 
	} 
	if (target) { 
		if (abs(gActiveUnit->xPos - target->xPos) + abs(gActiveUnit->yPos - target->yPos) > 5) 
		AiTryMoveTowards(target->xPos, target->yPos, 0, 0x8, true); // if far from lord, move towards them 
		//AiTryMoveTowards(target->xPos, target->yPos, int decisionId, int safetyThreshold, int ignoreEnemies);

	}
} 

u32 WhatHPWillTargetHaveAfterAIQueueIsDone(int i, int xPos, int yPos, int startHP) { 
    //struct Unit* actor = gActiveUnit; 
    struct BattleUnit* target = &gBattleTarget; 
    int item = 0; 
	int c = 0; 
	int newHP = startHP; 
    for (c = i; c < 115; c++) { 
		if (!gAiState.unitIt[c]) {
			c = 115; 
		break; } // stop when no unit is found  }
		struct Unit* unit = gUnitLookup[c];

		item = GetUnitEquippedWeapon(unit); 
		if (!item) continue;       


		if (!CouldUnitBeInRangeHeuristic(gActiveUnit, unit, item)) {
			continue; 
		} 

		FillMovementAndRangeMapForItem(unit, item); // perhaps this should use a version that assumes they can pass through walls etc. 

		if (!gMapRange[yPos][xPos]) continue; 
		
		if (((unit->skl * 2) + GetItemHit(item) + (unit->lck / 2) - target->battleAvoidRate) > 75) { 
			int res = target->unit.res; 
			int def = target->unit.def; 
			int spd = unit->spd; 
			int unit_power = GetUnitPower(unit);
			int might = GetItemEffMight(item, unit_power, def, res, spd, unit); 
			newHP -= might; 
			if (newHP < 0) newHP = 0; 
			break;
		} 
	} 
	return (c+1)<<16 | newHP; 


} 

int CanAnotherUnitMakeItSafeEnough(void) { 
    struct Unit* actor = gActiveUnit; 
    struct BattleUnit* target = &gBattleTarget; 
	struct AiDecision* gAiDecision = &gAiData.decision; 
	int result = false; 
	int yPos = gAiDecision->yMovement; 
	int xPos = gAiDecision->xMovement; 
    int i = 1; 
    int reducedDanger = gMapMovement2[yPos][xPos] - (target->battleAttack/2); 
    if (actor->curHP <= reducedDanger) { return false; } 
    // even if someone else kills the target, we won't be safe, so don't attack 
	int remainingHP = target->unit.curHP; 
	
	for (int c = 0; c < 50; c++) { 
		remainingHP = WhatHPWillTargetHaveAfterAIQueueIsDone(i, xPos, yPos, remainingHP); 
		i = (remainingHP & 0xFF0000)>>16; // counter  
		if (i > 100) { 
			break; } 
		remainingHP = remainingHP & 0xFFFF; 
		if (!remainingHP) {
			result = true; 
			break; }
    } 

	FillMovementMapForUnit(gActiveUnit); 
    return result; 
	
}

void removeActiveAllegianceFromUnitMap(void) { 
	int ix, iy; 
	int activeAllegiance = (gActiveUnit->index)>>6; 
    for (iy = gMapSize.y - 1; iy >= 0; iy--) {
		u8 * unitRow = gMapUnit[iy];
        for (ix = gMapSize.x - 1; ix >= 0; ix--) {
			if (!unitRow[ix]) 
				continue; // do nothing if already 0 here 
			if (unitRow[ix]>>6 == activeAllegiance) { 
				unitRow[ix] = 0; 
			} 
        }
    }
} 


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
							// we immediately change its type, so we must use else 
							else if (type == 1) type = 0; // axereaver becomes a sword 
							else if (type == 2) type = 1; // swordreaver becomes a lance 	
							
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
	int sword =  weps 	& 0xF; 
	int lance = (weps 	& 0xF0)>>4; 
	int axe = 	(weps 	& 0xF00)>>8; 
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

s8 NewAiFindSafestReachableLocation(struct Unit* unit, struct Vec2* out) {
    int ix;
    int iy;
	int resultX = 0xFF; 
	int resultY = 0xFF; 
    u8 bestDanger = 0xff;

    if (gAiState.flags & AI_FLAG_1) {
        BmMapFill(gMapMovement, -1);
        gMapMovement[unit->yPos][unit->xPos] = 0;
    } else {
        FillMovementMapForUnit(unit);
    }

    for (iy = gMapSize.y - 1; iy >= 0; iy--) {
		u8 * moveRow = gMapMovement[iy];
		u8 * unitRow = gMapUnit[iy];
		u8 * otherRow = gMapMovement2[iy];
		u8 * terrainRow = gMapTerrain[iy]; 
		
        for (ix = gMapSize.x - 1; ix >= 0; ix--) {

            if (moveRow[ix] > 120) { // magic number fsr 
                continue;
            }

            if ((unitRow[ix] != 0) && (unitRow[ix] != gActiveUnitId)) {
                continue;
            }
			int tempDanger = otherRow[ix]; 
			
			if (!tempDanger) { // if 0 danger, don't care about trees etc. 
				resultX = ix; 
				resultY = iy; 
				bestDanger = tempDanger; 
			} 
			if (!unit->index>>7) { 
			tempDanger -= (unit->pClassData->pTerrainAvoidLookup[terrainRow[ix]]/4); // every 4 avoid makes a tile 1 dmg less dangerous  
			tempDanger -= ((unit->pClassData->pTerrainDefenseLookup[terrainRow[ix]])>0); // any def also makes it 1 dmg less dangerous 
			} 
			if (tempDanger < 0) tempDanger = 0; 
			
            if (bestDanger < tempDanger) {
                continue;
            }

			resultX = ix; 
			resultY = iy; 
            bestDanger = tempDanger; 
			
        }
    }
    out->x = resultX;
    out->y = resultY;
    if (bestDanger != 0xFF) {
        return 1;
    }

    return 0;
}

