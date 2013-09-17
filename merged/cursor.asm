;cursor printing

csrset		
			set 3,(iy+$05)			;print inverted
			call kdelay
			jr csrprint
csrdel		
			res 3,(iy+$05)			;print normal
csrprint	
			ld hl,(sngpnt)
			ld a,(hl)				;restore from cursor
			call num2hex
			ld de,(csrpos)
			ld (GRAF_CURS),de
			ld a,(numfld)
			ld b,a
			ld a,(colval)
			rra						;;check if we're at an odd or even row
			jr nc,csrf
			ld a,(numfld+1)			;if we're at an odd row, load char code of 2nd nibble
			ld b,a
csrf			ld a,b
			call mcharput
			ret
