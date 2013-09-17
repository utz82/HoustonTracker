;hexadecimal input handler

inputv		
			ld d,a					;input hex nibble
			push de
			call csrdel				;delete cursor
			pop de
			ld a,(colval)			;check row pos
			rra						;check if we're at an odd or even row
			jr c,input1				;odd rows will have bit 0 set
			ld a,(hl)				;load song data byte (csrdel updates hl)
			or $f0					;clear upper nibble
			xor $f0
			ld e,a					;preserve in e
			ld a,d					;load inputval
			add a,a					;shift to upper nibble
			add a,a
			add a,a
			add a,a
			jr inputf

input1		
			ld a,(hl)				;load pointer
			or $0f					;clear lower nibble
			xor $0f
			ld e,a					;preserve in e
			ld a,d					;load inputval

inputf		
			add a,e						
			ld (hl),a				;load data pointer with new value
			call num2hex

rowswitch	
			ld a,(colval)			;update row value pointer
			rra
			jr nc,norowup
			ld hl,(csrpos)
			ld (GRAF_CURS),hl		;and update the screen while we're at it
			call nfmch			
			call coldec
			call rowinc
rowf		
			call csrset
			call kdelay
			call kdelay
			jp readkeys
norowup		
			ld hl,(csrpos)
			ld (GRAF_CURS),hl
			ld a,(numfld)    		;Offset of the string
			call mcharput 			;Display the string
			call colinc
			jr rowf

dcolinc		
			ld a,(csrpos)
			add a,2
			ld (csrpos),a
			ld hl,(sngpnt)			;
			inc hl
			jr dcex
			
colinc		
			ld a,(csrpos)
			add a,4
			ld (csrpos),a
			ld a,(colval)
			inc a
			jr cex
			
dcoldec		
			ld a,(csrpos)			;look up current cursor position
			sub 2					;shift left 2 pixels
			ld (csrpos),a			;update cursor position
			ld hl,(sngpnt)			;update song data pointer
			dec hl
dcex		
			ld (sngpnt),hl
			ld a,(hl)				;
			call num2hex			;
			ret
			
coldec		
			ld a,(csrpos)
			sub 4
			ld (csrpos),a
			ld a,(colval)
			dec a
cex			ld (colval),a
			ret
			
rowinc		
			ld a,(csrpos+1)			;look up current cursor position
			cp 56					;see if we have reached the bottom of the screen
			jr nz,rskip1
			call scrlup				;if so, scroll
			ret

rskip1		
			add a,6					;update cursor position
			ld (csrpos+1),a
			ld hl,(sngpnt)			;update song data pointer
			ld de,$0005
			add hl,de
			ld (sngpnt),hl
			ret

rowdec		
			ld a,(csrpos+1)			;look up current cursor position
			cp $02					;see if we have reached the top the screen
			jr nz,rskip2
			call scrldown
			ret
			
rskip2		
			sub 6					;update cursor position
			ld (csrpos+1),a
			ld hl,(sngpnt)			;update song data pointer
			ld de,$0005
			sbc hl,de
			ld (sngpnt),hl
			ret			
