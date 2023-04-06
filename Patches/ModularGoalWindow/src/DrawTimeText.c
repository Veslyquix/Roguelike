#include "ModularGoalWindow.h"

//Adapted from Stan's FE7 version

//TODO: Add a target time argument to count down to
//TODO: Handle negative numbers for the clock text

struct ProcInstruction const ClockTextProcInstruction[] = {
    PROC_LOOP_ROUTINE(UpdateClockText),
    PROC_END,
};

//Helper function to draw a number as two digits
static void DrawNumber2Chars(struct TextHandle* text, u16 number) {
    char digit_a = '0' + __modsi3(number, 10);
    char digit_b = '0' + __divsi3(number, 10);

    Text_DrawChar2(text, &digit_a);
    text->xCursor -= 15;
    Text_DrawChar2(text, &digit_b);
    text->xCursor -= 15;
}
extern const void* EnableFogEvent; 
//Draws formatted time as
void DrawClockText(ClockTextProc* proc) {
    int x = proc->x;
    struct TextHandle* text = proc->text;

    Text_Clear(text);
    
    u16 hours, minutes, seconds;

    //Use chapter start time for start of the timer
   //FormatTime(
   //    (GetGameClock() - gChapterData._u04),
   //    &hours,
   //    &minutes,
   //    &seconds
   //);
   int time = proc->timer - ((GetGameClock() - gChapterData._u04) - proc->initialTime);
   //int time = proc->timer - gChapterData._u04;
   
   if (time < 60) { 
	   time = 0; 
	   if (!proc->changedFog) { 
			CallMapEventEngine(&EnableFogEvent, 1); 
			proc->changedFog = true; 
	   } 
   } 
    FormatTime(
        (time),
        &hours,
        &minutes,
        &seconds
    );

    Text_SetXCursor(text, x +  0); DrawNumber2Chars(text, hours);
    Text_SetXCursor(text, x +  9); Text_DrawString(text, ":");
    Text_SetXCursor(text, x + 21); DrawNumber2Chars(text, minutes);
    Text_SetXCursor(text, x + 30); Text_DrawString(text, ":");
    Text_SetXCursor(text, x + 42); DrawNumber2Chars(text, seconds); 
}

//Refreshes the clock every 60 frames
void UpdateClockText(ClockTextProc* proc) {
    proc->clock += 1;

    if (proc->clock == 60) {
        proc->clock = 0;
        DrawClockText(proc);
    }
}
extern int myRam; 

//Starts and initializes Clock Text Proc
void StartClockText(TextHandle* text, int x, GoalWindowProc* parent) {
    ClockTextProc* proc = ProcStart(ClockTextProcInstruction, parent);
	proc->initialTime = myRam; 
    proc->timer = 60*12; 
    proc->x = x;
    proc->clock = 0;
    proc->text = text;
	proc->changedFog = false; 

    DrawClockText(proc);
}
void ResetToTenSeconds(void) { 
	ClockTextProc* proc = ProcFind(ClockTextProcInstruction);
	proc->timer = 60*10; 
	myRam = GetGameClock() - gChapterData._u04;
	proc->initialTime = GetGameClock() - gChapterData._u04; 
	proc->changedFog = false; 
	return; 
} 

