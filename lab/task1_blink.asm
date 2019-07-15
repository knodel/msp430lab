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
;   Blinking LED example for the red LED
;   The delays are realised by two Wait-Loops
;------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430g2231.h"  ; cdecls tells assembler to allow
                                            ; the c header file
COUNT      .equ     0x0004                  ; delay count
;------------------------------------------------------------------------------
;   Main Code
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main                   ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            bis.b   #01000001b,&P1DIR       ; make P1.0 and P1.6 output
            bis.b   #00000001b,&P1OUT
			bic.b   #01000000b,&P1OUT

Mainloop    xor.b   #01000001b,&P1OUT
			call 	#LongWait
			jmp     Mainloop


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
            .short  _main

            .end
