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
;                MSP430G2231
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |             P1.0|--> LED red
;   Buton -->|P1.3         P1.6|--> LED green
;            |                 |
;             -----------------
;
;			Status Register
;			Bit  8 7 6 5 4 3 2 1 0
;			Flag V - - - - - N Z C
;
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
;   Header and defines
;------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430g2231.h"  ;MSP430 G2231



LED_GREEN	.set 01000000b
LED_RED		.set 00000001b
LED_BOTH	.set LED_GREEN | LED_RED
SWITCH		.set 00001000b

COUNT       .equ 0x0004

;------------------------------------------------------------------------------
;   Data segment
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;   Initialization
;------------------------------------------------------------------------------

            .text                           ; program start
           	.global _main		    		; define entry point


_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            mov.b   #LED_BOTH,&P1DIR
			mov.b	#LED_GREEN,&P1OUT

;------------------------------------------------------------------------------
;   Timer Initialization
;------------------------------------------------------------------------------
     		mov.w   #CCIE,&CCTL0            ; CCR0 interrupt enabled
           	mov.w   #0xFFFF,&TACCR0         ; Timer_A Capture CompaRe
    		mov.w   #(TASSEL_2 | MC_3 | ID_3 | TAIE ),&TACTL

    										; SMCLK, continous_mode
											; TACTL:	Timer_A ConTroL
											; TASSEL:   Timer_A Source SELect
											; TASSEL_2: SMCLK (1MHz)
											; MC_0      Halt
											; MC_1:		up_mode                   = 1:50000
											; MC_2:		continous_mode
											; MC_3:		up-down_mode			  = 1:100000
											; ID_2:     Vorteiler (Input Divider) = 1:4
                                            ; --> 1:400000

    		;bis.w   #CPUOFF+GIE,SR        	; CPU off, interrupts enabled  --> sleep mode
			bis.w   #GIE,SR          		; CPU on, interrupts enabled


;------------------------------------------------------------------------------
;   Mainloop
;------------------------------------------------------------------------------

Mainloop		nop
 		        jmp 	Mainloop               ; Required only for debugger...


;-------------------------------------------------------------------------------
;    Toggle P1.0
;-------------------------------------------------------------------------------
TA0_ISR			nop
				xor.b   #01000001b,&P1OUT
            	reti


;------------------------------------------------------------------------------
;   Reset
;------------------------------------------------------------------------------

_reset      	mov.b   #0x00,&P1OUT
				jmp     _main


;------------------------------------------------------------------------------
;   Subroutines
;------------------------------------------------------------------------------

LongWait    push    SR
			push    R15
			mov.w   #COUNT,R15
LongWait_l  dec.w   R15
            call    #ShortWait
            jnz     LongWait_l
            pop     R15
            pop     SR
            ret


ShortWait   push    SR
			push    R15
			mov.w   #0x0,R15
ShortWait_l dec.w   R15
            jnz     ShortWait_l
            pop     R15
            pop     SR
            ret


;------------------------------------------------------------------------------
;   Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  _reset

            .sect   ".int09"                ; Timer_A0 Vector
            .short  TA0_ISR                 ;

			.end

