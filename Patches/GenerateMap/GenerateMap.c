#include "gbafe.h"
#include <string.h>
// F42C Event2A_MoveToChapter
// gets chapter ID (sometimes from mem slot 2) 
// stores this to gChapterData + 0x4A as chapter to go to 
// passes 1, 2, or 3 to 0x08009F50   //SetNextGameActionId
// in procs_gamectrl 0x85916D4 it calls SetupChapter 0x8030E05 at $5918DC in label 7 
// gChapterData + 0x04 looks like chapter clock time at start of the chapter 
// +0x48 looks like Total Support Points at start of the chapter
// I dunno what +0x4A and +0x4B are but I think there's some bitpacking going on and 
// +0x4A seems to be set depending on what MNC version you do
// InitChapterMap at 194BC calls LoadChapterMap at 198AC which decompresses map 
// [0x80198B8]

extern bool CheckEventId(int flag);
extern bool SetEventId(int flag);
extern bool UnsetEventId(int flag);


void CopyMapPiece(u16 dst[], u8 xx, u8 yy, u8 map_size_x, u8 map_size_y, u16 defaultTile);

struct MapPieces_Struct
{
	u8 x; 
	u8 y; 
	u16 data[0xff]; 
};
extern u8 TilesetTable[0xFF];
extern int UseFrontierLink; 
extern int UseVillageLink; 

struct MapPieces_Struct_Poin 
{
	struct MapPieces_Struct* mapPieces[0xFF]; 
};

struct PoinTilesetInfo_Struct
{
	struct MapPieces_Struct_Poin* MapPiecesPoin; 
};
struct PoinTilesetPieces_Struct
{
	int* numberOfMapPieces; 
};

//extern struct PoinTilesetInfo_Struct TilesetPointerTable[0xFF];
extern struct MapPieces_Struct_Poin* TilesetPointerTable[0xFF];
extern int* TilesetPiecesTable[0xFF];




extern int FrequencyOfObjects_Link; 

struct GeneratedMapDimensions_Struct
{
	u8 min_x; 
	u8 min_y; 
	u8 max_x; 
	u8 max_y; 
};

extern struct GeneratedMapDimensions_Struct GeneratedMapDimensions;



struct Map_Struct
{
	u8 x; 
	u8 y; 
	u16 data[0xff]; 
};
void GenerateMap(struct Map_Struct* dst);

static char* const TacticianName = (char* const) (0x202bd10); //8 bytes long
extern u32* StartTimeSeedRamLabel; 

u8 HashByte(u8 number, int max){
  if (max==0) return 0;
  u32 hash = 5381;
  hash = ((hash << 5) + hash) ^ number;
  hash = ((hash << 5) + hash) ^ gChapterData.chapterIndex;
  hash = ((hash << 5) + hash) ^ *StartTimeSeedRamLabel;
  for (int i = 0; i < 9; ++i){
    if (TacticianName[i]==0) break;
    hash = ((hash << 5) + hash) ^ TacticianName[i];
  };
  return Mod((u16)hash, max);
};

u16 HashShort(u8 number, int max){
  if (max==0) return 0;
  u32 hash = 5381;
  hash = ((hash << 5) + hash) ^ number;
  hash = ((hash << 5) + hash) ^ gChapterData.chapterIndex;
  hash = ((hash << 5) + hash) ^ *StartTimeSeedRamLabel;
  for (int i = 0; i < 9; ++i){
    if (TacticianName[i]==0) break;
    hash = ((hash << 5) + hash) ^ TacticianName[i];
  };
  return Mod((u16)hash, max);
};


int HashInt(int number, int max){
  if (max==0) return 0;
  u32 hash = 5381;
  hash = ((hash << 5) + hash) ^ number;
  hash = ((hash << 5) + hash) ^ gChapterData.chapterIndex;
  hash = ((hash << 5) + hash) ^ *StartTimeSeedRamLabel;
  for (int i = 0; i < 9; ++i){
    if (TacticianName[i]==0) break;
    hash = ((hash << 5) + hash) ^ TacticianName[i];
  };
  return Mod((u32)hash, max);
};

// game time initialized -> chapter start events -> when map needs to be displayed, then it is loaded (so if you are faded in, events occur first) 
extern struct ChapterState gChapterData; 
	
