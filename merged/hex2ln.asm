;convert 3 ascii digits to memory location
;in: hl - pointer to ascii digits
;out: hl - memory location
;destroyed: af,de

			push hl					;convert 3 ascii digits to memory location
			ld a,(hl)				;get our 12-bit value into hl
			ld d,a					;1st and 3rd digit are simple enough
			inc hl
			inc hl
			ld a,(hl)
			ld e,a
			dec hl
			ld a,(hl)				;the 2nd digit needs to be shifted to the upper nibble
			sla a
			sla a
			sla a
			sla a
			add a,e
			ld e,a

			ld hl,MAXL

			ccf						;?
			sbc hl,de				;check if user is trying to jump to a higher line
			jr nc,mxx1				;if not, proceed

			ld de,MAXL
		
			ld a,d
			pop hl
			push hl
			ld (hl),a			;correct hex digits in buffer, or we'll get 
			dec a					;strange characters the next time user tries to jump
			inc hl
			inc hl
			ld (hl),a
			ld a,$0c
			dec hl
			ld (hl),a
mxx1			pop hl
			ld h,d					;now multiply row number by 5
			ld l,e
			add hl,hl
			add hl,hl
			add hl,de
			ld de,sdata
			add hl,de				;and add the starting position of the data block
			ret