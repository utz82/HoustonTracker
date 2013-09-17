;all the menu functions

dispmenu	
			call csrdel				;delete normal cursor

			set 3,(iy+$05)			;print inverted
			ld de,$1444
			ld hl,menumsg
			xor a
			ld (pbuf),a				;(pbuf) is used to store menu position counter
			call mxpri
			call kdelay
			call kdelay
			
rkmenu		
			ld hl,menumsg			;reset initial string pointer
			ld de,$1444				;reset initial print position
			res 3,(iy+$05)			;printing flag normal
			ld a,%11111100			;mask keys... reading 2 rows *oops
			out (1),a
			in a,(1)				
			bit 6,a					;read CLEAR key
			jr z,menexit			;if it is pressed, quit menu
			bit 3,a					;check if key Up is being pressed
			jr z,mkeyUp
			rra						;check if key Down is being pressed
			jr nc,mkeyDown
			ld a,%10111111
			out (1),a
			in a,(1)
			rra
			jr nc,mkeyM
			jr rkmenu				;continue reading keys
			
menexit		
			call mkdsx
mrexit		
			call csrset				;print normal cursor
			ret						;return to global keyhandler

mkeyM		
			call mhand
			or a
			jr nz,mrexit			;if Jump was executed, return to global keyhandler immediately
			jr mkex					;else, do a short delay and continue reading keys
			
mkeyUp		
			call mkdsx				;delete cursor
			dec a					;decrement cursor position
			cp $ff					;if < 0
			jr nz,mkdsk				;go print
			ld a,6					;else, cursor pos = 6
			jr mkdsk				;go print
			
mkeyDown	
			call mkdsx				;delete cursor
			inc a					;increase cursor position
			cp 7					;if <7
			jr nz,mkdsk				;go print
			xor a					;else, cursor pos = 0, go print
			
mkdsk		
			ld (pbuf),a				;update menu pos buffer
			set 3,(iy+$05)			;print inverted
			call mkdsx				;call printing subroutine
mkex		
			call kdelay
			jr rkmenu				;return to menu keyhandler

mkdsx		
			ld a,(pbuf)				;read menu position buffer
			or a					;if menu pos = 0
			jr z,mxpri				;we already have correct printing pos, so print
			
			push hl					;preserve string pointer		
			ld b,a					;load menu pos to counter
			xor a					;a=0
			ld l,a					;l=0
mlp1		
			add a,6					;
			djnz mlp1				;repeat (menu pos) times
			ld h,a					
			add hl,de				;add offset 
			ex de,hl				;update curor position
			pop hl					;restore string pointer
			ld a,(pbuf)				;read menu pos from buffer
			ld b,a					;load to counter
			xor a					;a=0
mlp2		
			add a,3					;
			djnz mlp2				;repeat (menu pos) times
			ld c,a					;c = offset, b = 0
			add hl,bc				;add offset to string pointer

mxpri		
			call dlmde				;print length-indexed string at pointer
			ld a,(pbuf)				;load menu pos from buffer
			ld hl,menumsg
			ld de,$1444
			ret						;and that's it

;************************************************************************
mhand		
#ifdef TI82
			ROM_CALL(BACKUP_DISP)	;copy current screen to APD_BUF
#else			
			bcall(_savedisp)	;copy current screen to saferam1
#endif			
			call restdisp			;copy APD_BUF to GRAPH_MEM
mhand1		
			ld hl,GRAPH_MEM + 516 + 48
			ld b,12
			ld a,$ff
mllloop		
			ld (hl),a				;draw a line
			inc hl
			djnz mllloop
			ld b,214 -48
			xor a
mblloop		
			ld (hl),a				;blank the lowest two rows
			inc hl
			djnz mblloop
#ifdef TI82		
			call CR_GRBCopy			;... it's time to print the screen
#else
			call ionFastCopy
#endif
mhdqex		
			nop
			
mmkhd		
			ld a,%11111101			;mask keys... 
			out (1),a
			in a,(1)				
			bit 6,a					;read CLEAR key
			jr z,mmexit				;if it is pressed, quit menu
			ld a,%10111111
			out (1),a
			in a,(1)
			rra
			jr nc,mconfirm
			jr mmkhd			

