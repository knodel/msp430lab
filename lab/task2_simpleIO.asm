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
;		P1DIR
;       -----
;		  7   6   5   4 | 3   2   1   0
;		---------------------------------
;       | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 |     1: output
;       ---------------------------------     0: input
;             |                       |
;             v                       v
;         LED green                LED red
;
;		P1OUT
;       -----
;		  7   6   5   4 | 3   2   1   0
;		---------------------------------
;       | 0 | x | 0 | 0 | 0 | 0 | 0 | x |     1: on
;       ---------------------------------     0: off
;             |                       |
;             v                       v
;         LED green                LED red
;
;       P1IN
;       ----           Button S2
;                         |
;                         v
;		---------------------------------
;       | 0 | 0 | 0 | 0 | X | 0 | 0 | 0 |     0: on
;       ---------------------------------     1: off
;		  7   6   5   4 | 3   2   1   0
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;   Header and defines
;------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430g2553.h"  ; cdecls tells assembler to allow
                                            ; the c header file
LED_GREEN	.set 01000000b
LED_RED		.set 00000001b
LED_BOTH	.set LED_GREEN | LED_RED

SWITCH		.set 00001000b

;------------------------------------------------------------------------------
;   Initialization
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            bis.b   #LED_BOTH,&P1DIR       	; make P1.0 and P1.6 output
            bis.b   #LED_BOTH,&P1OUT        ; all others are inputs by default
            bis.b   #SWITCH,&P1REN			; enable pull-up resistor for P1.3

;------------------------------------------------------------------------------
;   Application Code
;------------------------------------------------------------------------------

Mainloop    mov.b 	&P1IN,R15
			inv.b	R15
			rra.b	R15
			rra.b	R15
			rra.b	R15
			mov.b	R15,&P1OUT
			bis.b   #LED_GREEN,&P1OUT
			jmp 	Mainloop

			bit.b   #SWITCH,&P1IN        	; read switch at P1.3
            jnz     Off                    	; if P1.3 is pressed the input is '0'

On          bic.b   #LED_RED,&P1OUT       	; clear P1.0 (red off)
            bis.b   #LED_GREEN,&P1OUT       ; set P1.6 (green on)
            jmp     Mainloop                ; branch to a delay routine

Off         bis.b   #LED_RED,&P1OUT       	; set P1.0 (red on)
            bic.b   #LED_GREEN,&P1OUT       ; clear P1.6 (green off)
            jmp 	Mainloop

Wait        mov.w   #4000,R15               ; load R15 with value for delay
L1          dec.w   R15                     ; decrement R15
            jnz     L1                      ; if R15 is not zero jump to L1
            jmp     Mainloop                ; jump to the Mainloop label

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








