;Divide hl by 5, place result in bc

divhl5		push hl
			xor a
			ld bc,$1005

dvloop		add	hl,hl
			rla
			cp c
			jr c,$+4
			sub	c
			inc	l
			djnz dvloop
			
			ld b,h
			ld c,l
			pop hl
			ret