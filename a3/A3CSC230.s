@ *************** Bill Xiong V00737042 ****
@ *************** Cell Phone simulator ****
	.equ    SWI_EXIT, 		0x11		@terminate program
@ swi codes for the Embest board
	.equ    SWI_SETSEG8, 		0x200	@display on 8 Segment
	.equ    SWI_SETLED, 		0x201	@set LEDs on/off
	.equ    SWI_CheckBlack, 	0x202	@check press Black button
	.equ    SWI_CheckBlue, 		0x203	@check press Blue button
	.equ    SWI_DRAW_STRING, 	0x204	@display a string on LCD
	.equ    SWI_DRAW_INT, 		0x205	@display an int on LCD  
	.equ    SWI_CLEAR_DISPLAY, 	0x206	@clear whole LCD
	.equ    SWI_DRAW_CHAR, 		0x207	@display a char on LCD
	.equ    SWI_CLEAR_LINE, 	0x208	@clear a line on LCD
	.equ	LASTLINE,			14		@last line on screen
	.equ 	SEG_A,		0x80		@ patterns for 8 segment display
	.equ 	SEG_B,		0x40
	.equ 	SEG_C,		0x20
	.equ 	SEG_D,		0x08
	.equ 	SEG_E,		0x04
	.equ 	SEG_F,		0x02
	.equ 	SEG_G,		0x01
	.equ 	SEG_P,		0x10                
	.equ    LEFT_LED, 	0x02	@patterns for LED lights
	.equ    RIGHT_LED, 	0x01
	.equ    BOTH_LED, 	0x03
	.equ    NO_LED, 	0x00       
	.equ    LEFT_BLACK_BUTTON, 	0x02	@patterns for black buttons
	.equ    RIGHT_BLACK_BUTTON, 0x01
@ bit patterns for blue keys used here
	.equ    Blbut15, 	0x8000	@ =15
    .equ    Blbut14,    0x4000  @ =14
    .equ    Blbut9,     0x0200  @ =9
    .equ    Blbut8,     0x0100  @ =8
	.equ    Blbut7, 	0x0080	@ =7
	.equ    Blbut6, 	0x0040	@ =6
	.equ    Blbut5, 	0x0020	@ =5
	.equ    Blbut4, 	0x0010	@ =4
	.equ    Blbut1, 	0x0002	@ =1
	.equ    Blbut0, 	0x0001	@ =0
@ add more here......you need 0,1,4,5,6,7

@ timing related
	.equ    SWI_GetTicks, 		0x6d	@get current time 
	.equ    EmbestTimerMask, 	0x7fff	@ 15 bit mask for Embest timer
											@(2^15) -1 = 32,767        										
	.equ	OneSecond,	1000	@ Time intervals
	.equ	QuarterSec,	250
	.equ	FiveSeconds,	5000

	.text
	.global	_start
	
_start:
@load code, then wait for Blue=14 to start program
LoadProgr:
	BL	WaitForBlueStartStop	@R0=WaitForBlueStartStop()
	cmp	R0,#1					@exit program?
	beq	ExitProgr
	BL	Init			@else initialize peripherals void Init()
CallStart:				@wait for event from button press
	BL	WaitForBlackBlue	@R0=WaitForBlackBlue()
	cmp	R0,#0				@exit program?
	beq	ExitProgr
	cmp	R0,#LEFT_BLACK_BUTTON	@Incoming?
	beq	HandleIncoming
HandleOutgoing:
	BL	OutCall			@R0=OutCall()
	cmp	R0,#1			@could be exit program
	beq	ExitProgr
	Bal	CallStart
HandleIncoming:
	BL	InCall			@R0=InCall()
	cmp	R0,#1			@exit program?
	beq	ExitProgr
	Bal	CallStart

ExitProgr:	
	mov	r3,#3
ClearLoop:			@clear all screen lines except 1,2
	mov	r0,r3				@R0=line to be cleared
	swi	SWI_CLEAR_LINE
	add	r3,r3,#1
	cmp	r3,#LASTLINE
	bne	ClearLoop
	mov	r0,#5				@print exit message			
	mov	r1,#5
	ldr	r2,=Bye
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string
	add r1,r1,#1
    ldr r2,=ThankYou
    swi SWI_DRAW_STRING
    ldr	r10,=FiveSeconds	@delay for 5 seconds 
	BL	Wait				
	BL	ClearAll			@then clear everything
	swi	SWI_EXIT			@and exit program
	
