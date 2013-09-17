;main keyhandler

readkeys	
			ld a,%11011111		;mask keys
			out (1),a
			in a,(1)			;read keyboard
			rra
			rra
			jp nc,keySto
			rra
			jp nc,keyLn
			rra
			jp nc,keyLog
			rra
			jp nc,keyMute
			rra
			jp nc,keyD
			rra
			jp nc,keyA

			ld a,%11101111
			out (1),a
			in a,(1)
			rra
			jp nc,key0
			rra
			jp nc,key1
			rra
			jp nc,key4
			rra
			jp nc,key7
			rra
			rra
			jp nc,keyE
			rra
			jp nc,keyB
			
			ld a,%11110111
			out (1),a
			in a,(1)
			rra
			jp nc,keyDot
			rra
			jp nc,key2
			rra
			jp nc,key5
			rra
			jp nc,key8
			rra
			rra
			jp nc,keyF
			rra
			jp nc,keyC

			ld a,%11111011
			out (1),a
			in a,(1)
			rra
			jp nc,keyNeg
			rra
			jp nc,key3
			rra
			jp nc,key6
			rra
			jp nc,key9
			
			ld a,%11111101
			out (1),a
			in a,(1)
			rra
			jp nc,keyEnter
			rra
			jp nc,keyPlus
			rra
			jp nc,keyMinus
			rra
			jp nc,keyMult
			rra
			jp nc,keyDiv
			
			ld a,%11111110
			out (1),a
			in a,(1)
			rra
			jp nc,keyDown
			rra
			jp nc,keyLeft
			rra
			jp nc,keyRight
			rra
			jp nc,keyUp

			ld a,%10111111			
			out (1),a
			in a,(1)				
			rra
			jp nc,keyMenu			;read GRAPH key
			rra
			jp nc,keyTrace
			rra
			jp nc,keyZoom
			rra
			jp nc,keyQcut			;read WINDOW key
			rra
			jp nc,keyQcopy			;read Y= key
			rra
			rra
			ret nc					;if MODE key is pressed, exit
			
			jp kskip1				;

			
keyD		
			ld a,$0d				;assign hex values
			jr imputjmp
keyA		
			ld a,$0a
			jr imputjmp
key0		
			xor a
			jr imputjmp
key1		
			ld a,$01
			jr imputjmp
key4		
			ld a,$04
			jr imputjmp
key7		
			ld a,$07
			jr imputjmp
keyE		
			ld a,$0E
			jr imputjmp
keyB		
			ld a,$0B
			jr imputjmp
key2		
			ld a,$02
			jr imputjmp
key5		
			ld a,$05
			jr imputjmp
key8		
			ld a,$08
			jr imputjmp
keyF		
			ld a,$0f
			jr imputjmp
keyC		
			ld a,$0c
			jr imputjmp
key3		
			ld a,$03
			jr imputjmp
key6		
			ld a,$06
			jr imputjmp
key9			ld a,$09
			
imputjmp	
			jp inputv

keySto		
			call rowtrns
			ld hl,mhxbuf+6
			jr keyLcp

keyLn		
			call rowtrns
			ld hl,mhxbuf+3
			jr keyLcp

keyLog		
			call rowtrns
			ld hl,mhxbuf
keyLcp		
			call copynum
			jr kskip2

rowtrns		
			push de
			call chkstart
			ld (intbuf1),hl		;store temporary song data pointer
			
			ccf
			ld de,sdata			;load song data start position
			sbc hl,de			;subtract it from current song data position
			inc hl				;adjust +1

			call linediv		;now bc holds the actual line #
			pop de
			ret
			
copynum		
			ld a,b
			ld (hl),a
			inc hl
			ld a,c
			srl a
			srl a
			srl a
			srl a
			ld (hl),a
			inc hl
			ld a,c
			or $f0
			xor $f0
			ld (hl),a
			ret
			
keyNeg		
			call chkstart			;play from position
			jr cplay
			
keyDot		
			call chkstart			;play current row
			ld de,pbuf				;load pointer to temporary player buffer
			ld b,5
			ld a,(chmask)
			ld c,a
chmtsk0		
			srl c
			jr nc,chmtsk1
			xor a
			jr chmtsk2
chmtsk1		
			ld a,(hl)
chmtsk2		
			ld (de),a
			inc de
			inc hl
			djnz chmtsk0
			ld hl,pbuf
			ld a,$c9
			ld (pex),a
			ld (t5pex),a
			ld (t7pex),a
			jr cplay
