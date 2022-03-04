;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************


	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	BL System_Clock_Init
	BL UART2_Init



;;;;;;;;;;;; YOUR CODE GOES HERE	;;;;;;;;;;;;;;;;;;;

	; Enable GPIOB and GPIOC
	LDR r0, =RCC_BASE           ; Load the address for the base to r0
	LDR r1, [r0, #RCC_AHB2ENR]  ; Load the clock part to r1 from r0
	ORR r1, #0x6                ; Load bits 1 and 2 to enable the clocks for GPIOB and GPIOC
	STR r1, [r0, #RCC_AHB2ENR]  ; Store the modified bits back to the address in r0 for the clock register
	
	; Set the mode of GPIOB
	LDR r9, =GPIOB_BASE         ; Load the address of GPIOB into r0
	LDR r10, [r9, #GPIO_MODER]  ; Load the bits of the moder into r1 with the offset
	BIC r10, #0xC00             ; Clear bits to reset the mode
	BIC r10, #0x0FC
	LDR r0, #0x300              ; Create a register to hold mask
	ADD r0, #0x003
	AND r10, r0;                ; Set the mode pins to input (00)
	STR r1, [r9, #GPIO_MODER]   ; Store back to the GPIO address in r0 with Moder offset
	
	; Set the mode of GPIOC
	LDR r11, =GPIOC_BASE        ; Load the address of GPIOC
	LDR r12, [r11, #GPIO_MODER]   ; Load the bits of the moder into r1 with the offset
	BIC r12, #0xFF               ; Clear the bits of the moder
	ORR r12, #0x55               ; Set the mode pins to output (01)             
	STR r12, [r11, #GPIO_MODER]   ; Store back to the GPIO address in r0 with Moder offset
	
	; Enable the Output Data Register for GPIOC
	LDR r12, [r11, #GPIO_ODR]     ; Load in the ODR register address into r1 from r0
	AND r12, #0x0                ; Mask the ODR register from r1
	STR r12, [r11, #GPIO_ODR]     ; Store the data back from r1 to r0 with the ODR shift
	
	; Clock enable
	; c as output
	; b as input
	
	LDR r8, = char1
	
	; mov ascii value into r5
	
	
	
	; Registers
		; r2 masks for rows
		; r3 column inputs
		
		; r0-r3 for loop operations
		; r5 for setting ascii character
		; r8 is for display key function
		; r9 and r10 for loading, storing, and masking GPIOB
		; r11 and r12 for loading, storing, and masking GPIOC
		
		
	; GPIOC is for writing values to control the rows
	; GPIOB is for reading values from the columns
	
	; loop
	; pull all rows low
	; delay
	; check all column inputs = 1
	
loop
	LDR r4, =GPIO_C_BASE
	LDR r6, [r4, #GPIO_ODR]     ; Load in the ODR register address into r1 from r0
	AND r6, #0x0                ; Mask the ODR register from r1
	STR r6, [r4, #GPIO_ODR]     ; Store the data back from r1 to r0 with the ODR shift
	
	bl delay                    ; Delay function
	
	; Load input from the IDR
	; If none are pressed, IDR will be all ones
	LDR r0, =GPIOB_BASE         ; Load the address of GPIOB into r0
	LDR r1, [r0, #GPIO_IDR]     ; Load in the IDR register address into r1 from r0
	CMP r1, #0xF                ; Check to see if any of the columns are pressed
	BEQ loop
	
	; Pull only the first row low and check
	LDR r6, [r4, #GPIO_ODR]     ; Load in the ODR register address into r1 from r0
	AND r6, #0xE                ; Mask the ODR register from r1
	STR r6, [r4, #GPIO_ODR]     ; Store the data back from r1 to r0 with the ODR shift
	
	MOV r2, #0x0
	MOV r3, #0x0
	
	; Outer loop iterates through rows
loopRow
	
	MOV r7, #0x1
	LSL r7, r2
	MVN r6, r7
	STR r6, [r4, #GPIO_ODR]     ; Store the data back from r1 to r0 with the ODR shift
	
	; Iterate through checking all columns
	
	
	
	
	
	
	ADD r2, #0x1
	B loopRow


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	; How to use:
	; LDR r8, =char1
	; MOV r5, [ascii value]
	
displaykey
	STR	r5, [r8]
	LDR	r0, =char1  ; First argument
	MOV r1, #1      ; Second argument
	BL USART2_Write
 	
	ENDP		

			
		

delay	PROC
	; Delay for software debouncing
	LDR	r2, =0x9999
delayloop
	SUBS	r2, #1
	BNE	delayloop
	BX LR
	
	ENDP
		
		
					
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN

char1	DCD	43
	END