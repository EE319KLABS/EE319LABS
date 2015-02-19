;****************** main.s ***************
; Program written by: put your names here
; Date Created: 1/24/2015 
; Last Modified: 1/24/2015 
; Section 1-2pm     TA: Wooseok Lee
; Lab number: 3
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE0 is switch input  (1 means pressed, 0 means not pressed)
;  PE1 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 2, with five changes:
;1-  the pin to which we connect the switch is moved to PE0, 
;2-  you will have to remove the PUR initialization because pull up is no longer needed. 
;3-  the pin to which we connect the LED is moved to PE1, 
;4-  the switch is changed from negative to positive logic, and 
;5-  you should increase the delay so it flashes about 8 Hz.
; Operation
;	1) Make PE1 an output and make PE0 an input. 
;	2) The system starts with the LED on (make PE1 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE0 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over


GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
       IMPORT  TExaS_Init
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
 ; TExaS_Init sets bus clock at 80 MHz
      BL  TExaS_Init ; voltmeter, scope on PD3
; you initialize PE1 PE0
	BL init
; R0 now contains DATA address

      CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
;CPSIE I enables interrupts

loop  
; you input output delay
	BL delay
	  
	  B    loop
delay
;LED should be slowed to 8Hz
;16MHz/8Hz= 2E6 (total clock cycles)
;approx 4 cycles per wait loop
;2E6/4= 500000 = 0x7A120 or 4000 x 125, 4000=0xFA0
	MOV R0, #0x0FA0
	MOV R2, #125
	MUL R0, R0, R2
wait
	SUBS R0, #0x01 ;1 cycle
	BNE wait ;average 3 cycles
	BX LR
init
; Turn on Port E clock
	LDR R1, = SYSCTL_RCGCGPIO_R
	LDR R0, [R1]
	ORR R0, #0x10
	STR R0, [R1]
	NOP
	NOP
; Enable Digital Pins
	LDR R1, = GPIO_PORTE_DEN_R
	LDR R0, [R1]
	ORR R0, #0x03
	STR R0, [R1]
; Disable Analog 
	LDR R1, = GPIO_PORTE_AMSEL_R
	LDR R0, [R1]
	BIC R0, #0x03
	STR R0, [R1]
; Disable Alternate Functions
	LDR R1, = GPIO_PORTE_AFSEL_R
	LDR R0, [R1]
	BIC R0, #0x03
	STR R0, [R1]
; Set Data Register so that LED is on
	LDR R1, = GPIO_PORTE_DATA_R
	LDR R0, [R1]
	ORR R0, #0x02
	STR R0, [R1]
	BX LR
      ALIGN      ; make sure the end of this section is aligned
      END        ; end of file
       