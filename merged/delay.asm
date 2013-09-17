;standard delay for various functions

kdelay		
			ld bc,$3000			;delay loop to prevent accidental key repeat
kdloop		
			ld hl,$0000				
			push hl
			pop hl
			dec bc
			ld a,b
			or c
			jr nz,kdloop
			ret