@ *** int WaitForBlueStartStop	()	
@   Inputs:  none
@   Results:  	R0=1 if Blue=15 for exit
@				R0=0 if Blue=14 to start
@   Description:
@ 		polls until a Blue button is pressed
WaitForBlueStartStop:
	STMFD	sp!,{lr}
CheckBlueStartStop:
	SWI	SWI_CheckBlue
	cmp	r0,#Blbut15		@exit program?
	beq	ReturnExit
	cmp	r0,#Blbut14		@start?
	beq	ReturnStart
	bal	CheckBlueStartStop
ReturnExit:
	mov	r0,#1
	bal	EndWaitForBlueStartStop
ReturnStart:
	mov	r0,#0
EndWaitForBlueStartStop:
	LDMFD	sp!,{pc}

@ *** void Init	()	
@   Inputs:  none
@   Results:  	R0=1 if Blue=15 for exit
@				R0=0 if Blue=14 to start
@   Description:
@ 		sets up initial configuration of peripherals
Init:
	STMFD	sp!,{r0-r2,lr}
	mov	r0,#3			@initialize LCS screen lines 1-2
	mov	r1,#1
	ldr	r2,=NameStr1
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string
	mov	r0,#3
	mov	r1,#2
	ldr	r2,=NameStr2
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string
	mov	r0, #NO_LED			@ both LED off	
	swi	SWI_SETLED	
	mov	r0,#10				@8-segment point only
	mov	r1,#1
	bl	Display8Segment
	mov	r0,#0
	LDMFD	sp!,{r0-r2,pc}
	
@ *** void ClearAll	()	
@   Inputs:  none
@   Outputs: none 	
@   Description:
@ 		clear all peripherals
ClearAll:
	STMFD	sp!,{r0-r1,lr}
	swi	SWI_CLEAR_DISPLAY	
	mov	r0, #NO_LED				
	swi	SWI_SETLED	
	mov	r0,#10				
	mov	r1,#0
	bl	Display8Segment
	LDMFD	sp!,{r0-r1,pc}

@ *** int WaitForBlackBlue()	
@   Inputs:  none
@   Results:  	R0=0 if Blue=15 for exit
@				R0=left or right Black button pattern
@   Description:
@ 		polls until a Black button is pressed
@		or Blue to exit
WaitForBlackBlue:
	STMFD	sp!,{lr}
	mov	r0,#5			@display waiting event message
	mov	r1,#5			@bonus: incorporate blinking?
	ldr	r2,=waiting_str
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string	
CheckMain1:
	mov	r0,#5			@display waiting event message
	mov	r1,#5			@bonus: incorporate blinking?
	ldr	r2,=waiting_str		
	SWI	SWI_CheckBlue
	cmp	r0,#Blbut15					@exit program?
	bne	NextBlack
	mov	r0,#0						@end program
	bal	EndWaitForBlackBlue
NextBlack:
	SWI	SWI_CheckBlack
	cmp	r0,#LEFT_BLACK_BUTTON		@incoming call?
	beq	EndWaitForBlackBlue
	cmp	r0,#RIGHT_BLACK_BUTTON		@outgoing call?
	beq	EndWaitForBlackBlue
	bal	CheckMain1					@if none, keep waiting
EndWaitForBlackBlue:
	LDMFD	sp!,{pc}	
	
@ *** int InCall()	
@   Inputs:  none
@   Results:  	R0=1 if Blue=15 for exit
@				R0=0 if call finished okay
@   Description:
@ 		handles incoming calls by:
@The Left Black Button is pressed and the event is detected.

