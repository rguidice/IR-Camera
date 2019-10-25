;************************************
; Student's Name: Ryan Guidice
; Date: 10/5/2019
; Lab #9 - Smart Security Camera
; Name of File: Lab9.s
; Description of Program:
; 		IR sensor on Tiva board triggers an interrupt that sends trigger to Raspberry Pi to start recording via webcam.
;************************************

;************************************
;EQU Directives
;************************************
;SYMBOL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 0x400053FC 	;Port B data address
GPIO_PORTB_DIR 		EQU 0x40005400
GPIO_PORTB_AFSEL 	EQU 0x40005420 
GPIO_PORTB_DEN 		EQU 0x4000551C 
IOB 				EQU 2_00111111 	; Port B - 6 outputs
GPIO_PORTE_DATA 	EQU 0x400243FC 	; Port E data address
GPIO_PORTE_DIR 		EQU 0x40024400
GPIO_PORTE_AFSEL 	EQU 0x40024420
GPIO_PORTE_DEN 		EQU 0x4002451C
IOE 				EQU 2_00000000	; Port E - all inputs
SYSCTL_RCGCGPIO 	EQU 0x400FE608
GPIO_PORTE_PUR 		EQU 0x40024510
NVIC_ST_CTRL		EQU	0xE000E010
NVIC_ST_RELOAD		EQU	0xE000E014
NVIC_ST_CURRENT		EQU	0xE000E018
SHP_SYSPRI3			EQU	0xE000ED20
RELOAD_VALUE		EQU	0x003C0000
DELAY_CLKS			EQU	0x3D08FF
	
;****************************************
; Data Section
; Can be combined with other message texts
;****************************************
;SYMBOL		DIRECTIVE	VALUE		COMMENT
			AREA   		|.text|, READONLY, DATA

MSG_MOTION	DCB			"Motion detected.",13,4
	
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

__main		; Initialize UARTIO
			BL	UART_Init

			; Set up GPIO clock
			LDR R1, =SYSCTL_RCGCGPIO
			LDR R0, [R1]
			ORR R0, R0, #0x12
			STR R0, [R1]
			NOP
			NOP
			NOP
			
			; Initialize GPIO port B
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
			
			; Initialize GPIO port E
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
			
			; Initialize SysTick
			LDR	R1,=NVIC_ST_CTRL
			MOV	R0,#0
			STR	R0,[R1]
			LDR	R1,=NVIC_ST_RELOAD
			LDR	R0,=RELOAD_VALUE
			STR	R0,[R1]
			LDR	R1,=NVIC_ST_CURRENT
			MOV	R0,#0
			STR	R0,[R1]
			LDR	R1,=SHP_SYSPRI3
			MOV	R0,#0x40000000
			STR	R0,[R1]
			LDR	R1,=NVIC_ST_CTRL
			MOV	R0,#0x03
			STR	R0,[R1]
			
			; Enable maskable interrupts
			CPSIE	I
			
wait		WFI
			B		wait
			
			; Delay subroutine, should delay for approx. 1s based on processor clock speed
DELAY		PUSH	{LR}
			PUSH	{R0}
			LDR 	R0,=DELAY_CLKS
del			SUBS	R0, R0, #1
			BNE		del
			POP		{R0}
			POP		{LR}
			BX		LR	
			
;************************************
;IR Sensor ISR
;************************************
			EXPORT SysTick_Handler

SysTick_Handler	PUSH	{LR,R0,R1}
				LDR		R1,=GPIO_PORTE_DATA		; Will be 0xFE if no IR detected, 0xFF if IR detected
				LDR 	R0,[R1]
				MOV		R2,#0xFF				
				CMP		R2,R0					; Check if R2 and R0 are equal, if they aren't then skip the motion code
				BNE		no_motion				
				LDR		R0,=MSG_MOTION			; Outputs "Motion detected" to terminal via OutStr
				BL		OutStr				
				LDR		R1,=GPIO_PORTB_DATA		
				STR		R2,[R1]					; Sets GPIO Port B data to be 0xFF, which will tell Raspberry Pi there is IR detected
no_motion		BL		DELAY					; Delay for about 1s to avoid issues with GPIO
				MOV		R2,#0x00				
				STR		R2,[R1]					; Reset Port B data so the next loop cycle will be accurate on if there is IR detected or not
				POP		{LR,R0,R1}
				BX		LR

;****************************************
; End of program
;****************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			ALIGN
			END
			