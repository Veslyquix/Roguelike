
#include "gbafe.h"
typedef struct CreatorClassProcStruct CreatorClassProcStruct;
typedef struct Struct_SelectRelicProc Struct_SelectRelicProc;
typedef struct SomeAISStruct SomeAISStruct;

extern const MenuDefinition gSelectUnitMenuDefs;

int RestartSelectRelic_ASMC(struct MenuProc* menu, struct MenuCommandProc* command);
void SelectRelic_ASMC(Proc* proc);
void SelectRelic_StartMenu(struct Struct_SelectRelicProc* proc);
void RelicCreateMenuGFX(struct Struct_SelectRelicProc* proc);
static int SelectYes(struct MenuProc* menu, struct MenuCommandProc* command);
static void SelectNo(struct MenuProc* menu, struct MenuCommandProc* command);
void SelectRelicMenuEnd_ReturnTrue(void); // Exited menu selecting "yes" - write 1 to memory slot C 
void SelectRelicMenuEnd_ReturnFalse(void); // Exited menu by pressing B - write 0 to memory slot C 
void SelectRelicMenuEnd(void);
static void DrawSelectRelicCommands(struct MenuProc* menu, struct MenuCommandProc* command);
static void DrawDesc(struct MenuProc* menu, struct MenuCommandProc* command);
static const struct MenuDefinition MenuDef_SelectRelic3;
static void DrawYes(struct MenuProc* menu, struct MenuCommandProc* command);
static void DrawNo(struct MenuProc* menu, struct MenuCommandProc* command);

typedef struct Tile Tile;
typedef struct TSA TSA;
struct Tile
{
	u16 tileID : 10;
	u16 horizontalFlip : 1;
	u16 verticalFlip : 1;
	u16 paletteID : 4;
};

struct TSA
{
	u8 width, height;
	Tile tiles[];
};
struct CreatorClassProcStruct
{
	PROC_HEADER
	u8 destructorBool;
};


extern u16 gBG2MapBuffer[32][32]; // 0x02023CA8.
extern u16 gBG0MapBuffer[32][32]; // 0x02022CA8. Snek: Ew why does FE-CLib-master not do it like this?
extern u16 gBG1MapBuffer[32][32]; // 0x020234A8.

extern void LockGameGraphicsLogic(void); // Hide map sprites? ! FE8U = 0x8030185
extern void UnlockGameGraphicsLogic(void); //! FE8U = 0x80301B9
extern void MU_AllDisable(void);
extern void MU_AllEnable(void); 
extern u8 HashByte(int value, int max); 
extern int RelicMaxLink; 
extern TSA RelicDescBoxTSA;
extern TSA RelicTitleBoxTSA;
extern u16 RelicTitleLink;
extern unsigned gEventSlot[];

struct Struct_SelectRelicProc
{
	PROC_HEADER;
	u8 destructorBool; // 0x29.
	u8 currOptionIndex; // 0x2A. 0 = first option, 1 = 2nd option, etc. 
	u8 entry[3];
};

struct Struct_ConfirmationProc
{
	PROC_HEADER;
};
struct RelicNameTableStruct
{
	//const u8 WorldMap_img[];
	void* img;
	void* pal;
	u16 name;
    u16 desc;
	void* func; 
	//u16 pad; 
};

extern struct RelicNameTableStruct RelicNameTable[0xFF]; 
extern void PushToSecondaryOAM(int x, int y, struct ObjData* obj, int pal_flips_tile); 
extern void RegisterObjectTileGraphics(const void* source, void* target, int width, int height); 
void CreatorIdle(Struct_SelectRelicProc* proc)
{
	//return; 


	// Draw whatever's in VRAM for some object (eg. if we wanted a 64x64 img to display) 
	//PushToSecondaryOAM(3<<14|104, 40, &gObj_32x32, 0xB198); //|27<<12);



}