InCall:
	STMFD	sp!,{lr}
    mov r1,#5
    bl ClearLine
	mov	r0,#5			@initialize LCS screen lines 1-2
	mov	r1,#8
	ldr	r2,=incoming_call_str
	swi	SWI_DRAW_STRING	@R0:col#;R1:row#;R2:&string
	mov	r0,#0 			@The 8-segment displays “0”.
	bl	Display8Segment
	mov	r0, #BOTH_LED	@ both LED on	
	swi	SWI_SETLED		@• Both LED lights are turned on.
	mov r0,#5
    mov r1,#9
    ldr r2,=waiting_for_answer
    swi SWI_DRAW_STRING
    bl PollFor5DQ	@• The “DIAL” blue button “0” on the keyboard is checked for a maximum of 5 seconds. In this 5 second period:

	@* the 8-segment displays the count of the seconds from 5 to 1, one number per second; * both LED lights stay on.
	cmp r4,#0			@• If no signal (blue=0) is received for an answer, 
	beq EndInCall			@then the program returns to the Idle State at the end of the 5 seconds.
							
	cmp r4,#Blbut15		@• If the blue button = 15 is pressed, 
	moveq r0,#1
	beq EndInCall			@the program returns to the Idle State with a flag to exit. 
						@• If the “DIAL” blue button “0” is pushed within the 5 seconds, then:
    bl ClearLine
	mov r0,#5
	ldr r2,=incoming_call_accept@* a message is displayed stating the acceptance of the incoming call;
	swi SWI_DRAW_STRING
	bl TimeAndPoll					@* a timer starts in order to enable the computation of charges;
	cmp r4,#Blbut15
	moveq r0,#1
	beq EndInCall

	mov r0,#BOTH_LED	@* both LED lights stop blinking and are on together;
	swi SWI_SETLED		
	mov r0,#0 @* the 8-segment displays “0”;
	mov r1,#0 
	bl Display8Segment
	mov r1,#8
	mov r9,#1			@* the cost is computed at a rate of $1 per second, and a message is 
	@displayed with the total amount;
	mul r6,r5,r9		@r6 = total cost
	mov r0,r1
	swi SWI_CLEAR_LINE
	mov r0,#5
	ldr r2,=incoming_str
	swi SWI_DRAW_STRING
	add r0,r0,#20
	mov r2,r6
	swi SWI_DRAW_INT

	@* the system returns to the Idle State after a delay of 5 seconds (i.e. no events possible in this period).
	ldr r10,=FiveSeconds
	bl Wait
EndInCall:
	bl ClearLineForIdle
	LDMFD	sp!,{pc}

@ *** int OutCall()	
@   Inputs:  none
@   Results:  	R0=1 if Blue=15 for exit
@				R0=0 if call finished okay
@   Description:
@ 		handles outgoing calls by:
OutCall:
	STMFD	sp!,{lr}
    mov r1,#5 @clear the waiting message
    bl ClearLine
	mov	r0,#5			@initialize LCS screen lines 1-2
	mov	r1,#8
	ldr	r2,=outgoing_call_str
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string
	mov r0,#BOTH_LED		@both LED on
	swi SWI_SETLED
    mov r0,#5 @set back to col#
	mov r3,#4 @num of times to poll for numbers
	mov r9,#2 @Cost of call. Defaults to 2 (local). Change to 3 (LD)


    bl ClearLine @clear the line
    ldr r2,=waiting_local_or_longd
    swi SWI_DRAW_STRING


    bl PollFor5LD
    sub r3,r3,#1
    cmp r4,#Blbut15
    moveq r0,#1
    beq EndOutCall
    cmp r4,#0 @nothing was pressed
    beq EndOutCall

    cmp r4,#Blbut1 @long distance was pressed
    bne OutCallLocal @not 0,15,or 1. Local Call.

    mov r9,#3 @increase cost
    add r3,r3,#1 @poll one more time.
    mov r0,r1
    swi SWI_CLEAR_LINE @clear the lc/ld message
    bal OutCallPollStart


OutCallLocal:
    mov r0,r1
    swi SWI_CLEAR_LINE @clear the lc/ld message
    mov r0,#5
    mov r1,#5
    ldr r2,=Dialnum
    swi SWI_DRAW_STRING
    add r7,r0,#9
    mov r8,r1

@accepted dials
    cmp r4,#Blbut6
    moveq r0,#6
    cmp r4,#Blbut7
    moveq r0,#7
    cmp r4,#Blbut8
    moveq r0,#8
    cmp r4,#Blbut9
    moveq r0,#9
    mov r1,#0
    bl Display8Segment
    mov r2,r0
    mov r0,r7
    mov r1,r8
    swi SWI_DRAW_INT
    mov r4,#0 @clear r4
    add r7,r7,#2 @offset for next dial
    cmp r3,#0
    bne OutCallPoll


OutCallPollStart:
    mov r0,#5
    mov r1,#5
    ldr r2,=Dialnum
    swi SWI_DRAW_STRING
    add r7,r0,#9
    mov r8,r1
OutCallPoll:   
    bl PollFor5LC
    sub r3,r3,#1
    cmp r4,#Blbut15
    moveq r0,#1
    beq EndOutCall
    cmp r4,#0 @nothing was pressed
    beq EndOutCall
