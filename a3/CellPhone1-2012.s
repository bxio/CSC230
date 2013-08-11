@ *************** Initial Code ************
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
	.equ    Blbut14, 	0x4000	@ =14
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
InCall:
	STMFD	sp!,{lr}
	mov	r0,#5			@initialize LCS screen lines 1-2
	mov	r1,#8
	ldr	r2,=incoming_call_str
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string
	mov	r0,#0
EndInCall:
	LDMFD	sp!,{pc}
	
@ *** int OutCall()	
@   Inputs:  none
@   Results:  	R0=1 if Blue=15 for exit
@				R0=0 if call finished okay
@   Description:
@ 		handles outgoing calls by:
OutCall:
	STMFD	sp!,{lr}
	mov	r0,#5			@initialize LCS screen lines 1-2
	mov	r1,#8
	ldr	r2,=outgoing_call_str
	swi	SWI_DRAW_STRING		@R0:col#;R1:row#;R2:&string
	mov	r0,#0
EndOutCall:
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
NameStr1:			.asciz	"Jean Luc Picard V00123456\n"
NameStr2:			.asciz	"Summer 2012 - CSC 230\n"
Bye:				.asciz	"Program terminating...Ciao"
waiting_str:		.asciz	"Waiting for Event\n"
incoming_call_str:	.asciz	"Got an incoming call ...\n"
outgoing_call_str:	.asciz	"Got an outgoing call ...\n"
waiting_local_or_longd:	.asciz	"Waiting for local or longd button...\n"
local_call_str:		.asciz	"Got an outgoing local call...\n"
longd_call_str:		.asciz	"Got an outgoing long distance call...\n"
waiting_for_answer:	.asciz	"waiting for Answer button press\n"
waiting_for_hangup:	.asciz	"waiting for Hangup button press\n"
incoming_str:		.asciz	"Incoming call cost:"
local_call_cost:	.asciz	"Outgoing Local call cost:"
longd_call_cost:	.asciz	"Outgoing Long Distance call cost:"

	.end
