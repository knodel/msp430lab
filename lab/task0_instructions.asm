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
;------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430g2231.h"  ; includes the c header file
COUNT      .equ     0x0004                  ; delay count
;------------------------------------------------------------------------------
;   Main Code
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            bis.b   #0x41,&P1DIR
            bic.b   #0x41,&P1OUT

;			Status Register
;			Bit  8 7 6 5 4 3 2 1 0
;			Flag V - - - - - N Z C

Mainloop    mov.b   #0x5A,R4
			mov.b	#0x78,R5
			add.b	R4,R5
			mov.w	SR,R6
			and.w	#0x0101,R6
			mov.b   R6,&P1OUT
			rrc.b   R6
			rrc.b   R6
			xor.b   R6,&P1OUT
			;Was hat das Programmst�ck getan?

			bic.b   #0x41,&P1OUT
			mov.b   #0x08,R4
			inv.b	R4
			inc.b	R4
			mov.b	#0x1E,R5
			inv.b	R5
			inc.b	R5
			add.b	R4,R5
			mov.w	SR,R6
			and.w	#0x0101,R6
			mov.b   R6,&P1OUT
			rrc.b   R6
			rrc.b   R6
			xor.b   R6,&P1OUT

			;Wie rechnen mit 16 Bit?

			;Ablegen der Daten auf den Stack...
			push.b  #0x3D
			push.b  #0x1F
			push.b	#0xF8

			;Worin unterscheiden sich die Schiebeoperationen?
     		mov.b   #0x08,R15
			mov.b	#0xD3,R4
			mov.b	#0xD3,R5
loop		rra.b	R4						;Rotate arithmetically
			rrc.b	R5						;Rotate through carry
			dec.b	R15
			jnz     loop

			;Was machen die Befehle?
			pop.b	R9
			sxt		R9
			pop.b	R10
			sxt		R10
			swpb	R10

			;Speichern auf dem Stack
			mov.b   #0x0F,R15
loop2		push 	R15
			dec.b	R15
			jnz 	loop2

			;und lesen vom Stack
			mov.b   #0x0F,R15
loop3		pop 	R14
			dec.b	R15
			jnz 	loop3

			;direkt in den Speicher schreiben 
			mov.w   #0xC0FE, &0x0200

			jmp Mainloop




;------------------------------------------------------------------------------
;   Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  _main

            .end
