@ *************** Initial Code ************
@ *************** Cell Phone simulator ****

    .equ    SWI_EXIT,       0x11        @terminate program
@ swi codes for the Embest board
    .equ    SWI_SETSEG8,        0x200   @display on 8 Segment
    .equ    SWI_SETLED,         0x201   @set LEDs on/off
    .equ    SWI_CheckBlack,     0x202   @check press Black button
    .equ    SWI_CheckBlue,      0x203   @check press Blue button
    .equ    SWI_DRAW_STRING,    0x204   @display a string on LCD
    .equ    SWI_DRAW_INT,       0x205   @display an int on LCD  
    .equ    SWI_CLEAR_DISPLAY,  0x206   @clear whole LCD
    .equ    SWI_DRAW_CHAR,      0x207   @display a char on LCD
    .equ    SWI_CLEAR_LINE,     0x208   @clear a line on LCD
    .equ    LASTLINE,           14      @last line on screen
    .equ    SEG_A,      0x80        @ patterns for 8 segment display
    .equ    SEG_B,      0x40
    .equ    SEG_C,      0x20
    .equ    SEG_D,      0x08
    .equ    SEG_E,      0x04
    .equ    SEG_F,      0x02
    .equ    SEG_G,      0x01
    .equ    SEG_P,      0x10                
    .equ    LEFT_LED,   0x02    @patterns for LED lights
    .equ    RIGHT_LED,  0x01
    .equ    BOTH_LED,   0x03
    .equ    NO_LED,     0x00       
    .equ    LEFT_BLACK_BUTTON,  0x02    @patterns for black buttons
    .equ    RIGHT_BLACK_BUTTON, 0x01
@ bit patterns for blue keys used here
    .equ    Blbut15,    0x8000  @ =15
    .equ    Blbut14,    0x4000  @ =14
    .equ    Blbut9,     0x0200  @ =9
    .equ    Blbut8,     0x0100  @ =8
    .equ    Blbut7,     0x0080  @ =7
    .equ    Blbut6,     0x0040  @ =6
    .equ    Blbut5,     0x0020  @ =5
    .equ    Blbut4,     0x0010  @ =4
    .equ    Blbut1,     0x0002  @ =1
    .equ    Blbut0,     0x0001  @ =0
@ add more here......you need 0,1,4,5,6,7

@ timing related
    .equ    SWI_GetTicks,       0x6d    @get current time 
    .equ    EmbestTimerMask,    0x7fff  @ 15 bit mask for Embest timer
                                            @(2^15) -1 = 32,767                                             
    .equ    OneSecond,  1000    @ Time intervals
    .equ    QuarterSec, 250
    .equ    FiveSeconds,    5000
    .equ    LowThresh,  1750

    .text
    .global _start

@@@
_start:

TimeAndPoll:
    @stmfd sp!,{r0-r3,r7-r10,lr}
    mov r3,#0 @set our counter r3 to 0
    mov r5,#0 @counts the # of 10 seconds passed
    mov r8,#0 @r8 serves as led regulator
    mov r1,#0 @clear the dot in the 8-seg
    mov r0,r3
    bl Display8Segment

TimeAndPollPoll:    
    mov r10,#800
    bl WaitFor1or15
    cmp r4,#Blbut1
    beq TimeAndPollDone
    cmp r4,#Blbut15
    beq TimeAndPollDone
    @else, continue.
    @get new target time
    add r3,r3,#1
    cmp r3,#10
    moveq r3,#0
    addeq r5,r5,#1
    mov r0,r3
    mov r1,#0
    bl Display8Segment
    cmp r8,#0 @0=state0, 1=state1
    bne TimeAndPollState1
TimeAndPollState0: @r8 = 0
    mov r10,#100
    mov r0,#BOTH_LED
    swi SWI_SETLED
    bl Wait
    mov r0,#NO_LED
    swi SWI_SETLED
    bl Wait
    mov r0,#BOTH_LED
    swi SWI_SETLED
    
    mov r8,#1
    bal TimeAndPollPoll 
TimeAndPollState1: @r8 = 1
    mov r10,#100
    mov r0,#NO_LED
    swi SWI_SETLED
    bl Wait
    mov r0,#BOTH_LED
    swi SWI_SETLED
    bl Wait
    mov r0,#NO_LED
    swi SWI_SETLED

    mov r8,#0
    bal TimeAndPollPoll
