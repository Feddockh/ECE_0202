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
	
;;;;;;; Your Code Goes Here ;;;;;;;;;;
;;;;;;; Your Code Goes Here ;;;;;;;;;;
;;;;;;; Your Code Goes Here ;;;;;;;;;;
;;;;;;; Your Code Goes Here ;;;;;;;;;;

	; Enable GPIOB and GPIOC
	LDR r0, =RCC_BASE           ; Load the address for the base to r0
	LDR r1, [r0, #RCC_AHB2ENR]  ; Load the clock part to r1 from r0
	ORR r1, #0x6                ; Load bits 1 and 2 to enable the clocks for GPIOB and GPIOC
	STR r1, [r0, #RCC_AHB2ENR]  ; Store the modified bits back to the address in r0 for the clock register
	
	; Set the mode of GPIOB
	LDR r0, =GPIOB_BASE         ; Load the address of GPIOB into r0
	LDR r1, [r0, #GPIO_MODER]   ; Load the bits of the moder into r1 with the offset
	BIC r1, #0xF000             ; Clear bits to reset the mode
	BIC r1, #0x00F0
	ORR r1, #0x5000             ; Set the mode pins to output (01)
	ORR r1, #0x0050
	STR r1, [r0, #GPIO_MODER]   ; Store back to the GPIO address in r0 with Moder offset
	
	; Enable the Output Data Register for GPIOB
	LDR r0, =GPIOB_BASE         ; Load in memory location of GPIOB to r0
	LDR r1, [r0, #GPIO_ODR]     ; Load in the ODR register address into r1 from r0
	AND r1, #0x00               ; Mask the ODR register from r1
	STR r1, [r0, #GPIO_ODR]     ; Store the data back from r1 to r0 with the ODR shift
	
	; Set the mode of GPIOC
	LDR r5, =GPIOC_BASE         ; Load the address of GPIOC into r5
	LDR r6, [r5, #GPIO_MODER]   ; Load the bits of the moder into r1 with the offset
	AND r6, #0x0000             ; Set the mode pins to input (00)
	STR r6, [r5, #GPIO_MODER]   ; Store back to the GPIO address in r0 with Moder offset

	
	; Delay
	; r0 and r1 for loading, storing, and masking GPIOB
	; r2 is for the number counter (i)
	; r3 is the delay counter (j)
	; r4 is used to store the max value of delay
	; r5 and r6 for loading, storing, and masking GPIOC
	
	; MSB is 7, LSB is 2
	; Therefore 7, 6, 3, 2
	
	; Concept:
		; loop
		; wait 1 sec
		; increment count register (0-9)
		; load r0 to r1
		; Use r2
		; store back
	
	  MOV r2, #0x0000           ; Set number counter to 0
	  MOV r4, #0xFFFF           ; Comparision number for delay CMP
	  LSL r4, #2                ; Shifts the comparision number further left

loop  
      MOV r3, #0x0000           ; reset delay counter to 0
	
delay                           ; Delay loop start
	  LDR r6, [r5, #GPIO_IDR]   ; Load the bits of the moder into r1 with the offset
	  AND r6, 0x2000
	  CMP r6, 0x0000
	  MOVEQ r2, #0x0000
	  BEQ reset

	  ADD r3, #0x0001           ; Increment r3
	  CMP r3, r4                ; Check if r3 is equal to the value in r5
	  BLT delay                 ; If r3 is less than r5, repeat the loop

reset
	  LDR r1, [r0, #GPIO_ODR]   ; Load in the ODR register address into r1 from r0
	  BIC r1, #0xFF00           ; Clear the bits from the r1 register
	  BIC r1, #0x00FF
	  
	  BFI r1, r2, #2, #2        ; Insert the first 2 bits of r2 into bits 2-3 of r1
	  BFI r1, r2, #4, #4        ; Inserts the second 2 bits of r2 into bits 6-7 of r1
	  
	  STR r1, [r0, #GPIO_ODR]   ; Store the data back from r1 to r0 with the ODR shift
	  
	  ADD r2, #0x0001           ; Add 1 to the r2 number counter
	  
	  CMP r2, #0x000A           ; Compare the number counter in r2 to 0
	  MOVEQ r2, #0x0000         ; If the number counter is 0, reset it to 0
	  
	  B loop                    ; Repeats the loop

stop 	B 		stop     		; dead loop & program hangs here

	ENDP						

	AREA myData, DATA, READWRITE
	ALIGN

	END