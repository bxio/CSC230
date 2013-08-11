@ =============== Bill Xiong V00737042
@ *************** Assignment 2  ***************
@ This program reads 2 dimensional matrices until end of
@ file, prints them, prints their diagonal, computes their
@ transpose and checks if they are symmetric or skew symmetric

@ Version 0 - Template given
@ Open input file
@ Read row size R
@ While Not end of file:
@	Read column size C
@	Call RdMat: Read R x C integer into a 2D matrix
@	Call PrMat: print matrix
@	TO BE DONE IN ASSIGNMENT:
@		diagonal,transpose, check symmetric, check skew symmetric
@	Read row size R
@ Close input file

	.equ	SWI_Exit,   0x11	@terminate program
	.equ	SWI_Open,   0x66	@open a file
	.equ	SWI_Close,	0x68	@close a file
	.equ	SWI_PrStr,  0x69	@print a string
	.equ	SWI_PrInt,	0x6b	@print integer
	.equ	SWI_RdInt,	0x6c	@read an integer from file
	.equ	Stdout,		1		@output mode for Stdout
	.equ	FileInputMode,  0
	.equ	MAXSIZE,	10		@max dimension for matrix

		.global _start
		.text
_start:
@ ====  open the input file
	ldr	r0,=InputFileName	@ set to open input file
	mov	r1,#0				@ R1 = mode = input
	swi	SWI_Open
	bcs	InFileError			@ if problem, exit
	ldr	r1,=InFileHandle	@ else save the file handle
	str	r0,[r1]

@ ==== print initial messages to screen
	ldr	r1,=Welcome1		@ R1 = address of string
	mov	r0,#Stdout			@ to screen
	swi	SWI_PrStr
	ldr	r1,=Welcome2		@ R1 = address of string
	mov	r0,#Stdout			@ to screen
	swi	SWI_PrStr

@ ==== read row size from input file
	ldr	r0,=InFileHandle	@ load the input file handle
	BL	ReadInt				@ R0= ReadInt(R0:InputFileHandle)
	bcs	Closure				@ if c bit is set, EOF reached
	mov	r10,#0				@ R10=current matrix number
IOLoop:
	mov	r9,r0				@ R9 = row size read in
	add	r10,r10,#1			@ increase current matrix number
	ldr	r0,=InFileHandle	@ read column size
	BL	ReadInt				@ R0= ReadInt(R0:InputFileHandle)
	mov	r8,r0				@ R8 = column size read in
@ === read elements of matrix into MatMain
	ldr	r0,=InFileHandle	@ load the input file handle
	ldr	r1,=MatMain			@ R1 = address of Matrix
	mov	r2,r9				@ R2 = row size
	mov	r3,r8				@ R3 = column size
	BL	RdMat				@ void RdMat(R0:InputFile;R1:addr matrix;
							@ R2:row size;R3:col size)
@ === print matrix label and sizes
	ldr	r1,=Matlabel
	mov	r0,#Stdout
	swi	SWI_PrStr
	mov	r1,r10				@ R1 = current matrix number
	mov	r0,#Stdout
	swi	SWI_PrInt
	ldr	r1,=Sizemsg			@ print sizes
	mov	r0,#Stdout
	swi	SWI_PrStr
	mov	r1,r2				@ r1 = row size
	mov	r0,#Stdout
	swi	SWI_PrInt
	ldr	r1,=BLANKS2			@ blanks
	mov	r0,#Stdout
	swi	SWI_PrStr
	mov	r1,r3				@ r1 = column size
	mov	r0,#Stdout
	swi	SWI_PrInt
	ldr	r1,=NL				@ new line
	mov	r0,#Stdout
	swi	SWI_PrStr
@ === print the matrix
	ldr	r0,=MatMain			@ R0 = address of Matrix
	mov	r1,r9				@ R1 = row size
	mov	r2,r8				@ R2 = column size
	ldr r3,=RsizeM			@load address of RsizeM into R3
	str r1,[r3]				@ storing row size of matrix
	ldr r3, =CsizeM			@load address of CsizeM into R3
	str r2,[r3]				@ store col size of matrix
	BL	PrMat				@ void PrMat(R0:addr matrix;R1:row size;R2:col size)

@ === NEW ASSIGNMENT CODE HERE
	@ 1. Print the diagonal
	@ 2. Compute the transpose and store it in MatTransp
	@ 3. Print the transpose
	@ 4. If matrix is square,check if symmetric and print message
	@ 5. If matrix is square,check if skew -symmetric and print message


	ldr r1,=DiagMessage
	mov r0,#Stdout
	swi SWI_PrStr