@accepted dials
    cmp r4,#Blbut6
    moveq r0,#6
    cmp r4,#Blbut7
    moveq r0,#7
    cmp r4,#Blbut8
    moveq r0,#8
    cmp r4,#Blbut9
    moveq r0,#9
    mov r1,#0
    bl Display8Segment
    mov r2,r0
    mov r0,r7
    mov r1,r8
    swi SWI_DRAW_INT
    mov r4,#0 @clear r4
    add r7,r7,#2 @offset for next dial
    cmp r3,#0
    bne OutCallPoll

@Finished Dialing. Do we call?
    bl PollFor5DQ
    cmp r4,#0 @no input
    beq EndOutCall
    cmp r4,#Blbut15
    moveq r0,#1
    beq EndOutCall
    @actually call.
    bl TimeAndPoll
        cmp r4,#Blbut15
        moveq r0,#1
        beq EndOutCall
    @calculate costs
    mul r6,r5,r9
    mov r0,#5
    mov r1,#8
    bl ClearLine
    cmp r9,#2 @is call local?
    ldreq r2,=local_call_cost
    ldrne r2,=longd_call_cost
    swi SWI_DRAW_STRING
    add r1,r1,#1
    mov r2,r6 @move into r2 to display
    swi SWI_DRAW_INT
    ldr r10,=FiveSeconds
    bl Wait

EndOutCall:
    mov r4,#0
	mov r1,#8
    bl ClearLineForIdle
	LDMFD	sp!,{pc}

