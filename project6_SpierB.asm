TITLE Project 6     (project6_SpierB.asm)

; Author: Brian Spier
; Last Modified: 3/15/22
; OSU email address: spierb@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6             Due Date: 3/13/22
; Description: This program prompts the user to enter 10 string
; of decimals which in turn fill an array. The strings are verified
; to contain only integers and are then converted into their decimal
; value. Once converted the avg and sum of the values is determined.
; Next the array of decimals is converted back into strings and the
; array of strings is displayed along with the sum and avg of the
; values.

INCLUDE Irvine32.inc

;MACROS
;-------------------------------------------------------------------
mDisplayString	MACRO	string
; this macro displays a string in place of call writestring 
; this macro takes in a string as the only parameter, moves the
; string to edx and calls WriteString 
;-------------------------------------------------------------------
  push	EDX
  mov	EDX, string
  call	WriteString
  pop	EDX
ENDM

;-------------------------------------------------------------------
mGetString		MACRO	prompt, tempStringLocation, lengthString
; this macro takes in the parameters prompt which is a string prompt
; tempstringlocation which is where the user string is stored and 
; lengthString which is where the length of the user string is 
; stored
; this macro take prompts the user to enter a string, stores the 
; string in tempStringLocation array and stores the length of 
; string in lengthString array 
;-------------------------------------------------------------------
  push	ECX
  push	EDX
  mDisplayString prompt
  mov	EDX, tempStringLocation	
  call	ReadString
  mov	lengthString, EAX
  pop	EDX
  pop	ECX
ENDM


arraySize = 10

.data
  userArray			DWORD	10 DUP (?) ; decimals that have been converted are stored in this array
  arrayLength		DWORD	? ; records the length of the array
  temp				BYTE	0 ; temp array to store strings user enterd
  tempInt			BYTE	0 ; used to temporarly store value in AL reg
  tempIntAl			BYTE	0 ; used to temporarly store value in AL reg
  sLen				DWORD	? ; records the length of the strings the user enters
  sum				SDWORD	0 ; variable to store sum of converted integers
  avg				SDWORD	0 ; variable to store the avg of the converted integers
  tempArray			BYTE	10 DUP (?)
  intro				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,0
  author			BYTE	"Written by: Brian Spier",13,10,0
  rules				BYTE	"Please provide 10 signed decimal iintegers.",13,10,0
  rules2			BYTE	"Each number needs to be small ebough to fit inside a 32 bit register. ",0
  rules3			BYTE	"After you have finished inputting the raw numbers I will display a",13,10,0
  rules4			BYTE	"list of the integers, their sum, and thier average value.",13,10,0
  userPrompt		BYTE	"Please enter an signed number: ",0
  userError			BYTE	"ERROR: you did not enter a signed number or your number was too big.",13,10,0
  userPrompt2		BYTE	"Please try again: ",0
  stringOutput		BYTE	"You entered the following numbers:",13,10,0
  arraySumPrompt	BYTE	"The sum of these number is: ",0
  arrayAvgPrompt	BYTE	"The truncated average is: ",0


.code
;-------------------------------------------------------------------
main PROC
;-------------------------------------------------------------------
; Intro
  mDisplayString	OFFSET	intro
  mDisplayString	OFFSET	author
  call	CrLf
  mDisplayString	OFFSET	rules
  mDisplayString	OFFSET	rules2 
  mDisplayString	OFFSET	rules3
  mDisplayString	OFFSET	rules4
  call	CrLf

; Get Value
  push	OFFSET tempIntAl;	[EBP + 48]
  push	OFFSET tempInt ;	[EBP + 44]
  push	OFFSET temp ;		[ebp + 40]
  push	OFFSET sLen ;		[ebp + 36]
  push	OFFSET userArray ;	[ebp + 32]
  push	OFFSET tempArray ;  [EBP + 28]
  push	sum	;				[EBP + 24]
  push	avg ;				[EBP + 20]
  push	OFFSET userPrompt ;	[EBP + 16]
  push	OFFSET userError ;	[EBP + 12]
  push	OFFSET userPrompt2;	[EBP + 8]
  mov	ECX, 10
  getNumber:
  ; get number loop that fills tempArray
  call	ReadVal
  loop	getNumber
  mov	ECX, arraySize

  displayArray:

  mov	ESI, userArray
  mov	EAX, [ESI]
  add	ESI, 4
	
main ENDP

;-------------------------------------------------------------------
ReadVal PROC
; prompts user to enter signed string values and adds them to an
; array. next the values in the array are varified and converted 
; into thier corresponding decimal values.
; reg used: EBP, ESP, ECX, ESI, EAX, EBX, AL, BL
; 
;-------------------------------------------------------------------
getNumber:
; calls mGetString to get string to put into an array
; array is temp

  push	EBP
  mov	EBP, ESP
  push	ECX

mGetString [EBP + 16], [EBP + 28], [EBP + 36]
 
 convertNumbers:
 ; places the sLen into ECX for looping
 ; places the temp array with strings into ESI
  CLD
  mov	ECX, [EBP + 36] ; sLen
  mov	ESI, [EBP + 28] ;tempArray

  ;convert string to decimal
validateNumber:
; uses LODSB to individuall acces each string byte
; compares the string byte to determin if it is valid

  LODSB ;put bytes in AL
  cmp	AL, 43 ; compares AL to negative sign
  JE	negativeNumber	

  cmp	AL, 45 ; compares AL to positive sign
  je	positiveNumberConversion

  cmp	AL, 48 ; compares AL to 0
  jl	invalid

  cmp	AL, 57 ; compares AL to 9
  jg	invalid
  jmp	positiveNumberConversion

invalid:
; if string byte is not a + or - or does not
; correspond to a integer then the user is 
; given an error prompt and asked to re enter
; a valid string

  mDisplayString [EBP + 12]
  mGetString [EBP + 16], [EBP + 28], [EBP + 36]
  jmp	validateNumber

negativeNumber:
; if the string entered has a starting negative sign 
; then its is converted into the corresponding negative
; value and is added to the userArray
  

positiveNumberConversion:
; if the string entered has a starting positive or no sign 
; then its is converted into the corresponding positive
; value and is added to the userArray

  ;conversion block 
  sub	AL, 48
  mov	[EBP + 48], AL
  mov	AL, [EBP + 44]
  mov	BL, 10
  mul	BL
  add	AL, [EBP + 48]
  movzx	EAX, AL
 
  ;add decimal to userArray block 
  loop 	convertNumbers

  mov	ESI, [EBP + 32] ;userArray
  mov	[ESI], EAX
  add	ESI, 4
  pop	ECX
  pop	EBP
  ret	
  
ReadVal ENDP
;-------------------------------------------------------------------
WriteVal PROC
;this procedure converts the decimals in userArray back into strings
;to be displayed. this procedure also displays the sum and avg of the 
;values stored in the array
;-------------------------------------------------------------------
WriteVal ENDP

Invoke ExitProcess,0 ; exit to operating system
end main

; (insert additional procedures here)

;END main