void GenerateMap(struct Map_Struct* dst)
{
	// 2 bytes are the map's XX / YY size
	// then it's just SHORTs of the different tileset IDs in a row as YY << 7 | XX << 2
	// uncompressed size is 0x512 / #1298


	// hooked InitChapterMap to update gChapterData._u04 right before LoadChapterMap instead of right after 
	
	
	// GmDataInit 0x80BC81C at BC884 calls SetRandState();
	// 300534D
	u16 saveRandState[3]; 
	GetRandState(saveRandState); // commented this out by accident which was causing crits to always occur lol 
	//int clock = GetGameClock(); 
	//int t_start = gChapterData._u04;
	//asm("mov r11, r11"); 
	//if (t_start != clock) { 
	u16 var[3]; 
	u8 x; 
	
	for (u8 c=0; c<3; c++) { 
		x = HashShort(c, 255); 
		var[c] = HashShort(x, 255); 
	} 
	SetRandState(var); //! FE8U = (0x08000C4C+1)
	//} 
	
	struct GeneratedMapDimensions_Struct dimensions = GeneratedMapDimensions;
	
	dst->x = (NextRN_N(dimensions.max_x-dimensions.min_x)+dimensions.min_x); 
	dst->y = (NextRN_N(dimensions.max_y-dimensions.min_y)+dimensions.min_y);
	u16 c = 0; 
	while (((dst->x * dst->y) > 1500) && (c<255)) { // redo if it will exceed max map size 
		dst->x = (NextRN_N(dimensions.max_x-dimensions.min_x)+dimensions.min_x); 
		dst->y = (NextRN_N(dimensions.max_y-dimensions.min_y)+dimensions.min_y);
		c++; 
	}
	if (c == 255) { dst->y = 10; }  // if we try 255 times and fail, make height the min of 10. 

	u8 map_size_x = dst->x;
	u8 map_size_y = dst->y; 
	//int FrequencyOfObjects_Link; 
	// creates a randomized map 
	for (int iy = 0; iy<map_size_y; iy++) {
		for (int ix = 0; ix < map_size_x; ix++) {
			//u16 value = 0;
			//while (!value) { // never be 0 
				//value = NextRN_N(32) <<7 | (NextRN_N(32)<<2); // I think NextRN_N is 0-indexed, so given 4 it will return max 3 
			//}
			//dst->data[iy*x+ix] = value;  // totally random tiles 
			
			if (FrequencyOfObjects_Link > NextRN_N(100)) { 
				
				CopyMapPiece(dst->data, ix, iy, map_size_x, map_size_y, dst->data[map_size_y*map_size_x+map_size_x]); // bottom right tile as default tile 
			}  
			//else { dst->data[iy * map_size_x + iy] = dst->data[map_size_y*map_size_x+map_size_x]; } 
		
		}
	}
	SetEventId(8); // don't spawn the traps again 
	SetRandState(saveRandState); 
}

extern int DoorTrapID_Link; 
extern int BreakableWallTrapID_Link; 
extern int VillageATrapID_Link;
extern int VillageBTrapID_Link;
extern int VillageCTrapID_Link;
extern int VillageDTrapID_Link;
extern int VillageETrapID_Link;
extern int BlankVillageTrapID_Link;