const struct ProcInstruction ProcInstruction_SelectRelic[] =
{
    PROC_CALL_ROUTINE(LockGameLogic),
	//PROC_CALL_ROUTINE(LockGameGraphicsLogic),
	PROC_CALL_ROUTINE(MU_AllDisable), 
	PROC_YIELD,
	//PROC_CALL_ROUTINE(0x8013DA5) // Fade out black 
	
	PROC_LABEL(2),
	PROC_CALL_ROUTINE(SelectRelic_StartMenu),
	//PROC_CALL_ROUTINE(RelicCreateMenuGFX),

	PROC_LABEL(0),
    PROC_LOOP_ROUTINE(CreatorIdle),

	PROC_LABEL(1),
	PROC_END_ALL(0x85B64D1), //#define MenuProc 0x5B64D0
	PROC_CALL_ROUTINE(UnlockGameLogic),
	//PROC_CALL_ROUTINE(UnlockGameGraphicsLogic), 
	PROC_CALL_ROUTINE(MU_AllEnable),
	
    PROC_END,
};



static const struct ProcInstruction ProcInstruction_Confirmation[] =
{
    PROC_YIELD,
    PROC_END,
};






static const struct MenuCommandDefinition MenuCommands_ConfirmationProc[] =
{
    {
        .isAvailable = MenuCommandAlwaysUsable,
		.onDraw = DrawYes,
        .onEffect = SelectYes,
    },

    {
        .isAvailable = MenuCommandAlwaysUsable,

        .onDraw = DrawNo, 
        .onEffect = SelectNo,
    },
    {} // END
};





static const struct MenuDefinition MenuDef_ConfirmCharacter =
{
    .geometry = { 25, 13, 5 },
    .commandList = MenuCommands_ConfirmationProc, 

    //.onEnd = SelectRelicMenuEnd,
    .onBPress = (SelectNo), 
};


extern int Clean(Proc* proc); 
void SelectRelic_ASMC(Proc* proc) // ASMC 
{
	Struct_SelectRelicProc* charProc = ProcStartBlocking(ProcInstruction_SelectRelic, proc);
}

void SelectRelic_StartMenu(struct Struct_SelectRelicProc* proc)
{
	proc->entry[0] = HashByte(0, RelicMaxLink)+1;
	proc->entry[1] = HashByte(1, RelicMaxLink)+1;
	proc->entry[2] = HashByte(2, RelicMaxLink)+1;
	
	int c = 3; 
	while (proc->entry[1] == proc->entry[0]) {
		proc->entry[1] = HashByte(c, RelicMaxLink);
		c++;
	}
	c = 3; 
	while ((proc->entry[2] == proc->entry[0]) | (proc->entry[2] == proc->entry[1])) {
		proc->entry[2] = HashByte(c, RelicMaxLink);
		c++; 
	}
	proc->currOptionIndex = 0; 
	
	//
	Text_SetFont(0);
    //Text_SetFontStandardGlyphSet(0);
	Font_LoadForUI();
	LoadNewUiFrameGraphics(); 
	Text_ResetTileAllocation();
	RelicCreateMenuGFX(proc); 
	StartMenu(&MenuDef_SelectRelic3);
	
}









enum {
NL = 1, // Text control code for new line.
};
static int GetNumLines(char* string) // Basically count the number of NL codes.
{
	int sum = 1;
	for ( int i = 0 ; string[i] ; i++ )
	{
		if ( string[i] == NL ) { sum++; }
	}
	return sum;
}
static void DrawMultiline(TextHandle* handles, char* string, int lines) // There's a TextHandle for every line we need to pass in.
{
    // We're going to copy each line of the string to gGenericBuffer then draw the string from there.
	int j = 0;
    for ( int i = 0 ; i < lines ; i++ )
    {
        int k = 0;
        for ( ; string[j] && string[j] != NL ; k++ )
        {
            gGenericBuffer[k] = string[j];
            j++;
        }
        gGenericBuffer[k] = 0;

		u32 width = ((Text_GetStringTextWidth((char*)gGenericBuffer))+8)/8;

		Text_InitClear(&handles[i], width);
		handles[i].tileWidth = width;
		//handles[i].xCursor = 0;
		//handles[i].colorId = TEXT_COLOR_NORMAL;
		//handles[i].useDoubleBuffer = 0;
		//handles[i].currentBufferId = 0;
		//handles[i].unk07 = 0;
		
        Text_InsertString(&handles[i],0,handles->colorId,(char*)gGenericBuffer);
        //Text_DrawString(&handles[i],(char*)gGenericBuffer);
        //handles++;
        j++;
    }
}

