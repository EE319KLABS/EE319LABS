;****************** main.s ***************
; Program written by: put your names here
; Date Created: 1/24/2015 
; Last Modified: 1/24/2015 
; Section 1-2pm     TA: Saugata Bhattacharyya
; Lab number: 2
; Brief description of the program
; The overall objective of this system is a digital lock
; Hardware connections
;  PF4 is switch input  (1 means SW1 is not pressed, 0 means SW1 is pressed)
;  PF2 is LED output (1 activates blue LED) 
; The specific operation of this system 
;    1) Make PF2 an output and make PF4 an input (enable PUR for PF4). 
;    2) The system starts with the LED ON (make PF2 =1). 
;    3) Delay for about 1 ms
;    4) If the switch is pressed (PF4 is 0), then toggle the LED once, else turn the LED ON. 
;    5) Repeat steps 3 and 4 over and over

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
	BL init
loop  
	BL delay
	LDR R0,[R1];
	ANDS R0,#0x10 ;ANDS is needed to set NPVC flags
	BNE TurnLED_ON	;Branches to TurnLED_ON if switch is not pressed
ToggleLED			;continues to ToggleLED if switch is pressed
	LDR R0,[R1]
	EOR R0,#0x04	;Exclusive OR will toggle LED in DATA every time it executes
	STR R0,[R1]
    B loop
TurnLED_ON
	LDR R0,[R1];
	ORR R0,#0x04	
	STR R0,[R1];
	B loop
delay 	
	MOV R0,#0xFA0	;1 Cycle
wait	
	SUBS R0,#0x01	;1 Cycle
	BNE wait		;(1 or 1 + p) [Average 3 Cycles]
	BX LR;
init
;Turn on Port F Clock
	LDR R1, = SYSCTL_RCGCGPIO_R;
	LDR R0, [R1];
	ORR R0,#0x20;
	STR R0,[R1];
	NOP
	NOP
;Set Pin Directions
	LDR R1, = GPIO_PORTF_DIR_R;
	LDR R0, [R1];
	BIC R0,#0x10;
	ORR R0,#0x04;
	STR R0,[R1];
;Turn off Alternate Functions
	LDR R1, = GPIO_PORTF_AFSEL_R;
	LDR R0, [R1];
	BIC R0,#0x14;
	STR R0,[R1];
;Enable Digital Pins
	LDR R1, = GPIO_PORTF_DEN_R;
	LDR R0, [R1];
	ORR R0,#0x14;
	STR R0,[R1];
;PULL UP RESISTOR ENABLED!!!
	LDR R1, = GPIO_PORTF_PUR_R
	LDR R0,[R0]
	ORR R0,#0x10
	BIC R0,#0x04
	STR R0,[R1]
;SET PF2 =1 System starts like this
	LDR R1, = GPIO_PORTF_DATA_R;
	LDR R0,[R1];
	ORR R0,#0x04;
	STR R0,[R1];
	BX LR
	
       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file
       