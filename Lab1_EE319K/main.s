;****************** main.s ***************
; Program written by: Kyle Sikora and Briar Coker
; Date Created: 1/24/2015 
; Last Modified: 1/24/2015 
; Section 1-2pm     TA: Wooseok Lee
; Lab number: 1
; Brief description of the program
; The overall objective of this system is a digital lock
; Hardware connections
;  PE3 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE4 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE2 is LED output (0 means door is locked, 1 means door is unlocked) 
; The specific operation of this system is to 
;   unlock if both switches are pressed

GPIO_PORTE_DATA_R       EQU   0x400243FC ;agsharhe
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
SYSCTL_RCGC2_R          EQU   0x400FE108

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
Start
	;PE2 = 0 off, 1 ON
	;PE3 = input switch = 1 notpress, 0 pressed
	;PE4 = input switch = 1 notpress, 0 pressed
	;PE2 = 1 if and only if PE3 = 0 && PE4 = 0
;Turn on Port E Clock and wait 2 clock cycles
	LDR R1,= SYSCTL_RCGCGPIO_R
	LDR R0,[R1]
	ORR R0,R0,#0x10
	STR R0,[R1]
	NOP
	NOP
;Set Direction Register (output PE2, input: PE3, PE4) 1=output 0=input
	LDR R1,=GPIO_PORTE_DIR_R
	LDR R0,[R1]
	ORR R0,#0x04
	BIC R0,#0x18
	STR R0,[R1]
;Disable Alternate Functions of Registers 
	LDR R1,= GPIO_PORTE_AFSEL_R
	LDR R0, [R1]
	BIC R0,#0x1C
	STR R0,[R1]
;Enable Digital I/o Port
	LDR R1,=GPIO_PORTE_DEN_R
	LDR R0,[R1]
	ORR R0,#0x1C
	STR R0,[R1]
		
;R1 = PORTE data address location
	LDR R1,=GPIO_PORTE_DATA_R 
loop
;Get PORTE DATA
	LDR R0,[R1]
;Test if PE3 is 0, else Branch to turnoff
	MOV R3,R0
	AND R3,#0x08
	CMP R3,#0x00
	BNE TurnOff
;Test if PE4 is 0, else Branch to turnoff
	MOV R4,R0
	AND R4,#0x10
	CMP R4,#0x00
	BNE TurnOff
;Else Turn ON PE2
	ORR R0,#0x04
	STR R0,[R1]
	B loop
TurnOff
	BIC R0,#0x04
	STR R0,[R1]
	B loop

      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file