mmexit		
			call restdisp			;restore main view
#ifdef TI82		
			call CR_GRBCopy			;... it's time to print the screen
#else
			call ionFastCopy
#endif
			call kdelay				;wait a bit to prevent accidental keypress
			ld a,$03				;revert potential code modification
			ld (mhxswitch),a
			xor a
			ld (mhxcmode),a			;reset copy mode
			ret						;and back to global keyhandler

mconfirm	
			ld a,(pbuf)				;determine menu position
			ld de,$3201				;setup printing position used by mhexkhd subroutine
			ld (GRAF_CURS),de
			or a					;determine which function to execute
			jr z,mjump
			dec a
			jp z,mcopy
			dec a
			jp z,mcut
			dec a
			jp z,mzap
			dec a
			jp z,mload
			dec a
			jp z,msave
			jp mswap
			
mjump		
			ld hl,menumsg			;jump to line routine - load pointer to "JMP"
			call dlm3				;print it
			ld hl,msto				;load pointer to " TO:"
			call dzmstr				;print it
			ld de,(GRAF_CURS)		;preserve current print pos for mhexkhd
			push de
			ld de,$3801				;go to next line
			ld (GRAF_CURS),de
			ld hl,err3				;load pointer to "[Y=] CONFIRM  [CLEAR] ABORT"
			call dzmstr				;print it
			pop de					;get back our print pos for hex input
mjmpkhd		
			ld a,3					;need to input 3 hex digits
			ld hl,mhxbuf+6
			call mhexkhd			;call hex input routine
			or a					;if it returns with a=0
			jr z,mmexit				;then user pressed [CLEAR]

mjmpinit	
			ld hl,mhxbuf+6
			call hex2ln
			call rowadjust
			ld (sngpnt),hl			;now we know where to jump to in RAM
mjmpexit	
			ld a,$c9				;otherwise
			ld (reswitch),a			;modify code
			ld de,$020e				;preserve cursor position - don't think it's actually necessary
			ld (csrpos),de
#ifdef TI82
				ROM_CALL(CLEAR_DISP)
#else
				bcall(_clrlcdf)
#endif
			call restart			;restart Houston Tracker, thus updating the screen
			xor a					;revert code modification
			ld (reswitch),a
			cpl						;set a=$ff so menu keyhandler knows that it should quit to
			ld (sdend),a			;restore internal end marker
			ret						;main keyhandler

			
mcopy		
			ld hl,menumsg+3
			call dlm3
			ld hl,msfrom
			call dzmstr
			ld de,(GRAF_CURS)		;preserve current print pos for mhexkhd
			push de
			ld a,15
			add a,e
			ld e,a
			ld (GRAF_CURS),de
			ld hl,msto
			call dzmstr
			ld de,$3801				;go to next line
			ld (GRAF_CURS),de
			ld hl,err3				;load pointer to "[Y=] CONFIRM  [CLEAR] ABORT"
			call dzmstr				;print it
			pop de					;get back our print pos for hex input
			ld a,2					;set copy mode
			ld (mhxcmode),a
			ld (mhxccurr),a
			ld a,6					;pass number of digits to input
			ld hl,cmsg2
			ld (cmsgpnt),hl
			ld hl,mhxbuf
			call mhexkhd
			or a
			jp z,mmexit				;return to menu keyhandler if user cancelled action
			ld a,(mhxccurr)
			cp 2
			jp z,mpast
			
minsert		
			ld hl,cmsg3
			call pastprep

			
mimovdat	
			push bc					;move consecutive data down to make room for insert
			push hl
			push de
			
			ccf
			sbc hl,de				;now blk len in hl
			
			ld de,sdend
			dec de
			push de
			ex de,hl				;now blk len in de
			ld (intbuf1),de			;preserve blk end
			ccf
			sbc hl,de				;now start point for move in hl
			pop de
			
mimov		
			ld a,(hl)				;move down byte
			ld (de),a

			xor a					;delete original source
			ld (hl),a				;otherwise inserting w/ muted chans may look weird
			
			push hl
			ccf
			sbc hl,bc
			pop hl

			dec hl
			dec de
						
			jr nc,mimov				;if hl=bc, we're done moving down data
			
			pop de
			pop hl