@ ==== (1) Print diagonal from given matrix
	@r1 = address of MatMain
	@r2 = Row size of MatMain
	@r3 = Column size of MatMain
	@r4 = item counter
	@r5 = pointer to element to print
	@r6-r9 = temp variables.
	ldr r1,=MatMain @load address of MatMain into R1
	ldr r2,=RsizeM @load row into r2
	ldr r2,[r2]
	ldr r3,=CsizeM @load col into r3
	ldr r3,[r3]
	CMP r2,r3
	movgt r2,r3 @if r2>r3, set new min r2 = r3
	mov r4,#0 @the times count.
	ldr r5,=MatMain @ r5 = address of first element of matrix
	mov r6,#0 @the counter for spaces. Make sure to reset this every round.
diagLoop:
	CMP r4,r2	@compare r4 to r2 and branch into diagPrint if smaller than.
	BGE endDiag

diagPrint:
	CMP r6,r4	@print out space r4 times
		ldrlt r1,=BLANKS2 @Load address of space into r1
		movlt r0,#Stdout	@load mode into r0
		swilt SWI_PrStr	@print the space
		add r6,r6,#1
		BLT diagPrint
		@finished printing spaces.
	ldr r1,[r5] @print out number in matrix
	mov r0,#Stdout
	swi SWI_PrInt

	ldr r1,=NL @print newline character
	mov r0,#Stdout
	swi SWI_PrStr
	mov r8,#4
	add r9,r3,#1
	mul r7,r9,r8 @fixme
	add r5,r5,r7 @increase the address of current element
	add r4,r4,#1 @increase counter r4
	mov r6,#0 @reset counter for spaces (r6)
	BAL diagLoop @branch back to loop
endDiag:@move onto new code.
	ldr r1,=BLANKS2
	mov r0,#Stdout
	swi SWI_PrStr
	ldr r1,=Transplabel
	mov r0,#Stdout
	swi SWI_PrStr

@ ==== (2) Compute the transpose and store it in MatTransp
	@r1 = RsizeM = CsizeTR
	@r2 = CsizeM = RsizeTR
	@r3 = Address of MatMain, row anchor - acts as counter for rows
	@r4 = Address of MatMain, points to element to store in MatTransp.
	@r5 = Address of MatTransp
	@r6 = Column counter - check against r2
	@r7 = Row counter - check against r1
	
	@Grab and swap the row size and col size.
	ldr r1,=RsizeM
	ldr r1,[r1]
	ldr r2,=CsizeM
	ldr r2,[r2]
	@store the addresses into memory
	ldr r3,=CsizeTr
	str r1,[r3]
	ldr r3,=RsizeTr
	str r2,[r3]

	@Load our pointers
	ldr r3,=MatMain
	ldr r4,=MatMain
	ldr r5,=MatTransp
	@initialize our counters
	mov r6,#0 @ (i)
	mov r7,#0 @ (j)

TrLoop:
	cmp r7,r2 @while j < #cols
	bge TrEnd
TrMid1:
	cmp r6,r1 @while i<#rows
	bge TrMid2
	ldr r8,[r4] @load content at r4 into r8
	str r8,[r5] @store this in [r5]
	add r5,r5,#4
	mov r8,#4 @set r8 = 4 in prep for mul
	mul r9,r2,r8 @set r9 = r1*r8
	add r4,r4,r9 @r4 = r4 + r9
	add r6,r6,#1 @increment r6
	bal TrMid1
TrMid2:
	add r3,r3,#4 @r3 = r3 + 4
	mov r4,r3 @Set r4 = r3
	add r7,r7,#1 @increment r7
	mov r6,#0 @reset r6
	bal TrLoop
TrEnd: @go on to next section
@ ==== (3) Print the transpose [repeat of print Matrix]
	ldr	r0,=MatTransp		@ R0 = address of Matrix
	ldr r9,=RsizeTr 		@Set r9 = #rows Tr
	ldr r9,[r9]
	mov	r1,r9				@ R1 = row size
	ldr r8,=CsizeTr 		@set r8 - #cols Tr
	ldr r8,[r8]
	mov	r2,r8				@ R2 = column size
	BL	PrMat				@ void PrMat(R0:addr matrix;R1:row size;R2:col size)

