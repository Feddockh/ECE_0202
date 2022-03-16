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

	; Set up steps
	; Clock enable
	; c as output
	; b as input

	; Enable GPIOB and GPIOC
	LDR r0, =RCC_BASE           ; Load the address for the base to r0
	LDR r1, [r0, #RCC_AHB2ENR]  ; Load the clock part to r1 from r0
	ORR r1, #0x6                ; Load bits 1 and 2 to enable the clocks for GPIOB and GPIOC
	STR r1, [r0, #RCC_AHB2ENR]  ; Store the modified bits back to the address in r0 for the clock register
	
	; Set the mode of GPIOB
	LDR r9, =GPIOB_BASE         ; Load the address of GPIOB into r9
	LDR r10, [r9, #GPIO_MODER]  ; Load the bits of the moder into r10 with the offset
	BIC r10, #0xC00             ; Mask bits that control mode for pins 1,2,3, and 5 for digital input (00)
	BIC r10, #0x0FC              ; Set all the other mode pins to 1
	STR r10, [r9, #GPIO_MODER]  ; Store back to the GPIO address in r0 with Moder offset
	
	; Set the mode of GPIOC
	LDR r11, =GPIOC_BASE        ; Load the address of GPIOC
	LDR r12, [r11, #GPIO_MODER]   ; Load the bits of the moder into r1 with the offset
	BIC r12, #0xFF               ; Clear the bits of the moder
	ORR r12, #0x55               ; Set the mode pins to output (01)             
	STR r12, [r11, #GPIO_MODER]   ; Store back to the GPIO address in r0 with Moder offset
	
	; Reset the Output Data Register for GPIOC
	LDR r12, [r11, #GPIO_ODR]     ; Load in the ODR register address into r1 from r0
	AND r12, #0x0                ; Mask the ODR register from r1
	STR r12, [r11, #GPIO_ODR]     ; Store the data back from r1 to r0 with the ODR shift
	
	; Store char1 address to r8
	LDR r8, = char1
	
	; Registers
		; r8 is for display key function (don't touch)
		; r9 and r10 for loading, storing, and masking GPIOB
		; r11 and r12 for loading, storing, and masking GPIOC
		
		
	; GPIOB is for reading values from the columns
	; GPIOC is for writing values to control the rows
	
	; loop
	; pull all rows low
	; delay
	; check all column inputs = 1
	
loop
	; Reset the ODR to look for any down button
	LDR r12, [r11, #GPIO_ODR]     ; Load in the ODR register address into r12 from GPIOC (r11)
	MOV r12, #0x0                 ; Mask the ODR register from r12
	STR r12, [r11, #GPIO_ODR]     ; Store the data back from r12 to GPOIC (r11) with the ODR shift
	
	bl delay                      ; Delay function
	
	; Load input from the IDR
	LDR r10, [r9, #GPIO_IDR]      ; Load in the IDR register address into r10 from GPIOB (r9)
	AND r10, #0x2E                ; Only show IDR inputs from pins 1,2,3, and 5 (this output will be 0x2E when nothing is pressed)
	CMP r10, #0x2E                ; Check to see if any of the columns are pressed, if none are pressed the IDR will be equal to 0x2E
	BEQ loop                      ; If nothing is 0 then jump back to the top of the loop
	
	
	
	; Manually go through each row and each column for each row
	; r0 for masking ODR and checking IDR
	; r1 for incrementing the columns
	; r2 for incrementing the rows
	; r3 
	; r4 
	; r5 should be given the ascii value from the array for the function
	
	;;;;;;;;;;;; ROW 1 ;;;;;;;;;;;;
	MOV r12, #0xE                 ; Give value to r12 to pull down row 1 (pin 0 needs to be 0 and rest should be 1)
	STR r12, [r11, #GPIO_ODR]     ; Store r12 to the GPIOC ODR with GPIOC offset r11 and the ODR shift
	
	BL delay                      ; Delay for debouncing
	
	; Return the updated IDR value for the pulled down row
	MOV r10, 0x0
	LDR r10, [r9, #GPIO_IDR]       ; Load in the IDR register address into r10 from r9
	
	; Check column 1
	AND r0, r10, #0x2             ; Mask IDR with 0x2 because pin 1 and store in r0
	CMP r0, #0x2                  ; Compare the masked IDR in r0 to 0x2
	MOVNE r5, 49                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 1
	
	; Check column 2
	AND r0, r10, #0x4             ; Mask IDR with 0x4 because pin 2 and store in r0
	CMP r0, #0x4                  ; Compare the masked IDR in r0 to 0x4
	MOVNE r5, 50                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 2
	
	; Check column 3
	AND r0, r10, #0x8             ; Mask IDR with 0x8 because pin 3 and store in r0
	CMP r0, #0x8                  ; Compare the masked IDR in r0 to 0x8
	MOVNE r5, 51                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 3
	
	; Check column 4
	AND r0, r10, #0x20            ; Mask IDR with 0x20 because pin 5 and store in r0
	CMP r0, #0x20                 ; Compare the masked IDR in r0 to 0x20
	MOVNE r5, 65                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 4
	
	;;;;;;;;;;;; ROW 2 ;;;;;;;;;;;;
	MOV r12, #0xD                 ; Give value to r12 to pull down row 2 (pin 1 needs to be 0 and rest should be 1)
	STR r12, [r11, #GPIO_ODR]     ; Store r12 to the GPIOC ODR with GPIOC offset r11 and the ODR shift
	
	BL delay                      ; Delay for debouncing
	
	; Return the updated IDR value for the pulled down row
	MOV r10, 0x0
	LDR r10, [r9, #GPIO_IDR]       ; Load in the IDR register address into r10 from r9
	
	; Check column 1
	AND r0, r10, #0x2             ; Mask IDR with 0x2 because pin 1 and store in r0
	CMP r0, #0x2                  ; Compare the masked IDR in r0 to 0x2
	MOV r5, 52                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 1
	
	; Check column 2
	AND r0, r10, #0x4             ; Mask IDR with 0x4 because pin 2 and store in r0
	CMP r0, #0x4                  ; Compare the masked IDR in r0 to 0x4
	MOV r5, 53                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 2
	
	; Check column 3
	AND r0, r10, #0x8             ; Mask IDR with 0x8 because pin 3 and store in r0
	CMP r0, #0x8                  ; Compare the masked IDR in r0 to 0x8
	MOV r5, 54                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 3
	
	; Check column 4
	AND r0, r10, #0x20            ; Mask IDR with 0x20 because pin 5 and store in r0
	CMP r0, #0x20                 ; Compare the masked IDR in r0 to 0x20
	MOV r5, 66                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 4
	
	
	;;;;;;;;;;;; ROW 3 ;;;;;;;;;;;;
	MOV r12, #0xB                 ; Give value to r12 to pull down row 3 (pin 3 needs to be 0 and rest should be 1)
	STR r12, [r11, #GPIO_ODR]     ; Store r12 to the GPIOC ODR with GPIOC offset r11 and the ODR shift
	
	BL delay                      ; Delay for debouncing
	
	; Return the updated IDR value for the pulled down row
	MOV r10, 0x0
	LDR r10, [r9, #GPIO_IDR]       ; Load in the IDR register address into r10 from r9
	
	; Check column 1
	AND r0, r10, #0x2             ; Mask IDR with 0x2 because pin 1 and store in r0
	CMP r0, #0x2                  ; Compare the masked IDR in r0 to 0x2
	MOV r5, 55                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 1
	
	; Check column 2
	AND r0, r10, #0x4             ; Mask IDR with 0x4 because pin 2 and store in r0
	CMP r0, #0x4                  ; Compare the masked IDR in r0 to 0x4
	MOV r5, 56                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 2
	
	; Check column 3
	AND r0, r10, #0x8             ; Mask IDR with 0x8 because pin 3 and store in r0
	CMP r0, #0x8                  ; Compare the masked IDR in r0 to 0x8
	MOV r5, 57                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 3
	
	; Check column 4
	AND r0, r10, #0x20            ; Mask IDR with 0x20 because pin 5 and store in r0
	CMP r0, #0x20                 ; Compare the masked IDR in r0 to 0x20
	MOV r5, 67                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 4
	
	
	;;;;;;;;;;;; ROW 4 ;;;;;;;;;;;;
	MOV r12, #0x7                 ; Give value to r12 to pull down row 4 (pin 5 needs to be 0 and rest should be 1)
	STR r12, [r11, #GPIO_ODR]     ; Store r12 to the GPIOC ODR with GPIOC offset r11 and the ODR shift
	
	BL delay                      ; Delay for debouncing
	
	; Return the updated IDR value for the pulled down row
	MOV r10, 0x0
	LDR r10, [r9, #GPIO_IDR]       ; Load in the IDR register address into r10 from r9
	
	; Check column 1
	AND r0, r10, #0x2             ; Mask IDR with 0x2 because pin 1 and store in r0
	CMP r0, #0x2                  ; Compare the masked IDR in r0 to 0x2
	MOV r5, 42                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 1
	
	; Check column 2
	AND r0, r10, #0x4             ; Mask IDR with 0x4 because pin 2 and store in r0
	CMP r0, #0x4                  ; Compare the masked IDR in r0 to 0x4
	MOV r5, 48                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 2
	
	; Check column 3
	AND r0, r10, #0x8             ; Mask IDR with 0x8 because pin 3 and store in r0
	CMP r0, #0x8                  ; Compare the masked IDR in r0 to 0x8
	MOV r5, 35                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 3
	
	; Check column 4
	AND r0, r10, #0x20            ; Mask IDR with 0x20 because pin 5 and store in r0
	CMP r0, #0x20                 ; Compare the masked IDR in r0 to 0x20
	MOV r5, 68                    ; Move an ascii value into r5
	BNE displaykey                ; Call the display key function if column 4
	
	
	B loop
	
	
	
	; How to use:
	; Basically move the ascii value into r5 and call the function
	; LDR r8, =char1
	; MOV r5, [ascii value]
	
displaykey
	LDR r10, [r9, #GPIO_IDR]      ; Load in the IDR register address into r10 from GPIOB (r9)
	AND r10, #0x2E                ; Only show IDR inputs from pins 1,2,3, and 5 (this output will be 0x2E when nothing is pressed)
	CMP r10, #0x2E                ; Check to see if any of the columns are pressed, if none are pressed the IDR will be equal to 0x2E
	BNE displaykey                ; Continue to branch (loop) until none of the buttons are pressed

	STR	r5, [r8]
	LDR	r0, =char1  ; First argument
	MOV r1, #1      ; Second argument
	BL USART2_Write	
 	B loop
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

char1	DCD	49
	END