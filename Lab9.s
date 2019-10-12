;************************************
; Student's Name: Ryan Guidice
; Date: 10/5/2019
; Lab #9 - Smart Security Camera
; Name of File: Lab3.s
; Description of Program:
; 		IR sensor on Tiva board triggers an interrupt that sends trigger to Raspberry Pi to start recording via webcam.
;************************************

;************************************
;EQU Directives
;************************************
;SYMBOL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 0x400053FC ;Port B data address
GPIO_PORTB_DIR 		EQU 0x40005400
GPIO_PORTB_AFSEL 	EQU 0x40005420
GPIO_PORTB_DEN 		EQU 0x4000551C 
IOB 				EQU 2_00111111 ; port B 6 outputs
GPIO_PORTE_DATA 	EQU 0x400243FC ;Port E data address
GPIO_PORTE_DIR 		EQU 0x40024400
GPIO_PORTE_AFSEL 	EQU 0x40024420
GPIO_PORTE_DEN 		EQU 0x4002451C
IOE 				EQU 0x00		; port E all inputs
SYSCTL_RCGCGPIO 	EQU 0x400FE608
GPIO_PORTE_PUR 		EQU 0x40024510
DELAY_CLKS			EQU	0x3D08FF
	
;****************************************
; Data Section
; Can be combined with other message texts
;****************************************
;SYMBOL		DIRECTIVE	VALUE		COMMENT
			AREA   		|.text|, READONLY, DATA

MSG_MOTION	DCB			"Motion detected."
			DCB         0x0D
			DCB         0x04
	
;************************************
;Program Section
;************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA		main, READONLY, CODE
			THUMB
			IMPORT		UART_Init
			IMPORT		InChar
			IMPORT 		OutStr
			IMPORT		OutChar
			EXPORT		__main

__main		LDR R1, =SYSCTL_RCGCGPIO
			LDR R0, [R1]
			ORR R0, R0, #0x12
			STR R0, [R1]
			NOP
			NOP
			NOP

			LDR R1, =GPIO_PORTB_DIR
			LDR R0, [R1]
			BIC R0, #0xFF
			ORR R0, #IOB
			STR R0, [R1]
			LDR R1, =GPIO_PORTB_AFSEL
			LDR R0, [R1]
			BIC R0, #0xFF
			STR R0, [R1]
			LDR R1, =GPIO_PORTB_DEN
			LDR R0, [R1]
			ORR R0, #0xFF
			STR R0, [R1]

			LDR R1, =GPIO_PORTE_DIR
			LDR R0, [R1]
			ORR R0, #IOE
			STR R0, [R1]
			LDR R1, =GPIO_PORTE_AFSEL
			LDR R0, [R1]
			BIC R0, #0xFF
			STR R0, [R1]
			LDR R1, =GPIO_PORTE_DEN
			LDR R0, [R1]
			ORR R0, #0xFF
			STR R0, [R1]
			LDR R1, =GPIO_PORTE_PUR
			LDR R0, [R1]
			ORR R0, #0xFF
			STR R0, [R1]

			BL	CHECK

CHECK
loop		LDR	R1,=GPIO_PORTE_DATA
			LDR R0,[R1]
			LDR	R1,=GPIO_PORTB_DATA
			STR	R0,[R1]
			BL	DELAY
			B	loop  


DELAY		PUSH		{LR}
			PUSH		{R0}
			LDR 		R0,=DELAY_CLKS
del			SUBS		R0, R0, #1
			BNE			del
			POP			{R0}
			POP			{LR}
			BX			LR		
				
	
;****************************************
; End of program
;****************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			ALIGN
			END
			