void CopyMapPiece(u16 dst[], u8 placement_x, u8 placement_y, u8 map_size_x, u8 map_size_y, u16 defaultTile)
{

	u8 index = TilesetTable[gChapterData.chapterIndex];
	//asm("mov r11, r11");
	int numberOfMapPieces = *TilesetPiecesTable[index];
	//asm("mov r11, r11");
	struct MapPieces_Struct* T = TilesetPointerTable[index]->mapPieces[NextRN_N(numberOfMapPieces)];
	//asm("mov r11, r11"); 
	u8 piece_size_x = (T->x);
	u8 piece_size_y = (T->y);
	
	u8 exit = false; // default to false 

	u8 border_y = placement_y;
	u8 border_x = placement_x;
	if ((placement_y) && ((piece_size_y > 1)||(piece_size_x > 1))) { // border of 1 tile on left/above 
		border_y = placement_y - 1; 
	}
	if ((placement_x) && ((piece_size_y > 1)||(piece_size_x > 1))) { 
		border_x = placement_x - 1; 
	} 
	for (u8 y = 0; y <= piece_size_y+1; y++) {
		for (u8 x = 0; x <= piece_size_x+1; x++) { // if any tile is not the default, then immediately exit 
			if (dst[(border_y+y) * map_size_x + border_x+x] != defaultTile) { exit = true; } 
		}
	}
	int loc; 
		// this line is to stop it from drawing outside the map / from one side to another 
	if (!(((piece_size_x + placement_x) > map_size_x) || ((piece_size_y + placement_y) > map_size_y) || (exit)))  {
		for (u8 y = 0; y<piece_size_y; y++) {
			for (u8 x = 0; x < piece_size_x; x++) {
				loc = ((placement_y+y) * map_size_x) + placement_x+x; 
				//dst[((placement_y+y) * map_size_x) + placement_x+x] = T->data[y*piece_size_x+x]; 
				dst[loc] = T->data[y*piece_size_x+x]; 
				
				// frontier 

				if (TilesetTable[gChapterData.chapterIndex] == UseFrontierLink) { 
				if (!(CheckEventId(8))) { 
				if (dst[loc] == 0x400) { // door at 4x 11y in tileset (0-indexed) 
					dst[loc] = 0x10; // plain
					AddTrap(placement_x+x, placement_y+y, DoorTrapID_Link, 0);
				}
				if (dst[loc] == 0x84) { // Chest
					dst[loc] = 0x4; // Open chest 
					//AddTrap(placement_x+x, placement_y+y, DoorTrapID_Link, 0);
				}
				if (dst[loc] == 0xE3C) { // broken wall big 
					dst[loc] = 0x10; // floor no shadow 
					AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				
				// add village
				if ((dst[loc] == 0xD1C) | (dst[loc] == 0xCAC)) { // add village traps 
					AddTrap(placement_x+x, placement_y+y, VillageATrapID_Link, 0);
					AddTrap(placement_x+x, placement_y+y-1, BlankVillageTrapID_Link, 0);
				}
				if ((dst[loc] == 0xD20) | (dst[loc] == 0xCB0)) { // add village traps 
					AddTrap(placement_x+x, placement_y+y, VillageBTrapID_Link, 0);
					AddTrap(placement_x+x, placement_y+y-1, VillageETrapID_Link, 0);
				}
				if ((dst[loc] == 0xD24) | (dst[loc] == 0xCB4)) { // add village traps 
					AddTrap(placement_x+x, placement_y+y, VillageCTrapID_Link, 0);
					AddTrap(placement_x+x, placement_y+y-1, BlankVillageTrapID_Link, 0);
				}
				} 
				}
				
				
				
				// this is hardcoded to the village tileset atm 
				if (TilesetTable[gChapterData.chapterIndex] == UseVillageLink) { 
				if ((dst[loc] == 0xC8C) || (dst[loc] == 0xC80) || (dst[loc] == 0xC98)) { // village 1/6  
					dst[loc] = 0xCA4; // ruins 1/6
					//AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				if ((dst[loc] == 0xC90) || (dst[loc] == 0xC84) || (dst[loc] == 0xC9C)) { // village 2/6  
					dst[loc] = 0xCA8; // ruins 2/6
					//AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				if ((dst[loc] == 0xC94) || (dst[loc] == 0xC88) || (dst[loc] == 0xCA0)) { // village 3/6  
					dst[loc] = 0xCAC; // ruins 3/6
					//AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				if ((dst[loc] == 0xD0C) || (dst[loc] == 0xD00) || (dst[loc] == 0xD18)) { // village 4/6  
					dst[loc] = 0xD24; // ruins 4/6
					//AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				if ((dst[loc] == 0xD10) || (dst[loc] == 0xD04) || (dst[loc] == 0xD1C)) { // village 5/6  
					dst[loc] = 0xD28; // ruins 5/6
					//AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				if ((dst[loc] == 0xD14) || (dst[loc] == 0xD08) || (dst[loc] == 0xD20)) { // village 6/6  
					dst[loc] = 0xD2C; // ruins 6/6
					//AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				
				if (!(CheckEventId(8))) { 
				if (dst[loc] == 0x590) { // door at 4x 11y in tileset (0-indexed) 
					dst[loc] = 0x8BC; // floor with left shadow 
					AddTrap(placement_x+x, placement_y+y, DoorTrapID_Link, 0);
				}
				if (dst[loc] == 0x104) { // Chest
					dst[loc] = 0x100; // Open chest 
					//AddTrap(placement_x+x, placement_y+y, DoorTrapID_Link, 0);
				}
				if (dst[loc] == 0xBC8) { // broken wall big 
					dst[loc] = 0x840; // floor no shadow 
					AddTrap(placement_x+x, placement_y+y, BreakableWallTrapID_Link, 0);
				}
				
				// add either village or house at random 
				if (dst[loc] == 0xD24) { // add village traps 
					AddTrap(placement_x+x, placement_y+y, VillageATrapID_Link, 0);
					AddTrap(placement_x+x, placement_y+y-1, BlankVillageTrapID_Link, 0);
				}
				if (dst[loc] == 0xD28) { // add village traps 
					AddTrap(placement_x+x, placement_y+y, VillageBTrapID_Link, 0);
					AddTrap(placement_x+x, placement_y+y-1, VillageETrapID_Link, 0);
				}
				if (dst[loc] == 0xD2C) { // add village traps 
					AddTrap(placement_x+x, placement_y+y, VillageCTrapID_Link, 0);
					AddTrap(placement_x+x, placement_y+y-1, BlankVillageTrapID_Link, 0);
				}
				} 
				
				}

			}
		}
	}

}
