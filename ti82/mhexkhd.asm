;Routine for handling hex input in menu functions
;Input: (# of hex digits to input) in a, print coords in de
;		first value to edit in hl
;		copy/cut mode in (cmsgpnt)
;Return: Exit status in a, (1..3)*3 nibbles (aka 12-bit values) in mhxbuf
;Exit status: 0 - CLEAR pressed, 1/$ff - OK, 2 - Input Error

mhxkh		or a					;check how many digits to input
			jr z,mhxinit			;if none, skip digit input routine
			dec a
			ld (mhxRrs),a			;modify code as needed
			inc a
			ld (mhxpbuf),hl
			ld c,0					;c holds cursor position
			push bc
			set 3,(iy+$05)			;print inverted
			inc e					;need a bit of extra space
			ld (GRAF_CURS),de
			push de					;preserve print pos
			ld c,a					;(# of digits) to input to c
			;ld hl,mhxbuf
			ld a,(hl)				;check what's up in our hex nibble buffer
			add a,$30				;first nibble is always in range 0-7
			call mcharput		;so simply add $30 to get ascii code
			res 3,(iy+$05)			;print normal
			ld b,2
mhxplp		inc hl
			ld a,(hl)				;look up second nibble
			call num2hex			;convert it to ascii
			;ld a,(numfld+1)
			call nfmch
			djnz mhxplp
			ld a,c
			cp 6
			jr nz,mhxss1
			ld de,(GRAF_CURS)
			ld a,14
			add a,e
			ld e,a
			ld (GRAF_CURS),de
			ld b,3
mhxplp2		inc hl
			ld a,(hl)
			call num2hex
			;ld a,(numfld+1)
			call nfmch
			djnz mhxplp2
			ld de,$3253
			ld (GRAF_CURS),de
			ld a,(mhxcmode)
			or a
			jr z,mhxss1
			ld hl,(cmsgpnt)
			;ld b,3
			call dlm3

mhxss1		pop de					;restore print pos
			pop bc
			;ld hl,mhxbuf			;point to first nibble
			ld hl,(mhxpbuf)
			
mhxinit		ld a,%11111101			;mask keys...
			out (1),a
			in a,(1)				
			bit 6,a					;read CLEAR key
			jr nz,mhx1				;if it is pressed, quit to menu
			xor a
			ret
mhx1		ld a,%10111111			;mask keys...
			out (1),a
			in a,(1)
			bit 4,a					;read Y= key
mhxswitch .EQU $+1					;self-modifying, when hex input is not required,
			jr nz,mhx2				;jump to mhxinit instead. Values: mxh2 $03, mhxinit $ea 
			ld a,1
			ret
			
mhx2		ld a,%10111111			;mask keys...
			out (1),a
			in a,(1)
			bit 1,a					;read TRACE key
			jp z,mhxcmosw

			ld a,%11111110			;mask keys
			out (1),a
			in a,(1)				;read arrow keys
			rra
			jr nc,mhxDown
			rra
			jr nc,mhxLeft
			rra
			jr nc,mhxRight
			rra
			jr nc,mhxUp

mhxf		jr mhxinit				;if no key was pressed, continue reading keys

mhxDown		ld a,(hl)				;look up nibble at pointer
			or a
			jr z,mhxRex				;if it is 0, exit to keyhandler
			dec a					;decrease nibble value
			jr mhxxs				;and let the "key Down" routine do the rest
			
mhxUp		ld a,(hl)				;look up nibble at pointer
			cp $0f					;check if it happens to be $f
			jr z,mhxRex				;if so, exit to keyhandler
			inc a					;increase nibble value
mhxxs		ld (hl),a				;write it to buffer
			jr mhxxs3				;let the "key Right" routine do the rest
			
mhxLeft		ld a,c					;check if we're at the first digit
			or a
			jr z,mhxRex				;if so, ignore keypress and return to keyhandler
			call mhxcsrp			;otherwise, delete cursor
			push af					;dafuq??? no critical registers are changed in the following section,
									;but it'll print garbage on the first digit if af isn't preserved
			ld a,c
			cp 3					;check if we're jumping from "block end" to "block start" section
			jr nz,mhxLnos
			ld de,(GRAF_CURS)		;if yes, update GRAF_CURS
			ld a,e
			sub 14
			ld e,a
			ld (GRAF_CURS),de
mhxLnos		pop af
			dec c					;decrease digit #
		    ld hl,(mhxpbuf)			;point to nibble buffer
			or c					;if we're now at the first nibble
			jr z,mhxLx0				;then hl already points to the correct location
			ld b,c					;otherwise, load counter with # of digit to print cursor at
mhxLlp		inc hl					;calculate the pointer position
			djnz mhxLlp
mhxLx0		ld de,(GRAF_CURS)		;look up current cursor position
			ld a,e
			sub 8					;shift left 8 pixels...
			ld e,a					;...because GRAF_CURS points to the position after the cursor right now
			jr mhxxs3				;let the "key Right" routine do the rest

mhxRight	ld a,c					;check if we're at the last digit
mhxRrs .EQU $+1
			cp 2					;self-modifying
			jr z,mhxRex				;if so, ignore keypress and return to keyhandler
			call mhxcsrp			;otherwise, delete cursor
			ld a,c
			cp 2					;check if we're jumping from "block start" to "block end" section
			jr nz,mhxRnos
			ld de,(GRAF_CURS)		;if yes, update GRAF_CURS
			ld a,14
			add a,e
			ld e,a
			ld (GRAF_CURS),de
mhxRnos		inc c					;increase digit #
		    ld hl,(mhxpbuf)			;point to nibble buffer
			ld b,c					;load counter with # of digit to print cursor at
mhxRlp		inc hl					;calculate pointer position
			djnz mhxRlp				
			ld de,(GRAF_CURS)		;GRAF_CURS already points to the right position
mhxxs3		set 3,(iy+$05)			;print inverted
			call mhxcsrp			;print cursor
mhxRex0		res 3,(iy+$05)			;print normal
			push hl					;delay a bit to prevent accidental key repeat
			push bc
			call kdelay
			pop bc
			pop hl
mhxRex		jr mhxf					;and that's all

mhxcsrp		push de					;preserve print position
			ld (GRAF_CURS),de
			ld a,(hl)				;load byte
			add a,$30				;adjust to Ascii
			ccf
			cp $3a					;if nibble was $a or more...
			jr c,mhxcsrpp
			add a,$07				;... adjust once more
mhxcsrpp	call mcharput		;print nibble + cursor
			pop de					;restore print position
			ret						;and we're done

mhxcmosw	push bc
			ld a,(mhxcmode)		;check copy mode
			or a
			jr z,mhxcm2			;if mode = 0, return to menu keyhandler
			push de
			push hl
			ld a,(mhxccurr)		;read current mode
			cp 2
			jr nz,mhxcmsk		;if it's 2
mhxcmsk2b	inc a				;raise it to 3
			ld hl,cmsg3			;point to "INS"
			jr mhxcmsk2			;continue with updating stuff
mhxcmsk		dec a				;lower it to 2
mhxcmsk2a	ld hl,cmsg2			;point to "PST"
mhxcmsk2	ld (mhxccurr),a		;update current mode pointer
			ld (cmsgpnt),hl		;update message pointer
			ld de,$3253			;setup print position
			;ld (GRAF_CURS),de	;and print whatever needs to be printed
			;ld b,3
			call dlmde
			call kdelay
			pop hl
			pop de			
mhxcm2		pop bc
			jp mhxinit			

mhxcmode	nop
mhxccurr	nop			
mhxpbuf		nop
			nop
mhxbuf		nop						;buffer for data block start pointer
			nop
			nop
mhxbuf2		nop						;buffer for data block end pointer
			nop
			nop
mhxbuf3		nop						;buffer for target row # pointer
			nop
			nop