miblkadj	
			ld a,(mvsect)			;adjust start/end points if source blk was moved
			or a
			jr z,mipast
			ld bc,(intbuf1)
			ex de,hl
			add hl,bc				;add len to hl,de
			ex de,hl
			add hl,bc

mipast		
			pop bc
			ld a,(mvsect)			;the everlasting target row problem
			or a
			jr z,mipstsk
			inc de
			inc hl
mipstsk		
			ex de,hl				;now hl=start pos, de=end pos

			push hl					;paste source to target
			jp mpclpp
			
			
mcut		
			xor a
			ld (mhxcmode),a
			ld hl,menumsg+6
			call dlm3
			ld hl,msfrom
			call dzmstr
			ld de,(GRAF_CURS)		;preserve current print pos for mhexkhd
			push de
			ld a,15
			add a,e
			ld e,a
			ld (GRAF_CURS),de
			ld hl,msto
			call dzmstr
			ld de,$3801				;go to next line
			ld (GRAF_CURS),de
			ld hl,err3				;load pointer to "[Y=] CONFIRM  [CLEAR] ABORT"
			call dzmstr				;print it
			pop de					;get back our print pos for hex input
			ld a,6					;pass number of digits to input
			ld hl,mhxbuf
			call mhexkhd
			or a
			jp z,mmexit
			ld hl,mhxbuf
			call hex2ln				;now start pos is in hl
			push hl
			ld hl,mhxbuf+3
			call hex2ln				;now end pos is in hl
			pop de					;start pos is in de
			
			xor a					;signal mode to error trap
			call etrap				;check for errors
			or a
			jp z,mmexit				;abort if error found
			
			call rowadjust
			
			ld bc,$0005
			add hl,bc
			push de
mccutlp		
			ld a,(hl)
			ld (de),a
			inc hl
			inc de
			cp $ff
			jr nz,mccutlp
mccutlp2	
			ld a,(de)
			cp $ff
			jr z,mccskp1
			xor a
			ld (de),a
			inc de
			jr mccutlp2
mccskp1		
			xor a
			ld (de),a
			pop hl
			jp mjmpinit

mpast		
			ld hl,cmsg2
			call pastprep
			ex de,hl				;now hl=start pos, de=end pos
			push hl

			
mpclpp		
			exx						;to register set 2
			ld b,5					;counter to b'
			ld a,(chmask)			;channel mute mask to c'
			ld c,a
			exx						;back to primary reg.set
mpclpp0		
			ld hl,sdend
			ccf
			sbc hl,bc				;check if end of data block has been reached
			jr c,mpdone				;if so, abort pasting
			pop hl
			
			exx						;to reg.set 2
			srl c					;check if channel is muted
			jr c,mpcrev				;if carry is set (= ch muted), continue without copying data bytes
			dec b					;else, count down
			jr nz,mpcms0			;if 5 bytes have been copied
			ld b,5					;restore counter in b'
			ld a,(chmask)			;restore chmask in c'
			ld c,a
			
mpcms0		
			exx						;back to primary reg.set
			ld a,(hl)				;copy data byte
			ld (bc),a
mpcmskp		
			inc hl					;increment pointers
			inc bc
			push hl
mcpsw .EQU $				
			inc hl					;self-modifying, skip inc hl ($23) after copy w/ muted chans
			ccf
			sbc hl,de				;check if end of copy block reached
			jr nc,mpdone
			jr mpclpp0				;if not, continue copying stuff
mpdone		
			pop hl
			jp mjmpinit

mpcrev		
			dec b					;same as above, but skips copying
			jr nz,mpcrev0
			ld b,5
			ld a,(chmask)
			ld c,a
mpcrev0		
			exx						;back to primary reg.set
			jr mpcmskp

	
mload		
			ld a,(slottab)			;check if at least one saveslot exists
			or a
			jr z,mdelx				;if not, abort			
			xor a
			call ldsav
			ld a,$c9				;modify code
			ld (reswitch),a
			jp mxrest2				;and restart Houston Tracker

msave		
			ld a,1
mlsj		
			call ldsav
