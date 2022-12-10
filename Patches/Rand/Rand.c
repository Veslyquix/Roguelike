#include "gbafe.h"


extern void* gCharRamLocat;


//extern struct CharRamStruct gRamLocat 
//struct CharRamStruct { 
//	CharacterData[0xFF];
//};

void InitializeCharacterRam(void); 

void InitializeCharacterRam(void) { 

	//memcpy((void*)gClassRamLocat, &gClassData[5], 0x54*5); //*0x7F); // dst, src, size // char is 0x34, class 0x54 
	memcpy((void*)gCharRamLocat, &gCharacterData[5], 0x34*5); // dst, src, size 


} 


void MakeUnitUseCharacterRam(void) { 
	Unit* unit = GetUnitByCharId(1);
	unit->pCharacterData = gCharRamLocat;
	
} 














