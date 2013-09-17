;print one line of song data

newline		
			push de
			call chkstart
			ld (intbuf1),hl		;store temporary song data pointer
			ccf
			ld de,sdata			;load song data start position
			sbc hl,de			;subtract it from current song data position
			inc hl				;adjust +1

skipnl		
			call linediv		;now bc holds the actual line #

			ld a,b				;convert MSB to character code
			call num2hex		;and store in text buffer
			pop de				;retrieve printing position
			ld (GRAF_CURS),de
			push de
			call nfmch			;display MSB of row number
			pop de
			ld a,4				;adjust printing position for next output
			add a,e
			ld e,a
			ld a,c				;convert LSB of row number to character code
nlinitx		
			push de				;preserve printing position
			call num2hex
			pop de				;retrieve printing positon
			call nfstde			;display LSB of row number
			ld a,10				;adjust printing position for next output
			add a,e
			ld e,a
			ld (GRAF_CURS),de
			push de				;preserve printing position
			ld hl,(intbuf1)		;retrieve temporary song data pointer

nlinit0		
			ld b,5				;load loop counter to print five columns
nlinit1		
			ld a,(hl)			;load note byte
			call num2hex		;convert to hex
			pop de				;setup print pos
			ld (GRAF_CURS),de
			ld a,10				;update print pos for next output
			add a,e
			ld e,a
			push de				;preserve print pos
			push hl				;preserve song data pointer
			call nfstr			;print note value on screen
			pop hl				;restore song data pointer
			inc hl				;increase it
			djnz nlinit1		;repeat until 5 columns have been printed
			
			pop de				;clean up stack
			ret

nlinity		
			push de
			jr nlinit0