extern u16 SkillDescTable[0xFF]; 
#define SKILL_ICON(aSkillId) ((1 << 8) + (aSkillId))
static void DrawSelectRelicCommandDrawIdle(struct MenuCommandProc* command)
{
	Struct_SelectRelicProc* selectRelicProc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);
	u16* const out = gBg0MapBuffer + TILEMAP_INDEX(command->xDrawTile, command->yDrawTile);
	DrawIcon(out + TILEMAP_INDEX(0, 0), SKILL_ICON(selectRelicProc->entry[command->commandDefinitionIndex]), TILEREF(0, 4));
}

extern u8 gCurrentTextString[0xFF]; 
static void DrawSelectRelicCommands(struct MenuProc* menu, struct MenuCommandProc* command)
{
	u16* const out = gBg0MapBuffer + TILEMAP_INDEX(command->xDrawTile, command->yDrawTile);
	//Text_SetColorId(&command->text, TEXT_COLOR_GREEN);
	Struct_SelectRelicProc* selectRelicProc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);
	u8 skillID = selectRelicProc->entry[command->commandDefinitionIndex];
	
	//char* string = GetStringFromIndex(RelicNameTable[selectRelicProc->entry[command->commandDefinitionIndex]].name);
	char* string = GetStringFromIndex(SkillDescTable[skillID]);
	//string = gCurrentTextString; 
	for (u8 i = 0; i<0xFF; i++)
	{
		if ((gCurrentTextString[i] == 0x3A) | ( gCurrentTextString[i] == 0 ) ) { 
			gCurrentTextString[i] = 0; 
			break; 
		} 
	}
	
	u32 width = (Text_GetStringTextWidth(gCurrentTextString)+25)/8;
	Text_InitClear(&command->text, width);
	Text_SetXCursor(&command->text, 17);
	Text_DrawString(&command->text, gCurrentTextString); 

	
	
	//ObjInsertSafe(0, 
	//ObjInsertSafe(int node, u16 xBase, u16 yBase, const struct ObjData* pData, u16 tileBase);
    command->onCycle = DrawSelectRelicCommandDrawIdle;
		
	Text_Display(&command->text, out);
	
	EnableBgSyncByMask(BG0_SYNC_BIT);
}



