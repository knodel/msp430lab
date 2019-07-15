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

;            .cdecls C,LIST,"msp430g2553.h"
			.cdecls C,LIST,"msp430g2231.h"

LED_GREEN	.set 01000000b
LED_RED		.set 00000001b
LED_BOTH	.set LED_GREEN | LED_RED
SWITCH		.set 00001000b

;------------------------------------------------------------------------------
;   Data segment
;------------------------------------------------------------------------------

      		.data
daten		.word 	0x90D6, 0x145A, 0x0000

;------------------------------------------------------------------------------
;   Initialization
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

;------------------------------------------------------------------------------
;   Application Code
;------------------------------------------------------------------------------

Mainloop	mov.w	#daten, R4
			mov.w	&daten, R5

			mov.w   2(R4), R6
			add.w   R5,R6

			rra.w   R6
			mov.w   R6,4(R4)

	        jmp     Mainloop

;------------------------------------------------------------------------------
;   Reset
;------------------------------------------------------------------------------

_reset      mov.b   #0x00,&P1OUT
			jmp     _main

;------------------------------------------------------------------------------
;   Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  _reset

			.end
