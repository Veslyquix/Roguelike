.thumb
.include "mss_defs.s"

.global MSS_page4
.type MSS_page4, %function


MSS_page4:

page_start

draw_textID_at 17, 9, 0xd4b, 16, Green

draw_textID_at 1, 1, 0x1, 1 Green

page_end
