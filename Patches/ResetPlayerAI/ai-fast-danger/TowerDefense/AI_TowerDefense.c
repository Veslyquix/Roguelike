#include "gbafe.h"
#include "stdlib.h" 
extern u8 * * gMapRange;
extern u8 * * gMapMovement2;
extern u8 * * gMapMovement;
extern u8 * * gMapUnit;
extern u8 * * gMapTerrain;
int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item);
void FillMovementAndRangeMapForItem(struct Unit* unit, int item);
extern struct AiState gAiState;
#define UNIT_MOV(aUnit) ((aUnit)->movBonus + UNIT_MOV_BASE(aUnit))
#define UNIT_MOV_BASE(aUnit) ((aUnit)->pClassData->baseMov)

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
extern u8 gWorkingTerrainMoveCosts[];

extern int BuildAiUnitList(void);
extern void SortAiUnitList(int count);
void AiDecideMain(void);
extern void(*AiDecideMainFunc)(void);
extern int GetUnitAiPriority(struct Unit* unit);

int BuildAiUnitListFaction(u32 faction); 
#define CONST_DATA const __attribute__((section(".data")))
u32* CONST_DATA sUnitPriorityArray = (void*) gGenericBuffer;
void NewCpOrderFunc_BeginDecide(Proc* proc)
{
    int unitAmt = BuildAiUnitList(); // for current phase 
	if (unitAmt == 0) { 
		u32 faction = (gChapterData.currentPhase>>6); // enemy phase 
		//if (faction == (gActiveUnit->index)>>6) { // enemy phase finished 
			//RefreshFaction(0); // refresh players 
			unitAmt = BuildAiUnitListFaction(0); // Players to act now 
			//asm("mov r11, r11"); 
		//} 
	
	} 

    if (unitAmt != 0)
    {
        SortAiUnitList(unitAmt);

        gAiState.units[unitAmt] = 0;
        gAiState.unitIt = gAiState.units;

        AiDecideMainFunc = AiDecideMain;

        ProcStartBlocking(gProc_CpDecide, proc);
    }
}


int BuildAiUnitListFaction(u32 faction)
{
    int i, aiNum = 0;
    u32* prioIt = sUnitPriorityArray;

    int factionUnitCountLut[3] = { 62, 20, 50 }; // TODO: named constant for those

    for (i = 0; i < factionUnitCountLut[faction >> 6]; ++i)
    {
        struct Unit* unit = GetUnit(faction + i + 1);

        if (!unit->pCharacterData)
            continue;

        if (unit->statusIndex == UNIT_STATUS_SLEEP)
            continue;

        if (unit->statusIndex == UNIT_STATUS_BERSERK)
            continue;

        if (unit->state & (US_HIDDEN | US_UNSELECTABLE | US_DEAD | US_RESCUED | US_HAS_MOVED_AI))
            continue;

        gAiState.units[aiNum] = faction + i + 1;
        *prioIt++ = GetUnitAiPriority(unit);

        aiNum++;
    }

    return aiNum;
}