@ ===  (4) If matrix is square,check if symmetric and print message

SquareTests:
	ldr r1,=RsizeM
	ldr r2,=CsizeM
	ldr r1,[r1]
	ldr r2,[r2]
	cmp r1,r2
	bne SquareNo
	bal SymmTest

SquareNo:
	ldr r1,=NotSquare
	mov r0,#Stdout
	swi SWI_PrStr
	bal MoveToNextSegment
@ ===  (4) If matrix is square,check if symmetric and print message
	@r0: pointer to MatMain
	@r1: pointer to MatTransp
	@r2: counter
	@r3: number of times to iterate through the loop
	
SymmTest:
@init:
	ldr r0,=MatMain @set r0 as pointer to MatMain
	ldr r1,=MatTransp @set r1 as pointer to MatTransp
	mov r2,#0 @set r2 as counter, r2 = 0
	ldr r4,=RsizeTr 
	ldr r4,[r4]
	ldr r5,=CsizeTr
	ldr r5,[r5]
	mul r3,r4,r5 @set r3 as the number of iterations, (RsizeTr * CsizeTr)
	mov r4,#1 @set r4 as our flag, 0 as default. 0 = not symmetrical 1 = symmetrical
	
SymmLoop:
	cmp r2,r3	@Loop as long as r2<r3
	bge SymmTestEnd
	ldr r5,[r0] @load elements at r0 and r1
	ldr r6,[r1]
	cmp r5,r6 @compare them
	bne notSymm
	@if equal, move on.
	add r2,r2,#1 @increment necessary pointers
	add r0,r0,#4
	add r1,r1,#4
	bal SymmLoop

SymmTestEnd:
	ldr r1,=Symm
	mov r0,#Stdout
	swi SWI_PrStr
	bal SkSymmTest

notSymm:
ldr r1,=SymmNo
mov r0,#Stdout
swi SWI_PrStr
bal SkSymmTest

@ === (5) If matrix is square,check if skew -symmetric and print message
SkSymmTest:
@init:
	ldr r0,=MatMain @set r0 as pointer to MatMain
	ldr r1,=MatTransp @set r1 as pointer to MatTransp
	mov r2,#1 @set r2 as counter, r2 = 1
	ldr r4,=RsizeTr 
	ldr r4,[r4]
	ldr r5,=CsizeTr
	ldr r5,[r5]
	mul r3,r4,r5 @set r3 as the number of iterations, (RsizeTr * CsizeTr)
	mov r4,#1 @set r4 as our flag, 0 as default. 0 = not symmetrical 1 = symmetrical
	mov r6,#1 @set r6 = next diagonal root
	mul r5,r6,r6 @r5 = next square number (diagonal)
	
SkSymmLoop:
	cmp r2,r3	@Loop as long as r2<r3
	bgt SkSymmTestEnd
	cmp r2,r5 @is this element a diagonal?
	beq SkSymmDiag @if it is, branch to SkSymmDiag
	ldr r7,[r0] @load elements at r0 and r1
	ldr r8,[r1]
	rsb r8,r8,#0 @set r6 = 0-r6
	cmp r7,r8 @compare them
	bne notSkSymm
SkSymmLoopMid:
	@if equal, move on.
	@increment necessary pointers
	add r2,r2,#1
	add r1,r1,#4
	add r0,r0,#4
	bal SkSymmLoop
	
SkSymmDiag:
	add r6,r6,#1 @increase diagonal counter
	mul r5,r6,r6 @set next diagoanl number
	bal SkSymmLoopMid
	

SkSymmTestEnd: @move on with next matrix
	ldr r1,=SkSymm
	mov r0,#Stdout
	swi SWI_PrStr
	bal MoveToNextSegment
	
notSkSymm:
ldr r1,=SkSymmNo
mov r0,#Stdout
swi SWI_PrStr



MoveToNextSegment:
@going on to next segment......
@ === read next matrix row size and check for end of file
	ldr	r0,=InFileHandle	@ load the input file handle
	BL	ReadInt				@ R0= ReadInt(R0:InputFileHandle)
	bcs	Closure				@ if c bit is set, EOF  reached
	bal	IOLoop				@ else keep looping



@ === Errors Handling
InFileError:
	mov	r0,#Stdout				@ error for input file
	ldr	r1,=InFileErrorMessage	@ to Stdout
	swi	SWI_PrStr
	bal	Closure					@ exit