static void DrawDesc(struct MenuProc* menu, struct MenuCommandProc* command)
{
	Text_ResetTileAllocation();
	
	
	for (int x = 0; x < 30; x++) { // clear out bg0 text
		for (int y = 0; y < 20; y++) { 
			gBG0MapBuffer[y][x] = 0;
		}
	}
	

	DrawSelectRelicCommands(menu, menu->pCommandProc[0]); 
	DrawSelectRelicCommands(menu, menu->pCommandProc[1]); 
	DrawSelectRelicCommands(menu, menu->pCommandProc[2]); 
	
	Struct_SelectRelicProc* proc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);
	RelicCreateMenuGFX(proc); 
	proc->currOptionIndex = menu->commandIndex; 
	
	
	
	//char* string = GetStringFromIndex(RelicNameTable[proc->entry[menu->commandIndex]].desc);
	u8 skillID = proc->entry[command->commandDefinitionIndex];
	char* string = GetStringFromIndex(SkillDescTable[skillID]);
	
	int lines = GetNumLines(string);
	TextHandle handles[lines];
	for ( int i = 0 ; i < lines ; i++ )
	{
		handles[i].xCursor = 0;
		handles[i].colorId = TEXT_COLOR_NORMAL;
		handles[i].useDoubleBuffer = 0;
		handles[i].currentBufferId = 0;
		handles[i].unk07 = 0;
	}
	DrawMultiline(handles, string, lines);
	for ( int i = 0 ; i < lines ; i++ )
	{
		Text_Display(&handles[i],&gBG0MapBuffer[13+i*2][6]);
	}
	
	EnableBgSyncByMask(BG0_SYNC_BIT);
	
	/*
	// Prepare some image 
	Decompress(RelicNameTable[proc->entry[proc->currOptionIndex]].img, &gGenericBuffer[400]);
	RegisterObjectTileGraphics(&gGenericBuffer[400], (void*)0x6013300, 8, 8); 
	CopyToPaletteBuffer(RelicNameTable[proc->entry[proc->currOptionIndex]].pal, 27*32, 32); 
	*/
	
}

static int SelectRelic(struct MenuProc* menu, struct MenuCommandProc* command)
{
	Struct_SelectRelicProc* selectRelicProc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);
	selectRelicProc->currOptionIndex = menu->commandIndex; 
	
	StartMenuChild(&MenuDef_ConfirmCharacter, (void*) menu);
	return ME_PLAY_BEEP; 
	//return ME_DISABLE | ME_PLAY_BEEP;
	//return ME_DISABLE | ME_END | ME_PLAY_BEEP;
	//return ME_DISABLE | ME_END | ME_PLAY_BEEP | ME_CLEAR_GFX;
}

static void DrawNo(struct MenuProc* menu, struct MenuCommandProc* command)
{
	u16* const out = gBg0MapBuffer + TILEMAP_INDEX(command->xDrawTile, command->yDrawTile);
	TextHandle* currHandle = &command->text;
    Text_Clear(currHandle);
	Text_SetColorId(currHandle, TEXT_COLOR_NORMAL);
	
	Text_DrawString(currHandle," No");
	//Text_InsertString(currHandle,0,TEXT_COLOR_NORMAL," No");
    Text_Display(currHandle, out);
}

static void DrawYes(struct MenuProc* menu, struct MenuCommandProc* command)
{

	
	u16* const out = gBg0MapBuffer + TILEMAP_INDEX(command->xDrawTile, command->yDrawTile);
	TextHandle* currHandle = &command->text;
    Text_Clear(currHandle);
	Text_SetColorId(currHandle, TEXT_COLOR_NORMAL);
	
	Text_DrawString(currHandle," Yes");
	//Text_InsertString(currHandle,0,TEXT_COLOR_NORMAL," Yes");
    Text_Display(currHandle, out);
	
}


extern void CallFunction(void* function); 


static int SelectYes(struct MenuProc* menu, struct MenuCommandProc* command)
{
	SelectRelicMenuEnd_ReturnTrue();
	//proc->destructorBool = 1; // Start destruction sequence  
	//ProcGoto(proc, 1); // Destructor label 
	
	Struct_SelectRelicProc* proc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);

	CallFunction(RelicNameTable[proc->entry[proc->currOptionIndex]].func);
	// save the choice we made 
	
	EndAllMenus(menu);

	//return ME_END | ME_PLAY_BEEP;
	return ME_DISABLE | ME_END | ME_PLAY_BEEP | ME_CLEAR_GFX;
}

static void SelectNo(struct MenuProc* menu, struct MenuCommandProc* command)
{
	EndAllMenus(menu);
	SelectRelicMenuEnd_ReturnFalse();
	//return ME_DISABLE | ME_END | ME_PLAY_BEEP | ME_CLEAR_GFX;
	//return ME_DISABLE | ME_END | ME_PLAY_BEEP | ME_CLEAR_GFX;
}


