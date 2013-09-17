;determine row start in data

chkstart	
			ld a,(colval)			;load current column value
			bit 0,a
			jr z,chk1
			dec a
chk1		
			srl a				;divide by 2
			ld c,a				;preserve in c
			ld b,0				;clear b (just to be sure)
			ld hl,(sngpnt)			;load current pointer to song data
			ccf				;?
			sbc hl,bc			;subtract colval/2
			inc hl				;?
			ret