TimeAndPollDone:
    cmp r4,#Blbut15
    beq TimeAndPollExit

    @calculate time passed in seconds
    mov r8,#10
    mov r7,r5
    mul r5,r7,r8
    add r5,r3,r5 @r5 is now aggregated time

TimeAndPollExit:
    @ldmfd sp!,{r0-r3,r7-r10,lr} 

@ ==== void WaitFor1or15(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: R4 = Button pressed (Blbut0 or Blbut15)
@   Description:
@      WaitFor1or15 for r10 milliseconds using a 15-bit timer 
WaitFor1or15:
    stmfd   sp!, {r0-r2,r7-r10,lr}
    ldr     r7, =EmbestTimerMask
    swi     SWI_GetTicks        @get time T1
    and     r1,r0,r7            @T1 in 15 bits
WaitFor1or15Loop:
    swi SWI_CheckBlue
    cmp r0,#Blbut1 @user dialed 1
    beq WaitFor1or15Button
    cmp r0,#Blbut15 @user dialed 15
    beq WaitFor1or15Button

    swi SWI_GetTicks            @get time T2
    and     r2,r0,r7            @T2 in 15 bits
    cmp     r2,r1               @ is T2>T1?
    bge     simpletimeW15
    sub     r9,r7,r1            @ elapsed TIME= 32,676 - T1
    add     r9,r9,r2            @    + T2
    bal     CheckIntervalW15
simpletimeW15:
        sub     r9,r2,r1        @ elapsed TIME = T2-T1
CheckIntervalW15:
    cmp     r9,r10              @is TIME < desired interval?
    blt     WaitFor1or15Loop
WaitFor1or15Button:
    mov r4,r0
WaitFor1or15Done:
    ldmfd   sp!, {r0-r2,r7-r10,pc}

@ ==== void Wait(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: none
@   Description:
@      Wait for r10 milliseconds using a 15-bit timer 
Wait:
    stmfd   sp!, {r0-r2,r7-r10,lr}
    ldr     r7, =EmbestTimerMask
    swi     SWI_GetTicks        @get time T1
    and     r1,r0,r7            @T1 in 15 bits
WaitLoop:
    swi SWI_GetTicks            @get time T2
    and     r2,r0,r7            @T2 in 15 bits
    cmp     r2,r1               @ is T2>T1?
    bge     simpletimeW
    sub     r9,r7,r1            @ elapsed TIME= 32,676 - T1
    add     r9,r9,r2            @    + T2
    bal     CheckIntervalW
simpletimeW:
        sub     r9,r2,r1        @ elapsed TIME = T2-T1
CheckIntervalW:
    cmp     r9,r10              @is TIME < desired interval?
    blt     WaitLoop
WaitDone:
    ldmfd   sp!, {r0-r2,r7-r10,pc}  



@ *** void Display8Segment (Number:R0; Point:R1) ***
@   Inputs:  R0=number to display; R1=point or no point
@   Results:  none
@   Description:
@       Displays the number 0-9 in R0 on the 8-segment
@       If R1 = 1, the point is also shown
@       If R0=10, diplsy is blank
Display8Segment:
    STMFD   sp!,{r0-r2,lr}
    ldr     r2,=Digits
    ldr     r0,[r2,r0,lsl#2]
    tst     r1,#0x01 @if r1=1,
    orrne   r0,r0,#SEG_P            @then show P
    swi     SWI_SETSEG8
    LDMFD   sp!,{r0-r2,pc}


    .data
    .align
Digits:                         @ for 8-segment display
    .word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G   @0
    .word SEG_B|SEG_C                           @1
    .word SEG_A|SEG_B|SEG_F|SEG_E|SEG_D         @2
    .word SEG_A|SEG_B|SEG_F|SEG_C|SEG_D         @3
    .word SEG_G|SEG_F|SEG_B|SEG_C               @4
    .word SEG_A|SEG_G|SEG_F|SEG_C|SEG_D         @5
    .word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C   @6
    .word SEG_A|SEG_B|SEG_C                     @7
    .word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
    .word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C         @9
    .word 0                                     @Blank 
    .align
outgoing_call_str:  .asciz  "Got an outgoing call ...\n"
    .end