keyEnter							;play from start
			ld hl,sdata

cplay		
			ld a,(hl)
			cpl
			or a
			jr z,cpskp
			ld a,(engpnt)
			dec a
			call z,player
			dec a
			call z,player2
			dec a
			call z,player3
cpskp		
			ld a,$c0				;revert code modifications
			ld (pex),a
			xor a
			ld (t5pex),a
			ld (t7pex),a

kskip1		
			call csrset
kskip2		
			jp readkeys

keyDown		
			call csrdel
			call rowinc
			jr kskip1				;print cursor
keyUp		
			call csrdel
			call rowdec
			jr kskip1
keyLeft		
			call csrdel
			ld a,(colval)			;check what column is currently active
			or a					;if it is the leftmost column...
			jr z,kskip1				;... ignore keypress
			rra						;if it is an even column...
			call nc,dcoldec			;... shift cursor an extra 2 pixels and switch column
			call coldec				;update cursor position
			jr kskip1
keyRight	
			call csrdel
			ld a,(colval)			;check what column is currently active
			cp 9					;if it is the rightmost column...
			jr z,kskip1				;... ignore keypress
			rra						;if it is an odd column...
			call c,dcolinc			;... shift cursor an extra 2 pixels and switch column
			call colinc				;update cursor position
			jr kskip1
			
keyPlus		
			ld a,(spdpnt)			;increase speed value
			cp $fe
			jr z,ppret
			inc a
			ld (spdpnt),a
ppret		
			jr pmret

keyMinus	
			ld a,(spdpnt)			;decrease speed value
			dec a					;if a=1
			jr z,qret				;do nothing
			ld (spdpnt),a
pmret		
			ld bc,(numfld)
			res 3,(iy+$05)
			call num2hex
			ld de,$0257
			call nfstde				;display new speed value
			ld (numfld),bc
			call kdelay
			set 3,(iy+$05)
qret		
			jp readkeys

keyMult		
			ld a,(engpnt)
			cp 3
			jr z,kddret
			inc a
			ld (engpnt),a
			jr kddret
keyDiv		
			ld a,(engpnt)
			cp 1
			jr z,kddret
			dec a
			ld (engpnt),a
kddret		
			ld bc,(numfld)
			res 3,(iy+$05)
			call num2hex
			ld de,$085b
			ld (GRAF_CURS),de	
			call nfmch
			ld (numfld),bc
			call kdelay
			set 3,(iy+$05)
			jr keymenx

keyMenu			call dispmenu
keymenx			jp readkeys

keyZoom		
			call chkstart			;copy current row to buffer
			ld de,pbuf				;load pointer to temporary player buffer
			ld bc,$0005				;loop counter
			ldir
			jr keymenx

keyTrace	
			call chkstart
			push hl
			ld de,pbuf
			ex de,hl
			ld bc,$0005				;loop counter
			ldir
			ld de,(GRAF_CURS)
			ld e,14
			ld (GRAF_CURS),de
			res 3,(iy+$05)
			pop hl
			call nlinity
			jr keymenx

keyQcopy	
			call qinit
			call kdelay
			call mcopy
			jr keymenx

keyQcut		
			call qinit
			call mcut
			jr keymenx
			
keyMute		
			ld a,(colval)			;check current cursor position
			ld c,$01				;mask for xor'ing against channel mute mask (chmask)
			srl a					;colval/2 = data column currently being edited
			jr z,kmsx
			
kmloop		
			sla c					;rotate mask
			dec a
			jr nz,kmloop
			
kmsx		
			ld a,(chmask)
			xor c
kmsret		
			call chmaskp
			call kdelay
			call kdelay
			jp readkeys

chmaskp		
			ld (chmask),a
			ld hl,chnmsg+3
			ld de,$0e4b
			ld (GRAF_CURS),de
			ld b,5
kmploop		
			set 3,(iy+$05)			;print inverse
			srl a
			call c,kmswitch
			push af
			ld a,(hl)
			call mcharput
			pop af
			inc hl
			djnz kmploop	
kmswitch	
			res 3,(iy+$05)
			ret		
			
qinit		
			ld a,$c9				;modify code, so we can call mhand instead of jumping to it
			ld (mhdqex),a
			call mhand
			xor a
			ld (mhdqex),a			;revert code modification
			res 3,(iy+$05)
			ld de,$3201				;setup printing position used by mhexkhd subroutine
			ld (GRAF_CURS),de
			ret