void SelectRelicMenuEnd_ReturnTrue(void)
{
	SelectRelicMenuEnd();
	Struct_SelectRelicProc* proc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);
	
	
	
	ProcGoto((Proc*)proc,1); // Destructor sequence 
}

void SelectRelicMenuEnd_ReturnFalse(void)
{
	//gEventSlot[0xC] = 0x100;
	SelectRelicMenuEnd();
	
	//CreatorClassProcStruct* creatorClass = (CreatorClassProcStruct*)ProcFind(&ProcInstruction_CreatorClassProc);
	//CreatorClassEndProc(creatorClass);
	
	Struct_SelectRelicProc* proc = (Struct_SelectRelicProc*)ProcFind(&ProcInstruction_SelectRelic);
	
	ProcGoto((Proc*)proc,2); // Restart sequence 
}


void SelectRelicMenuEnd(void)
{	
	//FillBgMap(gBg0MapBuffer,0);
	//FillBgMap(gBg1MapBuffer,0);
	//FillBgMap(gBg2MapBuffer,0);
	//EnableBgSyncByMask(1|2|4);
	
}


static const struct MenuCommandDefinition MenuCommands_CharacterProc3[] =
{
    {
		.colorId = TEXT_COLOR_GREEN, 
        .isAvailable = MenuCommandAlwaysUsable,
        .onEffect = SelectRelic,
		.onDraw = DrawSelectRelicCommands,
		.onSwitchIn = DrawDesc, 

    },

    {
		.colorId = TEXT_COLOR_GREEN, 
        .isAvailable = MenuCommandAlwaysUsable,
        .onEffect = SelectRelic,
		.onDraw = DrawSelectRelicCommands,
		.onSwitchIn = DrawDesc, 

    },
    {
		.colorId = TEXT_COLOR_GREEN, 
        .isAvailable = MenuCommandAlwaysUsable,
        .onEffect = SelectRelic,
		.onDraw = DrawSelectRelicCommands,
		.onSwitchIn = DrawDesc, 

    },
    {} // END
};

static const struct MenuDefinition MenuDef_SelectRelic3 =
{
    .geometry = { 1, 5, 14 },
	.style = 0,
    .commandList = MenuCommands_CharacterProc3,
	._u14 = 0,
    //.onEnd = SelectRelicMenuEnd_ReturnFalse,
	.onInit = 0,
	.onBPress = SelectRelicMenuEnd_ReturnFalse,
	.onRPress = 0,
	.onHelpBox = 0, 	
};

void RelicCreateMenuGFX(struct Struct_SelectRelicProc* proc)
{
	//ClearBG0BG1();

	/*
	for (int x = 0; x < 30; x++) { // clear out bg1 menu gfx 
		for (int y = 0; y < 20; y++) { 
			gBG1MapBuffer[y][x] = 0;
		}
	}
	EnableBgSyncByMask(BG0_SYNC_BIT|BG1_SYNC_BIT);
	*/
	BgMap_ApplyTsa(&gBG1MapBuffer[0][1], &RelicTitleBoxTSA, 0);
	BgMap_ApplyTsa(&gBG1MapBuffer[13][5], &RelicDescBoxTSA, 0);
	
	char* string = GetStringFromIndex(RelicTitleLink);
	int lines = GetNumLines(string);
	TextHandle handles[lines];
	for ( int i = 0 ; i < lines ; i++ )
	{
		handles[i].xCursor = 0;
		handles[i].colorId = TEXT_COLOR_NORMAL;
		handles[i].useDoubleBuffer = 0;
		handles[i].currentBufferId = 0;
		handles[i].unk07 = 0;
	}
	DrawMultiline(handles, string, lines);
	for ( int i = 0 ; i < lines ; i++ )
	{
		Text_Display(&handles[i],&gBG0MapBuffer[0+i*2][2]);
	}
	
	EnableBgSyncByMask(BG0_SYNC_BIT|BG1_SYNC_BIT);
}