@ === Exit segment
Closure:
	ldr	r1,=Bye				@ final message
	mov	r0,#Stdout			@ to screen
	swi	SWI_PrStr
	ldr	r0,=InFileHandle
	ldr	r0,[r0]
	swi	SWI_Close			@ close the input file
	swi	SWI_Exit

@ ========== OTHER FUNCTIONS ============

@ === Reading an integer from a file
	@ R0 ReadInt( R0:InputFileHandle)
	@ Input parameters:R0 - pointer to input file
	@ Output parameters: R0 - integer read
	@ Side effects: If EOF then C bit is set in CPSR
ReadInt:
	STMFD	sp!,{lr}
	ldr	r0,[r0]			@ load input file handle
	swi	SWI_RdInt		@ to read from
	LDMFD	sp!,{pc}

@ === Reading a 2D matrix given its sizes
	@ void RdMat(Mat:r1;Row:r2;Col:r3)
	@ Input parameters:
	@ 	R0 - pointer to input file
	@ 	R1 - matrix address
	@ 	R2 - row size; R3 - column size
	@ Output parameters: None
	@ Side effects: Mat is filled with elements
RdMat:
	STMFD	sp!,{r0-r3,r8-r10,lr}
	mov	r8,r1			@ R8 is pointer to matrix
	mul	r9,r2,r3		@ R9 = total number of elements
	mov r10,r0			@ R10 = pointer to input file
RdAll:
	ldr		r0,[r10]		@ load input file handle
	swi		SWI_RdInt		@ get matrix element
	str		r0,[r8],#4		@ store it in matrix
	subs	r9,r9,#1		@ count number of elements
	bne		RdAll
DoneRdMat:
	LDMFD	sp!,{r0-r3,r8-r10,pc}

@ === Printing a 2D matrix to screen
	@ void PrMat(Mat:r0;Row:r1;Col:r2)
	@ Input parameters:
	@ 	R0 - matrix address
	@ 	R1 - row size; R2 - column size
	@ Output parameters: None
PrMat:
	STMFD	sp!,{r0-r2,r7-r9,lr}
	mov	r8,r0			@ R8 is pointer to matrix
	mov	r9,r2			@ R9 = column size
	mov	r7,r1			@ R7 = row size
PrRow:
	ldr		r1,[r8],#4			@ R1 = Mat[i++]
	mov		r0,#Stdout			@ print to screen
	swi		SWI_PrInt
	ldr		r1,=BLANKS2
	mov		r0,#Stdout
	swi		SWI_PrStr
	subs	r9,r9,#1			@end of row?
	bne		PrRow
	ldr		r1,=NL				@new line
	mov		r0,#Stdout
	swi		SWI_PrStr
	subs	r7,r7,#1			@end of all rows?
	beq		DonePrMat
	mov		r9,r2				@reset column count
	bal		PrRow
DonePrMat:
	LDMFD	sp!,{r0-r2,r7-r9,pc}


@ *************** Data Segment ***************
	.data
	.align
@ declare integer variables
InFileHandle:			.word	0
MatMain:				.skip	4*MAXSIZE*MAXSIZE
MatTransp:				.skip	4*MAXSIZE*MAXSIZE
RsizeM:					.skip	4
CsizeM:					.skip	4
RsizeTr:				.skip	4
CsizeTr:				.skip	4
CurrMat:				.word	0
@ declare strings and characters
NL:						.asciz	"\n"	@ new line
BLANKS2:				.asciz	"  "	@blanks
Welcome1:				.asciz	"\nAssignment 2 on matrices \n"
Welcome2:				.asciz	"\nBill Xiong, V00737042\n"
Bye:					.asciz	"\nAll done - Bye\n"
InputFileName:			.asciz	"INA2.txt"
InFileErrorMessage:		.asciz	"Unable to open input file\n"
Matlabel:				.asciz	"\n\n### MATRIX  "
Sizemsg:				.asciz	"  of size: "
Transplabel:			.asciz	"\n\nIts Transpose ###\n"
NotSquare:				.asciz	"\nMatrix is not square, no testing done\n\n"
Symm:					.asciz	"\nMatrix is symmetric\n\n"
SkSymm:					.asciz	"\nMatrix is skew symmetric\n\n"
SymmNo:					.asciz	"\nMatrix is not symmetric\n\n"
SkSymmNo:				.asciz	"\nMatrix is not skew symmetric\n\n"
DiagMessage:			.asciz	"\nPrinting Diagonal:\n"
	.end

