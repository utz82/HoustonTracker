;main screen initialization

init
#ifdef TI82
				ROM_CALL(CLEAR_DISP)
#else
				bcall(_clrlcdf)
#endif

			xor a			;clear buffers and pointers
			ld b,14
			ld hl,intbuf1
clrploop	
			ld (hl),a
			inc hl
			djnz clrploop
			
			inc hl
			ld (hl),$0e		;setup initial cursor position
			inc hl
			ld (hl),$02

			ld hl,sdata		;initialize pointer to song data position
			ld (sngpnt),hl		;internal pseudo-interrupt restart point
restart		
			ld de,$0240		;print SPEED display
			ld (GRAF_CURS),de	;setup print position
			ld hl,spdmsg
			call dzmstr		;display "SPEED"
			ld de,$0840		;print ENGINE display
			ld (GRAF_CURS),de	;setup print position
			ld hl,engmsg
			call dzmstr		;display "ENGINE"
			ld de,$0e40		;print channel mute display
			ld hl,chnmsg
			call dlmde		;display "CH "
			ld a,(chmask)
			call chmaskp
			
			ld a,(spdpnt)		;load speed value
			call num2hex		;convert to character codes and store in (numfld)
			ld de,$0257		;setup print pos
			call nfstde		;display speed value
			
			ld a,(engpnt)		;load engine value
			call num2hex		;convert to character codes and store in (numfld)
			ld de,$085b		;setup print pos
			ld (GRAF_CURS),de	
			call nfmch
			
setmenu		
			ld de,$1444		;setup print pos
			ld c,7			;setup loop counter
			ld hl,menumsg
dmloop		
			ld a,6			;setup print adjustment
			call dlmde		;print length-indexed string
			add a,d			;update it
			ld d,a
			dec c			;printing 7 lines, count down
			jr nz,dmloop

			ld de,$0200		;setup print pos for pattern matrix
			push de			;preserve it
			ld hl,(sngpnt)
			
			ld c,10			;counter for screen printing, printing 10 rows
			
scrinit0
						;calculate row numbers from position in song data
			ld (intbuf1),hl		;store temporary song data pointer

			push bc			;store loop counter
			ccf
			ld bc,sdata		;load song data start position
			sbc hl,bc		;subtract it from current song data position
			inc hl			;adjust +1

skip3		
			call linediv
			ld h,b				;now bc holds the actual row number
			ld l,c				;transfer it to hl

			pop bc				;restore loop counter (held in c)
			ld b,l
			ld a,h				;convert MSB to character code
			call num2hex		;and store in text buffer
			pop de				;retrieve printing position
			ld (GRAF_CURS),de
			ld hl,numfld+1    	;point to text buffer
			call dzmstr  		;display MSB of row number
			ld a,4				;adjust printing position for next output
			add a,e
			ld e,a
			ld a,b				;convert LSB of row number to character code

			call nlinitx		;print 1 row of song data

			ld a,6				;update cursor position for next row
			add a,d
			ld d,a
			ld e,0
			push de
			dec c				;decrease row print counter
			jr nz,scrinit0		;repeat until 10 rows have been printed
			
			pop de				;clean stack
reswitch	
			nop					;self-modifying switch, set to ret after internal restart
