;------------------------------------------------------------------------------
; MIT License
;
; Copyright (c) 2019 Oliver Knodel
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;   Digital I/O example for the LaunchPad
;   Read the status of built in push button - P1.3
;   (Note that P1.3 is "1" when the push button is open and "0" when the button is closed)
;   Red light if the button is not pushed - P1.0
;   Green light if the button is pushed - P1.6

;   Erweiterunng: simple Zeitverz�gerung des Anschaltens (mittels Warteschleife)
;;------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430g2231.h"  ; cdecls tells assembler to allow
;                                            ; the c header file
;            .cdecls C,LIST,"msp430g2553.h"  ; cdecls tells assembler to allow
                                            ; the c header file

;******************************************************************************
;   Main Code
;******************************************************************************

            .text                           ; program start
            .global _main		    ; define entry point

;------------------------------------------------------------------------------
;  Definition von Konstanten      zwecks besserer Lesbarkeit
;                                        leichterer �nderung des Programms

LED_GREEN 		.set	01000000b
LED_RED 		.set	00000001b
LED_BOTH		.set	LED_GREEN | LED_RED
PLED_DIR		.set	P1DIR
PLED_OUT		.set	P1OUT

SWITCH			.set	00001000b
PSWITCH_DIR 	.set	P1DIR
PSWITCH_IN  	.set	P1IN




;*******************************************************************************
;   MSP430G2xx1 Demo - Timer_A, Toggle P1.0, CCR0 Cont. Mode ISR, DCO SMCLK
;
;   Description: Toggle P1.0 using software and TA_0 ISR. Toggles every
;   50000 SMCLK cycles. SMCLK provides clock source for TACLK.
;   During the TA_0 ISR, P1.0 is toggled and 50000 clock cycles are added to
;   CCR0. TA_0 ISR is triggered every 50000 cycles. CPU is normally off and
;   used only during TA_ISR.
;   ACLK = n/a, MCLK = SMCLK = TACLK = default DCO
;
;                MSP430G2xx1
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |             P1.0|-->LED
;
;   D. Dang
;   Texas Instruments Inc.
;   October 2010
;   Built with Code Composer Essentials Version: 4.2.0
;*******************************************************************************


;------------------------------------------------------------------------------
; Einsprungpunkt: Beginn des eigentlichen Programms
;
; Initialisierung der Hardware
;------------------------------------------------------------------------------
reset      		mov.w   #0280h,SP               ; Initialize stackpointer

StopWDT     	mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT

				mov.b	#382d,R5
				clrc
				mov.w   R5,R6
				push    R6
				rlc		R6
				rlc		R6
				add.w	r5,r6
				and.b	#0fff1h,r6


				mov.b	#99h,R7
				Push	R7

				mov.w	#027Eh,R5
				mov.w	@R5,R5


				;Initialisierung der LEDs
            	bic.b   #(LED_GREEN | LED_RED),&PLED_DIR   ; P1.0 und P1.6 r�cksetzen
            		    ;erst definierten Zustand herstellen, dann auf Output schalten!
            	bis.b   #(LED_GREEN | LED_RED),&PLED_DIR   ; P1.0 und P1.6 Output
                                            ; alle anderen sind Inputs als Default

            	;Initialisierung des Tasters
            	;bic.b	#SWITCH,&PSWITCH_DIR    ; P1.3 Input (eigentlich unn�tig ...)
				bis.b 	#00001000b,&P1REN		;internen PULL-Up-Widerstand anschalten

waitloop		bit.b   #SWITCH,&PSWITCH_IN     ; Taste an P1.3 einlesen
            	jnz     waitloop                     ; Sprung, wenn Taste offen



SetupC0     	mov.w   #CCIE,&CCTL0            ; CCR0 interrupt enabled
           		mov.w   #50000d,&TACCR0         		  ; Timer_A Capture CompaRe
SetupTA    		mov.w   #(TASSEL_2 | MC_3 | ID_2 | TAIE ),&TACTL  ; SMCLK, continous_mode
												; TACTL:	Timer_A ConTroL
												; TASSEL:   Timer_A Source SELect
												; TASSEL_2: SMCLK (1MHz)
												; MC_0      Halt
												; MC_1:		up_mode                   = 1:50000
												; MC_2:		continous_mode
												; MC_3:		up-down_mode			  = 1:100000
												; ID_2:     Vorteiler (Input Divider) = 1:4
                                                ; --> 1:400000
 ; leeres Hauptprogramm - alle Aktionen sind Interrupt getrieben

    	;bis.w   #CPUOFF+GIE,SR        			; CPU off, interrupts enabled  --> sleep mode
				bis.w   #GIE,SR          		; CPU on, interrupts enabled

Mainloop
 		        jmp 	Mainloop                ; Required only for debugger, besser sleep-mode
 ;-------------------------------------------------------------------------------
;    Toggle P1.0
;-------------------------------------------------------------------------------
TA0_ISR			nop
            	reti                            ;

                                            ;










;******************************************************************************
;   Main Loop
;******************************************************************************

;Mainloop
				bit.b   #SWITCH,&PSWITCH_IN     ; Taste an P1.3 einlesen
            	jnz     Off                     ; Sprung, wenn Taste offen

				;Taste gedr�ckt
On          	bic.b   #LED_RED,&PLED_OUT      ; rote LED aus
				call	#waitlong
            	bis.b   #LED_GREEN,&PLED_OUT    ; gr�ne LED an
            	jmp     fertig

				;Taste offen
Off         	bic.b   #LED_GREEN,&PLED_OUT    ;  gr�ne LED aus
				call	#waitlong
  				bis.b   #LED_RED,&PLED_OUT      ;  rote LED an

fertig			jmp 	Mainloop

;******************************************************************************
;   Subroutines
;******************************************************************************
; Warteschleife
waitshort		push	SR
				push	R15
				mov.w	#50000d,R15
waitshort_loop	dec		R15
				jnz		waitshort_loop
				pop		R15
				pop		SR
				ret

waitlong:    	push	SR
				push	R15
				mov.w	#5d,R15
waitlong_loop	call	#waitshort
				dec		R15
				jnz		waitlong_loop
				pop		R15
				pop		SR
				ret

;******************************************************************************
;   Interrupt Vectors
;******************************************************************************
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  reset

            .sect   ".int09"                ; Timer_A0 Vector
            .short  TA0_ISR                 ;

            .end
