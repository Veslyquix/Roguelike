@ 0-7 buffs, 1 byte per stat 
@ mag/str/skl/spd/def/res/luk/mov 
@8: Rallies (str/skl/spd/def/res/luk) (bit 7 = rally move, bit 8 = rally spectrum)
@9: bit 1 = half str, bit 2 = half mag, bit 3 = hexing rod, bit 4 = rally mag, bits 5-8 are free 




.equ mag, 0 @ signed. eg up to +127 or -128 in a stat.
.equ str, 1 
.equ skl, 2 
.equ spd, 3 
.equ def, 4 
.equ res, 5 
.equ luk, 6 
.equ mov, 7 

.equ RallyByte, 8 
	.equ StrBit, 1<<0 
	.equ SklBit, 1<<1 
	.equ SpdBit, 1<<2 
	.equ DefBit, 1<<3 
	.equ ResBit, 1<<4 
	.equ LukBit, 1<<5 
	.equ MovBit, 1<<6 
	.equ SpecBit, 1<<7 

.equ MiscByte, 9
	.equ HalfStrBit, 1<<0
	.equ HalfMagBit, 1<<1 
	.equ HexBit, 1<<2 
	.equ MagBit, 1<<3 @ rally 
	.equ ArmorMarchBit, 1<<4 
	.equ VigorDanceBit, 1<<5 





