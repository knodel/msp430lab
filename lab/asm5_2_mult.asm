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

MPY 		.equ 0x130 ; Multiply unsigned
MPYS 		.equ 0x132 ; Multiply signed
MAC 		.equ 0x134 ; Multiply�and�Accumulate
OP2 		.equ 0x138 ; Operand 2 Register

SumLo 		.equ 0x013A ; Result Register LSBs 15..0
SumHi 		.equ 0x013C ; Result Register MSBs 32..16
SumExt 		.equ 0x013E ; Sum Extension Register 47..33


;------------------------------------------------------------------------------
;   Data segment
;------------------------------------------------------------------------------

      		.data

;------------------------------------------------------------------------------
;   Initialization
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

op1			.word 	0x0014
op2			.word   0x0009
result      .word   0x0000

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

;					       0 1 2 3  4  5  6 ...
;			Summenfolge -> 0 1 3 6 10 15 21

;			sum(0) = 0
;			sum(n) = sum(n-1)+n

Mainloop	bis.b   #LED_RED,&P1OUT
			mov.w   &op1, R5
			mov.w   &op2, R6
			mov.w   #0x00, &0x013A
			mov.w   #0x00, &0x138
			mov.w	&0x013A, R7
			mov.w	&0x013C, R8



Finished    mov.w	R7,&result
			bic.b   #LED_RED,&P1OUT
			bis.b   #LED_GREEN,&P1OUT
End			jmp     End


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
