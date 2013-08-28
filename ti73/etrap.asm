;the error trapping subroutine
;in: 	a - 0 if checking for cut, !0 when checking for copy
;		hl - block end
;		de - block start
;		bc - target
;out: 	a - !0 if ok, 0 when error found
;destroyed: af

etinit		or a
			jr z,echk4
			
echk1		xor a
			ld (mvsect),a
			push hl					;check if target is within source block	
			push de
			ex de,hl		
			ccf
			sbc hl,bc
			pop de
			pop hl
			jr c,echk1a
			xor a					;if bc < de
			cpl
			ld (mvsect),a			;set switch
			jr echk4				;check is passed
echk1a		push hl
			push de
			ccf
			sbc hl,bc
			pop de
			pop hl
			jr nc,eerr1

echk4		push hl					
			ccf
			sbc hl,de				;if (end pos)<=(start pos), we have an error
			pop hl
			jr c,eerr4

		
eok			xor a					;signal back with non-zero value in a
			cpl
			ret						;and we're done here
			

eerr1		call errstd
			ld hl,err2e				;load pointer to "target w/in source"
			jr errwait			
			
eerr4		call errstd
			ld hl,err2d				;load pointer to "end <= start"
						
errwait		call dzmstr		;print message
			ld b,$0c				
errwl		push bc					;display error message for 2 seconds or so
			call kdelay
			pop bc
			djnz errwl
			xor a
			ret
			
errstd		ld a,$c9				;modify code
			ld (mhdqex),a
			ld de,$3201				;setup printing position used by mhexkhd subroutine
			ld (pencol),de
			call mhand1
			xor a
			ld (mhdqex),a			;revert code modification
errsm		ld hl,err1				;load pointer to "FAIL: "
			call dzmstr		;print it
			ret

mvsect .EQU $						;switch to signal if target < blk start
			nop