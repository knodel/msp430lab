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

			;.cdecls C,LIST,"msp430g2553.h"
			.cdecls C,LIST,"msp430g2231.h"

LED_GREEN	.set 01000000b
LED_RED		.set 00000001b
LED_BOTH	.set LED_GREEN | LED_RED
SWITCH		.set 00001000b

;------------------------------------------------------------------------------
;   Data segment
;------------------------------------------------------------------------------

      		.data

input		.word 	0x1388
result      .word   0x0000

op1_lo		.word   0xF510
op2_lo		.word   0xD5F3
res_lo		.word   0x0000
res_hi		.word   0x0000


;------------------------------------------------------------------------------
;   Initialization
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            bis.b   #LED_BOTH,&P1DIR       	; make P1.0 and P1.6 output
            mov.b   #0x00,&P1OUT        	; clear output register
            bis.b   #SWITCH,&P1REN			; enable pull-up resistor for P1.3

;------------------------------------------------------------------------------
;   Application Code
;------------------------------------------------------------------------------

;			Status Register
;			Bit  8 7 6 5 4 3 2 1 0
;			Flag V - - - - - N Z C

;					       0 1 2 3  4  5  6 ... 5.000
;			Summenfolge -> 0 1 3 6 10 15 21		BEC5E4

;			sum(0) = 0
;			sum(n) = sum(n-1)+n

			bis.b   #LED_RED,&P1OUT
			jmp		Summe

;------------------------------------------------------------------------------
;   Summe
;------------------------------------------------------------------------------

Summe		mov.w   #0x0000,R6
			mov.w   #0x0000,R7
			mov.w	&input,R5
			mov.w	R5,R6
Sum_Loop	dec.w	R5
			jz		Sum_Finish
			add.w   R5,R6
			jnc		Sum_Loop
			inc.w   R7
			jmp     Sum_Loop

Sum_Finish  mov.w	R6,&result
			jmp     End


;------------------------------------------------------------------------------
;   Multiplikation
;------------------------------------------------------------------------------
Mult		mov.w	&op1_lo,R5
			mov.w	&op2_lo,R6
			mov.w   #0x00,R7
			mov.w   #0x00,R8
Mul_Loop	add.w   R6,R7
			jnc     Mul_carry
			inc.w   R8
Mul_carry   dec.w   R5
			jnz     Mul_Loop
			jmp 	End
			mov.w	R7,&res_lo
			mov.w	R8,&res_hi


;------------------------------------------------------------------------------
;   Ende
;------------------------------------------------------------------------------

End			bic.b   #LED_RED,&P1OUT
			bis.b   #LED_GREEN,&P1OUT
End_Loop	jmp     End_Loop


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