@ *** void Display8Segment (Number:R0; Point:R1) ***
@   Inputs:  R0=number to display; R1=point or no point
@   Results:  none
@   Description:
@ 		Displays the number 0-9 in R0 on the 8-segment
@ 		If R1 = 1, the point is also shown
@		If R0=10, diplsy is blank
Display8Segment:
	STMFD 	sp!,{r0-r2,lr}
	ldr 	r2,=Digits
	ldr 	r0,[r2,r0,lsl#2]
	tst 	r1,#0x01 @if r1=1,
	orrne 	r0,r0,#SEG_P 			@then show P
	swi 	SWI_SETSEG8
	LDMFD 	sp!,{r0-r2,pc}
		

@ *** int PollFor5DQ  ()  
@   Inputs:  none
@   Results:    R4 = Button Pressed
@   Description:
@       polls until a Blue button 0 or 15 is pressed
PollFor5DQ:
    stmfd sp!,{r0-r3,r7-r10,lr}
    mov r3,#5 @set our counter r3 to 5
    mov r1,#0 @clear the dot in the 8-seg
    mov r0,r3 @move into r0 for display
    bl Display8Segment

PollFor5DQPoll:   
    mov r10,#1000
    bl WaitForBlueDQ
    cmp r4,#0 @is there a dial?
    beq PollFor5DQUpdate
    cmp r4,#Blbut15 @is the dial 15?
    beq PollFor5DQDone
    @dial and not 15. end.
    bal PollFor5DQDone

PollFor5DQUpdate:
    add r2,r2,#1000 @r2 = new target time
    sub r3,r3,#1
    mov r0,r3
    mov r1,#0
    bl Display8Segment
    cmp r3,#0
    beq PollFor5DQDone
    bal PollFor5DQPoll
PollFor5DQDone:
    ldmfd sp!,{r0-r3,r7-r10,pc}

@ ==== void WaitForBlueDQ(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: R4 = Button pressed (Accepted buttons:0,15)
@   Description:
@      WaitForBlueDQ for r10 milliseconds using a 15-bit timer 
WaitForBlueDQ:
    stmfd   sp!, {r0-r2,r7-r10,lr}
    ldr     r7, =EmbestTimerMask
    swi     SWI_GetTicks        @get time T1
    and     r1,r0,r7            @T1 in 15 bits
WaitForBlueDQLoop:
    swi SWI_CheckBlue
    cmp r0,#Blbut0 @user dialed 0
    beq WaitForBlueDQButton
    cmp r0,#Blbut15 @user dialed 15
    beq WaitForBlueDQButton

    swi SWI_GetTicks            @get time T2
    and     r2,r0,r7            @T2 in 15 bits
    cmp     r2,r1               @ is T2>T1?
    bge     simpletimeWBlueDQ
    sub     r9,r7,r1            @ elapsed TIME= 32,676 - T1
    add     r9,r9,r2            @    + T2
    bal     CheckIntervalWBlueDQ
simpletimeWBlueDQ:
        sub     r9,r2,r1        @ elapsed TIME = T2-T1
CheckIntervalWBlueDQ:
    cmp     r9,r10              @is TIME < desired interval?
    blt     WaitForBlueDQLoop
    bal     WaitForBlueDQDone
WaitForBlueDQButton:
    mov r4,r0
WaitForBlueDQDone:
    ldmfd   sp!, {r0-r2,r7-r10,pc} 

@ *** int PollFor5DQ  ()  
@   Inputs:  none
@   Results:    R4 = Button Pressed
@               R5 = Total Elapsed Time in Seconds
@   Description:
@       polls with message until Blue 0 or 15 is pressed
@       then calculates the elapsed time
TimeAndPoll:
    stmfd sp!,{r0-r3,r7-r10,lr}
    mov r0,#5
    mov r1,#9
    ldr r2,=waiting_for_hangup
    swi SWI_DRAW_STRING
    mov r1,#10      @vanity text. Please Disregard
    ldr r2,=Pattern1
    swi SWI_DRAW_STRING
    mov r1,#11      @vanity text. Please Disregard
    ldr r2,=Pattern2
    swi SWI_DRAW_STRING
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
    bl WaitFor1or15
    mov r0,#NO_LED
    swi SWI_SETLED
    bl WaitFor1or15
    mov r0,#BOTH_LED
    swi SWI_SETLED
    
    mov r8,#1
    bal TimeAndPollPoll 
TimeAndPollState1: @r8 = 1
    mov r10,#100
    mov r0,#NO_LED
    swi SWI_SETLED
    bl WaitFor1or15
    mov r0,#BOTH_LED
    swi SWI_SETLED
    bl WaitFor1or15
    mov r0,#NO_LED
    swi SWI_SETLED

    mov r8,#0
    bal TimeAndPollPoll
TimeAndPollDone:
    cmp r4,#Blbut15     @Do we exit?
    beq TimeAndPollExit @Exit without showing cost.

    @calculate time passed in seconds
    mov r8,#10
    mov r7,r5
    mul r5,r7,r8
    add r5,r3,r5 @r5 is now aggregated time

TimeAndPollExit:
	mov r0,#10
	mov r1,#0
	bl Display8Segment
    mov r1,#9
    bl ClearLineForIdle
    ldmfd sp!,{r0-r3,r7-r10,pc} 

@ *** int PollFor5LC  ()  
@   Inputs:  none
@   Results:    R4 = Button Pressed
@   Description:
@       polls until a Blue button 6,7,8,9,or 15 is pressed
PollFor5LC:
    stmfd sp!,{r0-r3,r7-r10,lr}
    mov r3,#5 @set our counter r3 to 5
    mov r1,#0 @clear the dot in the 8-seg
    mov r0,r3 @move to r0 for displaying
    bl Display8Segment

PollFor5LCPoll:   
    mov r10,#1000
    bl WaitForBlueLC
    cmp r4,#0 @is there a dial?
    beq PollFor5LCUpdate @no dial: go do update
    bal PollFor5LCDone    @dialed and not 15. end.
PollFor5LCUpdate:
    add r2,r2,#1000 @r2 = new target time
    sub r3,r3,#1
    mov r0,r3
    mov r1,#0
    bl Display8Segment 
    cmp r3,#0
    beq PollFor5LCDone
    bal PollFor5LCPoll
PollFor5LCDone:
    mov r0,#10
    mov r1,#0
    bl Display8Segment
    ldmfd sp!,{r0-r3,r7-r10,pc}

@ ==== void WaitForBlueLC(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: R4 = Button pressed (Accepted buttons:1,6,7,8,9,15)
@   Description:
@      WaitForBlueLC for r10 milliseconds using a 15-bit timer 
WaitForBlueLC:
    stmfd   sp!, {r0-r2,r7-r10,lr}
    ldr     r7, =EmbestTimerMask
    swi     SWI_GetTicks        @get time T1
    and     r1,r0,r7            @T1 in 15 bits
WaitForBlueLCLoop:
    swi SWI_CheckBlue

    cmp r0,#Blbut6 @user dialed 6 
    beq WaitForBlueLCButton
    cmp r0,#Blbut7 @user dialed 7 
    beq WaitForBlueLCButton
    cmp r0,#Blbut8 @user dialed 8
    beq WaitForBlueLCButton
    cmp r0,#Blbut9 @user dialed 9 
    beq WaitForBlueLCButton
    cmp r0,#Blbut15 @user dialed 15
    beq WaitForBlueLCButton

    swi SWI_GetTicks            @get time T2
    and     r2,r0,r7            @T2 in 15 bits
    cmp     r2,r1               @ is T2>T1?
    bge     simpletimeWBlueLC
    sub     r9,r7,r1            @ elapsed TIME= 32,676 - T1
    add     r9,r9,r2            @    + T2
    bal     CheckIntervalWBlueLC
simpletimeWBlueLC:
        sub     r9,r2,r1        @ elapsed TIME = T2-T1
CheckIntervalWBlueLC:
    cmp     r9,r10              @is TIME < desired interval?
    blt     WaitForBlueLCLoop
    mov r4,#0
    bal     WaitForBlueLCDone
WaitForBlueLCButton:
    mov r4,r0
WaitForBlueLCDone:
    ldmfd   sp!, {r0-r2,r7-r10,pc}   
 

@ *** int PollFor5LD  ()  
@   Inputs:  none
@   Results:    R4 = Button Pressed
@   Description:
@       polls until a Blue button 1,6,7,8,9,or 15 is pressed
PollFor5LD:
    stmfd sp!,{r0-r3,r7-r10,lr}
    mov r3,#5 @set our counter r3 to 5
    mov r1,#0 @clear the dot in the 8-seg
    mov r0,r3 @move to r0 for displaying
    bl Display8Segment

PollFor5LDPoll:   
    mov r10,#1000
    bl WaitForBlueLD
    cmp r4,#0 @is there a dial?
    beq PollFor5LDUpdate @no dial: go do update
    bal PollFor5LDDone    @dialed and not 15. end.
PollFor5LDUpdate:
    add r2,r2,#1000 @r2 = new target time
    sub r3,r3,#1
    mov r0,r3
    mov r1,#0
    bl Display8Segment
    
    cmp r3,#0
    beq PollFor5LDDone

    bal PollFor5LDPoll
PollFor5LDDone:
    mov r0,#10
    mov r1,#0
    bl Display8Segment
    ldmfd sp!,{r0-r3,r7-r10,pc}

@ ==== void WaitForBlueLD(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: R4 = Button pressed (Accepted buttons:1,6,7,8,9,15)
@   Description:
@      WaitForBlueLD for r10 milliseconds using a 15-bit timer 
WaitForBlueLD:
    stmfd   sp!, {r0-r2,r7-r10,lr}
    ldr     r7, =EmbestTimerMask
    swi     SWI_GetTicks        @get time T1
    and     r1,r0,r7            @T1 in 15 bits
WaitForBlueLDLoop:
    swi SWI_CheckBlue
    cmp r0,#Blbut1 @user dialed 1
    beq WaitForBlueLDButton
    cmp r0,#Blbut6 @user dialed 6 
    beq WaitForBlueLDButton
    cmp r0,#Blbut7 @user dialed 7 
    beq WaitForBlueLDButton
    cmp r0,#Blbut8 @user dialed 8
    beq WaitForBlueLDButton
    cmp r0,#Blbut9 @user dialed 9 
    beq WaitForBlueLDButton
    cmp r0,#Blbut15 @user dialed 15
    beq WaitForBlueLDButton

    swi SWI_GetTicks            @get time T2
    and     r2,r0,r7            @T2 in 15 bits
    cmp     r2,r1               @ is T2>T1?
    bge     simpletimeWBlueLD
    sub     r9,r7,r1            @ elapsed TIME= 32,676 - T1
    add     r9,r9,r2            @    + T2
    bal     CheckIntervalWBlueLD
simpletimeWBlueLD:
        sub     r9,r2,r1        @ elapsed TIME = T2-T1
CheckIntervalWBlueLD:
    cmp     r9,r10              @is TIME < desired interval?
    blt     WaitForBlueLDLoop
    bal     WaitForBlueLDDone
WaitForBlueLDButton:
    mov r4,r0
WaitForBlueLDDone:
    ldmfd   sp!, {r0-r2,r7-r10,pc}   

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

@ *** Void ClearLine  ()  
@   Inputs:  R1 = Line to be cleared
@   Results:    none
@   Description:
@       Clears line R1, the 8-Segment, and sets both LEDs to Off.
ClearLine:
	stmfd sp!,{r0,r1,lr}
	mov r0,r1
	swi SWI_CLEAR_LINE
	mov r0,#10
	bl Display8Segment
	mov r0,#NO_LED
	swi SWI_SETLED
	ldmfd sp!,{r0,r1,pc}


@ *** Void ClearLineForIdle  ()  
@   Inputs:  R1 = Line to be cleared
@   Results:    none
@   Description:
@       Clears line R1, the 8-Segment, and sets both LEDs to Off,
@       Also Clears lines 9 through 11 and sets "waiting for event" message.
ClearLineForIdle:
    stmfd sp!,{r0-r2,lr}
    mov r0,r1
    swi SWI_CLEAR_LINE
    mov r0,#9
    swi SWI_CLEAR_LINE
    mov r0,#10
    swi SWI_CLEAR_LINE
    mov r0,#11
    swi SWI_CLEAR_LINE
    mov r0,#5
    mov r1,#5
    ldr r2,=waiting_str
    swi SWI_DRAW_STRING
    mov r0,#10
    bl Display8Segment
    mov r0,#NO_LED
    swi SWI_SETLED
    ldmfd sp!,{r0-r2,pc}  

@ ==== void Wait(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: none
@   Description:
@      Wait for r10 milliseconds using a 15-bit timer 
Wait:
	stmfd	sp!, {r0-r2,r7-r10,lr}
	ldr     r7, =EmbestTimerMask
	swi     SWI_GetTicks		@get time T1
	and		r1,r0,r7			@T1 in 15 bits
WaitLoop:
	swi SWI_GetTicks			@get time T2
	and		r2,r0,r7			@T2 in 15 bits
	cmp		r2,r1				@ is T2>T1?
	bge		simpletimeW
	sub		r9,r7,r1			@ elapsed TIME= 32,676 - T1
	add		r9,r9,r2			@    + T2
	bal		CheckIntervalW
simpletimeW:
		sub		r9,r2,r1		@ elapsed TIME = T2-T1
CheckIntervalW:
	cmp		r9,r10				@is TIME < desired interval?
	blt		WaitLoop
WaitDone:
	ldmfd	sp!, {r0-r2,r7-r10,pc}	


	.data
	.align
Digits:							@ for 8-segment display
	.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G 	@0
	.word SEG_B|SEG_C 							@1
	.word SEG_A|SEG_B|SEG_F|SEG_E|SEG_D 		@2
	.word SEG_A|SEG_B|SEG_F|SEG_C|SEG_D 		@3
	.word SEG_G|SEG_F|SEG_B|SEG_C 				@4
	.word SEG_A|SEG_G|SEG_F|SEG_C|SEG_D 		@5
	.word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C 	@6
	.word SEG_A|SEG_B|SEG_C 					@7
	.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
	.word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C 		@9
	.word 0 									@Blank 
	.align
@ FEEL FREE TO CHANGE, ADD, DELETE TO THE MESSAGES
NameStr1:				.asciz	"Bill Xiong V00737042\n"
NameStr2:				.asciz	"Summer 2012 - CSC 230\n"
Bye:					.asciz	"Program terminating...Ciao"
waiting_str:			.asciz	"Waiting for Event\n"
incoming_call_str:		.asciz	"Got an incoming call ...\n"
incoming_call_accept:	.asciz	"Picking up call ...\n"
outgoing_call_str:		.asciz	"Got an outgoing call ...\n"
outgoing_call_accept:	.asciz	"Calling ...\n"
waiting_local_or_longd:	.asciz	"Waiting for local or longd button...\n"
local_call_str:			.asciz	"Got an outgoing local call...\n"
longd_call_str:			.asciz	"Got an outgoing long distance call...\n"
waiting_for_answer:		.asciz	"waiting for Answer button press\n"
waiting_for_hangup:		.asciz	"waiting for Hangup button press\n"
incoming_str:			.asciz	"Incoming call cost:"
local_call_cost:		.asciz	"Outgoing Local call cost:"
longd_call_cost:		.asciz	"Outgoing Long Distance call cost:"
ThankYou:               .asciz  "Thank You For Using XiongTel.\n"
Dialnum:				.asciz  "Dialed #"
Pattern1:               .asciz  "Please enjoy the LED flashing"
Pattern2:               .asciz  "in pretty patterns during your call"
	.end