mdelx		
			call restdisp
			jp mmexit				;and we're done

mswap		
			ld a,(slottab)			;check if at least one saveslot exists
			or a
			jr z,mdelx				;if not, abort
			ld a,2
			jr mlsj

mzap		
			ld hl,menumsg+9			;point to "ZAP"
			call dlm3				;print it
			ld hl,msall				;point to " ALL"
			call mxsetup			;print the usual crap and modify hex keyhandler
			call mhexkhd			;call hex keyhandler (which now just reads [Y=] and [CLEAR]
			or a					;check if user pressed [CLEAR]
			jp z,mmexit				;if so, exit to menu keyhandler
			ld a,$03				;revert code modification
			ld (mhxswitch),a
mzapx		
			ld a,$c9				;modify code
			ld (reswitch),a
			ld a,$ff				;put an end marker at the start of the song data
			ld c,0
			ld hl,sdata
			ld (hl),a
mzxloop		
			inc hl					;increase pointer
			ld b,(hl)				;look up value at pointer
			ld (hl),c				;write a $00 byte at pointer
			cp b					;check if we have reached an end marker
			jr z,mxrest				;if so, restart Houston Tracker
			jr mzxloop				;if not... we gotta copy some more 0s
			
mxrest		
			ld hl,sdend				;restore permanent end marker
mxrest1		
			ld (hl),a
mxrest2		
			call init				;restart Houston Tracker
			ld a,$00				;revert code modification
			ld (reswitch),a
			cpl						;set a=$ff so menu keyhandler knows it should exit to main keyhandler
			ret						;and that's that.
						
restdisp	
			ld bc,768				;copy APD_BUF to GRAPH_MEM
			ld hl,APD_BUF
			ld de,GRAPH_MEM
			ldir
			ret

mxsetup		
			call dzmstr		;print whatever was pointed to
mxsetup2	
			ld de,$3801				;set print position to last line
			ld (GRAF_CURS),de		
			ld hl,err3				;point to "[Y=] CONFIRM  [CLEAR] ABORT"
			call dzmstr		;print it
			ld a,$ea				;modify hex input keyhandler so it only reads [Y=] and [CLEAR]
			ld (mhxswitch),a
			xor a
			ret

holdlp		
			push af					;row holding for engines
holdllp		
			xor a						;keyhandler
			out (1),a					;mask port with 0
			in a,(1)					;read MODE key
			cpl
			or a
			jr nz,holdllp
			pop af
			ret
			
derowlp		
			dec hl						;row looping for engines
			dec hl
			dec hl
			dec hl
			dec hl
			ret
			
rowadjust	
			push hl						;pointer adjustment for copy/cut
			push bc
			call chkstart
			ld (sngpnt),hl
			xor a
			ld (colval),a
			pop bc
			pop hl
			ret

pastprep	
			push hl						;preparations for copy/paste
			call kdelay
			pop hl
			ld de,$3201
			call dlmde
			ld hl,msat
			call dzmstr
			ld de,(GRAF_CURS)
			push de
			ld b,70
mpcllp		
			ld a,$20
			call mcharput
			djnz mpcllp
			ld a,3
			ld hl,mhxbuf+6
			pop de
			ld (GRAF_CURS),de
			call mhexkhd
			or a
			jp z,mmexit
			
			ld hl,mhxbuf
			call hex2ln				;now start pos is in hl
			push hl
			ld hl,mhxbuf+3
			call hex2ln				;now end pos is in hl
			push hl
			ld hl,mhxbuf+6
			call hex2ln
			ld b,h					;now target pos is in hl
			ld c,l					;put it in bc
			pop hl
			pop de					;start pos is in de

			xor a					;signal mode to error trap
			cpl
			call etrap				;check for errors
			or a
			jp z,mmexit				;abort if error found
			
			call rowadjust

			inc hl
			inc hl
			inc hl
			inc hl
			inc hl
			ret

msgsetu		
			call dlm3				;print it
			call mxsetup2			;print the usual crap and modify hex keyhandler
			call mhexkhd			;call hex keyhandler (which now just reads [Y=] and [CLEAR]
			or a					;check if user pressed [CLEAR]
			ret
