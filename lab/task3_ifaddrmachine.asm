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

      		.text
count		.byte	0x0A
bytes     	.byte	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A
result      .byte   0xFF

;------------------------------------------------------------------------------
;   Initialization
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            bis.b   #LED_BOTH,&P1DIR       	; make P1.0 and P1.6 output
            bis.b   #0x00,&P1OUT        	; clear output register
            bis.b   #SWITCH,&P1REN			; enable pull-up resistor for P1.3

;------------------------------------------------------------------------------
;   Application Code
;------------------------------------------------------------------------------

;			Status Register
;			Bit  8 7 6 5 4 3 2 1 0
;			Flag V - - - - - N Z C

Mainloop    mov.b   #0x00,&P1OUT
			mov.w	#bytes,R4
			mov.b	&count,R6
			mov.b   #0x0,R5

Loop		add.b   @R4+,R5
			bit.w   #0x0001,SR
			jnz     Error
			dec.b	R6
			jnz		Loop

Correct		bis.b   #LED_GREEN,&P1OUT
			mov.b	R5,&result
			jmp 	Mainloop

Error		bis.b   #LED_RED,&P1OUT
			mov.b	#0xFF,&result
			jmp		Mainloop

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
