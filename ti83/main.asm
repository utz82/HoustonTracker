#define TI83
;#define LIGHT					;uncomment this if you want to compile the "light" version
#nolist
#include ion.inc
#list
	.ORG	progstart
	xor a
	jr	nc,begin
	ret


.DB "houstontracker 0.3", 0
#define .db .byte
#define .dw .word

begin		
			push ix
			ld (sbuf),sp
			call init
			ld sp,(sbuf)
			pop ix
			res 3,(iy+$05)			;print inverted
			ret

;***********************************************************************************
;Setting up the initial screen
;***********************************************************************************			
			
init		bcall(_clrlcdf)

			xor a				;clear buffers and pointers
			ld b,14
			ld hl,intbuf1
clrploop	ld (hl),a
			inc hl
			djnz clrploop
			
			inc hl
			ld (hl),$0e			;setup initial cursor position
			inc hl
			ld (hl),$02

			ld hl,sdata			;initialize pointer to song data position
			ld (sngpnt),hl		;internal pseudo-interrupt restart point
restart		ld de,$0240			;print SPEED display
			ld (pencol),de	;setup print position
			ld hl,spdmsg
			call dzmstr			;display "SPEED"
			ld de,$0840			;print ENGINE display
			ld (pencol),de	;setup print position
			ld hl,engmsg
			call dzmstr			;display "ENGINE"
			ld de,$0e40			;print channel mute display
			ld hl,chnmsg
			call dlmde			;display "CH "
			ld a,(chmask)
			call chmaskp
			
			ld a,(spdpnt)		;load speed value
			call num2hex		;convert to character codes and store in (numfld)
			ld de,$0257			;setup print pos
			call nfstde			;display speed value
			
			ld a,(engpnt)		;load engine value
			call num2hex		;convert to character codes and store in (numfld)
			ld de,$085b			;setup print pos
			ld (pencol),de	
			call nfmch
			
setmenu		ld de,$1444			;setup print pos
			ld c,7				;setup loop counter
			ld hl,menumsg
dmloop		ld a,6				;setup print adjustment
			call dlmde			;print length-indexed string
			add a,d				;update it
			ld d,a
			dec c				;printing 7 lines, count down
			jr nz,dmloop

			ld de,$0200			;setup print pos for pattern matrix
			push de				;preserve it
			ld hl,(sngpnt)
			
			ld c,10				;counter for screen printing, printing 10 rows
			
scrinit0						;calculate row numbers from position in song data
			ld (intbuf1),hl		;store temporary song data pointer

			push bc				;store loop counter
			ccf
			ld bc,sdata			;load song data start position
			sbc hl,bc			;subtract it from current song data position
			inc hl				;adjust +1

skip3		call linediv
			ld h,b				;now bc holds the actual row number
			ld l,c				;transfer it to hl

			pop bc				;restore loop counter (held in c)
			ld b,l
			ld a,h				;convert MSB to character code
			call num2hex		;and store in text buffer
			pop de				;retrieve printing position
			ld (pencol),de
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
reswitch	nop					;self-modifying switch, set to ret after internal restart
;***************************************************************************
;Main key handler
;***************************************************************************			
			
readkeys	ld a,%11011111		;mask keys
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

			
keyD		ld a,$0d				;assign hex values
			jr imputjmp
keyA		ld a,$0a
			jr imputjmp
key0		xor a
			jr imputjmp
key1		ld a,$01
			jr imputjmp
key4		ld a,$04
			jr imputjmp
key7		ld a,$07
			jr imputjmp
keyE		ld a,$0E
			jr imputjmp
keyB		ld a,$0B
			jr imputjmp
key2		ld a,$02
			jr imputjmp
key5		ld a,$05
			jr imputjmp
key8		ld a,$08
			jr imputjmp
keyF		ld a,$0f
			jr imputjmp
keyC		ld a,$0c
			jr imputjmp
key3		ld a,$03
			jr imputjmp
key6		ld a,$06
			jr imputjmp
key9		ld a,$09
			
imputjmp	jp inputv

keySto		call rowtrns
			ld hl,mhxbuf+6
			jr keyLcp

keyLn		call rowtrns
			ld hl,mhxbuf+3
			jr keyLcp

keyLog		call rowtrns
			ld hl,mhxbuf
keyLcp		call copynum
			jr kskip2

rowtrns		push de
			call chkstart
			ld (intbuf1),hl		;store temporary song data pointer
			
			ccf
			ld de,sdata			;load song data start position
			sbc hl,de			;subtract it from current song data position
			inc hl				;adjust +1

			call linediv		;now bc holds the actual line #
			pop de
			ret
			
copynum		ld a,b
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
			
keyNeg		call chkstart			;play from position
			jr cplay
			
keyDot		call chkstart			;play current row
			ld de,pbuf				;load pointer to temporary player buffer
			ld b,5
			ld a,(chmask)
			ld c,a
chmtsk0		srl c
			jr nc,chmtsk1
			xor a
			jr chmtsk2
chmtsk1		ld a,(hl)
chmtsk2		ld (de),a
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

cplay		ld a,(hl)
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
cpskp		ld a,$c0				;revert code modifications
			ld (pex),a
			xor a
			ld (t5pex),a
			ld (t7pex),a

kskip1		call csrset
kskip2		jp readkeys

keyDown		call csrdel
			call rowinc
			jr kskip1				;print cursor
keyUp		call csrdel
			call rowdec
			jr kskip1
keyLeft		call csrdel
			ld a,(colval)			;check what column is currently active
			or a					;if it is the leftmost column...
			jr z,kskip1				;... ignore keypress
			rra						;if it is an even column...
			call nc,dcoldec			;... shift cursor an extra 2 pixels and switch column
			call coldec				;update cursor position
			jr kskip1
keyRight	call csrdel
			ld a,(colval)			;check what column is currently active
			cp 9					;if it is the rightmost column...
			jr z,kskip1				;... ignore keypress
			rra						;if it is an odd column...
			call c,dcolinc			;... shift cursor an extra 2 pixels and switch column
			call colinc				;update cursor position
			jr kskip1
			
keyPlus		ld a,(spdpnt)			;increase speed value
			cp $fe
			jr z,ppret
			inc a
			ld (spdpnt),a
ppret		jr pmret

keyMinus	ld a,(spdpnt)			;decrease speed value
			dec a					;if a=1
			jr z,qret				;do nothing
			ld (spdpnt),a
pmret		ld bc,(numfld)
			res 3,(iy+$05)
			call num2hex
			ld de,$0257
			call nfstde				;display new speed value
			ld (numfld),bc
			call kdelay
			set 3,(iy+$05)
qret		jp readkeys

keyMult		ld a,(engpnt)
			cp 3
			jr z,kddret
			inc a
			ld (engpnt),a
			jr kddret
keyDiv		ld a,(engpnt)
			cp 1
			jr z,kddret
			dec a
			ld (engpnt),a
kddret		ld bc,(numfld)
			res 3,(iy+$05)
			call num2hex
			ld de,$085b
			ld (pencol),de	
			call nfmch
			ld (numfld),bc
			call kdelay
			set 3,(iy+$05)
			jr keymenx

keyMenu		call dispmenu
keymenx		jp readkeys

keyZoom		call chkstart			;copy current row to buffer
			ld de,pbuf				;load pointer to temporary player buffer
			ld bc,$0005				;loop counter
			ldir
			jr keymenx

keyTrace	call chkstart
			push hl
			ld de,pbuf
			ex de,hl
			ld bc,$0005				;loop counter
			ldir
			ld de,(pencol)
			ld e,14
			ld (pencol),de
			res 3,(iy+$05)
			pop hl
			call nlinity
			jr keymenx

keyQcopy	call qinit
			call kdelay
			call mcopy
			jr keymenx

keyQcut		call qinit
			call mcut
			jr keymenx
			
keyMute		ld a,(colval)			;check current cursor position
			ld c,$01				;mask for xor'ing against channel mute mask (chmask)
			srl a					;colval/2 = data column currently being edited
			jr z,kmsx
			
kmloop		sla c					;rotate mask
			dec a
			jr nz,kmloop
			
kmsx		ld a,(chmask)
			xor c
kmsret		call chmaskp
			call kdelay
			call kdelay
			jp readkeys

chmaskp		ld (chmask),a
			ld hl,chnmsg+3
			ld de,$0e4b
			ld (pencol),de
			ld b,5
kmploop		set 3,(iy+$05)			;print inverse
			srl a
			call c,kmswitch
			push af
			ld a,(hl)
			call mcharput
			pop af
			inc hl
			djnz kmploop	
kmswitch	res 3,(iy+$05)
			ret		
			
qinit		ld a,$c9				;modify code, so we can call mhand instead of jumping to it
			ld (mhdqex),a
			call mhand
			xor a
			ld (mhdqex),a			;revert code modification
			res 3,(iy+$05)
			ld de,$3201				;setup printing position used by mhexkhd subroutine
			ld (pencol),de
			ret
			
;***********************************************************************
;Hexadecimal Input Routine
;***********************************************************************
		
inputv		ld d,a					;input hex nibble
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

input1		ld a,(hl)				;load pointer
			or $0f					;clear lower nibble
			xor $0f
			ld e,a					;preserve in e
			ld a,d					;load inputval

inputf		add a,e						
			ld (hl),a				;load data pointer with new value
			call num2hex

rowswitch	ld a,(colval)			;update row value pointer
			rra
			jr nc,norowup
			ld hl,(csrpos)
			ld (pencol),hl		;and update the screen while we're at it
			call nfmch			
			call coldec
			call rowinc
rowf		call csrset
			call kdelay
			call kdelay
			jp readkeys
norowup		ld hl,(csrpos)
			ld (pencol),hl
			ld a,(numfld)    		;Offset of the string
			call mcharput 			;Display the string
			call colinc
			jr rowf

dcolinc		ld a,(csrpos)
			add a,2
			ld (csrpos),a
			ld hl,(sngpnt)			;
			inc hl
			jr dcex
			
colinc		ld a,(csrpos)
			add a,4
			ld (csrpos),a
			ld a,(colval)
			inc a
			jr cex
			
dcoldec		ld a,(csrpos)			;look up current cursor position
			sub 2					;shift left 2 pixels
			ld (csrpos),a			;update cursor position
			ld hl,(sngpnt)			;update song data pointer
			dec hl
dcex		ld (sngpnt),hl
			ld a,(hl)				;
			call num2hex			;
			ret
			
coldec		ld a,(csrpos)
			sub 4
			ld (csrpos),a
			ld a,(colval)
			dec a
cex			ld (colval),a
			ret
			
rowinc		ld a,(csrpos+1)			;look up current cursor position
			cp 56					;see if we have reached the bottom of the screen
			jr nz,rskip1
			call scrlup				;if so, scroll
			ret

rskip1		add a,6					;update cursor position
			ld (csrpos+1),a
			ld hl,(sngpnt)			;update song data pointer
			ld de,$0005
			add hl,de
			ld (sngpnt),hl
			ret

rowdec		ld a,(csrpos+1)			;look up current cursor position
			cp $02					;see if we have reached the top the screen
			jr nz,rskip2
			call scrldown
			ret
			
rskip2		sub 6					;update cursor position
			ld (csrpos+1),a
			ld hl,(sngpnt)			;update song data pointer
			ld de,$0005
			sbc hl,de
			ld (sngpnt),hl
			ret			

;*********************************************************************
;scrolling routines		
;*********************************************************************			
			
scrlup		ld hl,(sngpnt)			;check if we're at the last line of song data
			push hl
			ld de,sdend-5				
			sbc hl,de
			pop hl
			ret nc					;if so, don't scroll
			ld de,$0005				;update data pointer
			add hl,de
			call backupdsp


			ld hl,graph_mem+24+72	;chickendude's optimized scrolly
			ld de,graph_mem+24
			ld a,64-2-6				;-2 for +24/12, -6 for +72/12
grcopy
			ld bc,8
			ldir
			ld c,4
			ex de,hl				;we can't do sbc de,bc, so we swap de and hl
			add hl,bc				;de-4
			ex de,hl				;swap back
			add hl,bc				;hl-4
			dec a
			jr nz,grcopy
		
			call ionFastCopy		;... it's time to print the screen
			ld de,$3800				;printing pos = start of lowest line
			call newline			;now let's fetch the correct line number
			ret

			
scrldown	ld hl,(sngpnt)			;check if we're at the first line of song data
			push hl
			ld de,sdata+5				
			sbc hl,de
			pop hl
			ret c					;if so, don't scroll
			ld de,$0005				;update data pointer
			sbc hl,de
			call backupdsp

			ld hl,graph_mem+768-24-72-5	;chickendude's optimized scrolly again
			ld de,graph_mem+768-24-5	;skip an extra 4 bytes (right side screen)
			ld a,56
grcopy1
			ld bc,8
			lddr
			ld c,4
			ex de,hl				;we can't do sbc de,bc, so we swap de and hl
			sbc hl,bc				;de-4
			ex de,hl				;swap back
			sbc hl,bc				;hl-4
			dec a
			jr nz,grcopy1
			
			call ionFastCopy			;... it's time to print the screen
			ld de,$0200				;printing pos = start of top line
			call newline			
			ret	

backupdsp	ld (sngpnt),hl
			bcall(_savedisp)	;copy current screen to graph_mem
			ld bc,768
			ld hl,saferam1
			ld de,graph_mem
			ldir
			ret

;*********************************************************************
;various calls to ROM_CALLs
;*********************************************************************			
nfstde		ld (pencol),de
nfstr		ld hl,numfld
dzmstr		bcall(_vputs)
			ret
dlmde		ld (pencol),de
dlm3		ld b,3			
dlmstr		bcall(_VPutSN)
			ret
nfmch		ld a,(numfld+1)
mcharput	bcall(_vputmap)
			ret

			
;*********************************************************************
;routine for printing a single line of song data
;*********************************************************************
newline		push de
			call chkstart
			ld (intbuf1),hl		;store temporary song data pointer
			ccf
			ld de,sdata			;load song data start position
			sbc hl,de			;subtract it from current song data position
			inc hl				;adjust +1

skipnl		call linediv		;now bc holds the actual line #

			ld a,b				;convert MSB to character code
			call num2hex		;and store in text buffer
			pop de				;retrieve printing position
			ld (pencol),de
			push de
			call nfmch			;display MSB of row number
			pop de
			ld a,4				;adjust printing position for next output
			add a,e
			ld e,a
			ld a,c				;convert LSB of row number to character code
nlinitx		push de				;preserve printing position
			call num2hex
			pop de				;retrieve printing positon
			call nfstde			;display LSB of row number
			ld a,10				;adjust printing position for next output
			add a,e
			ld e,a
			ld (pencol),de
			push de				;preserve printing position
			ld hl,(intbuf1)		;retrieve temporary song data pointer

nlinit0		ld b,5				;load loop counter to print five columns
nlinit1		ld a,(hl)			;load note byte
			call num2hex		;convert to hex
			pop de				;setup print pos
			ld (pencol),de
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

nlinity		push de
			jr nlinit0
			
;*********************************************************************
;cursor printing routine
;*********************************************************************
			
csrset		set 3,(iy+$05)			;print inverted
			call kdelay
			jr csrprint
csrdel		res 3,(iy+$05)			;print normal
csrprint	ld hl,(sngpnt)
			ld a,(hl)				;restore from cursor
			call num2hex
			ld de,(csrpos)
			ld (pencol),de
			ld a,(numfld)
			ld b,a
			ld a,(colval)
			rra						;;check if we're at an odd or even row
			jr nc,csrf
			ld a,(numfld+1)			;if we're at an odd row, load char code of 2nd nibble
			ld b,a
csrf		ld a,b
			call mcharput
			ret
			
kdelay		ld bc,$3000				;delay loop to prevent accidental key repeat
kdloop		ld hl,$0000				
			push hl
			pop hl
			dec bc
			ld a,b
			or c
			jr nz,kdloop
			ret

;**********************************************************************
;determine row start point
;**********************************************************************

chkstart	ld a,(colval)			;load current column value
			bit 0,a
			jr z,chk1
			dec a
chk1		srl a					;divide by 2
			ld c,a					;preserve in c
			ld b,0					;clear b (just to be sure)
			ld hl,(sngpnt)			;load current pointer to song data
			ccf						;?
			sbc hl,bc				;subtract colval/2
			inc hl					;?
			ret

;**********************************************************************
;menu subroutine
;**********************************************************************

dispmenu	call csrdel				;delete normal cursor

			set 3,(iy+$05)			;print inverted
			ld de,$1444
			ld hl,menumsg
			xor a
			ld (pbuf),a				;(pbuf) is used to store menu position counter
			call mxpri
			call kdelay
			call kdelay
			
rkmenu		ld hl,menumsg			;reset initial string pointer
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
			
menexit		call mkdsx
mrexit		call csrset				;print normal cursor
			ret						;return to global keyhandler

mkeyM		call mhand
			or a
			jr nz,mrexit			;if Jump was executed, return to global keyhandler immediately
			jr mkex					;else, do a short delay and continue reading keys
			
mkeyUp		call mkdsx				;delete cursor
			dec a					;decrement cursor position
			cp $ff					;if < 0
			jr nz,mkdsk				;go print
			ld a,6					;else, cursor pos = 6
			jr mkdsk				;go print
			
mkeyDown	call mkdsx				;delete cursor
			inc a					;increase cursor position
			cp 7					;if <7
			jr nz,mkdsk				;go print
			xor a					;else, cursor pos = 0, go print
			
mkdsk		ld (pbuf),a				;update menu pos buffer
			set 3,(iy+$05)			;print inverted
			call mkdsx				;call printing subroutine
mkex		call kdelay
			jr rkmenu				;return to menu keyhandler

mkdsx		ld a,(pbuf)				;read menu position buffer
			or a					;if menu pos = 0
			jr z,mxpri				;we already have correct printing pos, so print
			
			push hl					;preserve string pointer		
			ld b,a					;load menu pos to counter
			xor a					;a=0
			ld l,a					;l=0
mlp1		add a,6					;
			djnz mlp1				;repeat (menu pos) times
			ld h,a					
			add hl,de				;add offset 
			ex de,hl				;update curor position
			pop hl					;restore string pointer
			ld a,(pbuf)				;read menu pos from buffer
			ld b,a					;load to counter
			xor a					;a=0
mlp2		add a,3					;
			djnz mlp2				;repeat (menu pos) times
			ld c,a					;c = offset, b = 0
			add hl,bc				;add offset to string pointer

mxpri		call dlmde				;print length-indexed string at pointer
			ld a,(pbuf)				;load menu pos from buffer
			ld hl,menumsg
			ld de,$1444
			ret						;and that's it

;************************************************************************
mhand		bcall(_savedisp)	;copy current screen to saferam1
			call restdisp			;copy saferam1 to graph_mem
mhand1		ld hl,graph_mem + 516 + 48
			ld b,12
			ld a,$ff
mllloop		ld (hl),a				;draw a line
			inc hl
			djnz mllloop
			ld b,214 -48
			xor a
mblloop		ld (hl),a				;blank the lowest two rows
			inc hl
			djnz mblloop
			call ionFastCopy
mhdqex		nop
			
mmkhd		ld a,%11111101			;mask keys... 
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

mmexit		call restdisp			;restore main view
			call ionFastCopy
			call kdelay				;wait a bit to prevent accidental keypress
			ld a,$03				;revert potential code modification
			ld (mhxswitch),a
			xor a
			ld (mhxcmode),a			;reset copy mode
			ret						;and back to global keyhandler

mconfirm	ld a,(pbuf)				;determine menu position
			ld de,$3201				;setup printing position used by mhexkhd subroutine
			ld (pencol),de
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
			
mjump		ld hl,menumsg			;jump to line routine - load pointer to "JMP"
			call dlm3				;print it
			ld hl,msto				;load pointer to " TO:"
			call dzmstr				;print it
			ld de,(pencol)		;preserve current print pos for mhexkhd
			push de
			ld de,$3801				;go to next line
			ld (pencol),de
			ld hl,err3				;load pointer to "[Y=] CONFIRM  [CLEAR] ABORT"
			call dzmstr				;print it
			pop de					;get back our print pos for hex input
mjmpkhd		ld a,3					;need to input 3 hex digits
			ld hl,mhxbuf+6
			call mhexkhd			;call hex input routine
			or a					;if it returns with a=0
			jr z,mmexit				;then user pressed [CLEAR]

mjmpinit	ld hl,mhxbuf+6
			call hex2ln
			call rowadjust
			ld (sngpnt),hl			;now we know where to jump to in RAM
mjmpexit	ld a,$c9				;otherwise
			ld (reswitch),a			;modify code
			ld de,$020e				;preserve cursor position - don't think it's actually necessary
			ld (csrpos),de
			bcall(_clrlcdf)	;well...
			call restart			;restart Houston Tracker, thus updating the screen
			xor a					;revert code modification
			ld (reswitch),a
			cpl						;set a=$ff so menu keyhandler knows that it should quit to
			ld (sdend),a			;restore internal end marker
			ret						;main keyhandler

			
mcopy		ld hl,menumsg+3
			call dlm3
			ld hl,msfrom
			call dzmstr
			ld de,(pencol)		;preserve current print pos for mhexkhd
			push de
			ld a,15
			add a,e
			ld e,a
			ld (pencol),de
			ld hl,msto
			call dzmstr
			ld de,$3801				;go to next line
			ld (pencol),de
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
			
minsert		ld hl,cmsg3
			call pastprep

			
mimovdat	push bc					;move consecutive data down to make room for insert
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
			
mimov		ld a,(hl)				;move down byte
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

miblkadj	ld a,(mvsect)			;adjust start/end points if source blk was moved
			or a
			jr z,mipast
			ld bc,(intbuf1)
			ex de,hl
			add hl,bc				;add len to hl,de
			ex de,hl
			add hl,bc

mipast		pop bc
			ld a,(mvsect)			;the everlasting target row problem
			or a
			jr z,mipstsk
			inc de
			inc hl
mipstsk		ex de,hl				;now hl=start pos, de=end pos

			push hl					;paste source to target
			jp mpclpp
			
			
mcut		xor a
			ld (mhxcmode),a
			ld hl,menumsg+6
			call dlm3
			ld hl,msfrom
			call dzmstr
			ld de,(pencol)		;preserve current print pos for mhexkhd
			push de
			ld a,15
			add a,e
			ld e,a
			ld (pencol),de
			ld hl,msto
			call dzmstr
			ld de,$3801				;go to next line
			ld (pencol),de
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
mccutlp		ld a,(hl)
			ld (de),a
			inc hl
			inc de
			cp $ff
			jr nz,mccutlp
mccutlp2	ld a,(de)
			cp $ff
			jr z,mccskp1
			xor a
			ld (de),a
			inc de
			jr mccutlp2
mccskp1		xor a
			ld (de),a
			pop hl
			jp mjmpinit

mpast		ld hl,cmsg2
			call pastprep
			ex de,hl				;now hl=start pos, de=end pos
			push hl

			
mpclpp		exx						;to register set 2
			ld b,5					;counter to b'
			ld a,(chmask)			;channel mute mask to c'
			ld c,a
			exx						;back to primary reg.set
mpclpp0		ld hl,sdend
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
			
mpcms0		exx						;back to primary reg.set
			ld a,(hl)				;copy data byte
			ld (bc),a
mpcmskp		inc hl					;increment pointers
			inc bc
			push hl
mcpsw .EQU $				
			inc hl					;self-modifying, skip inc hl ($23) after copy w/ muted chans
			ccf
			sbc hl,de				;check if end of copy block reached
			jr nc,mpdone
			jr mpclpp0				;if not, continue copying stuff
mpdone		pop hl
			jp mjmpinit

mpcrev		dec b					;same as above, but skips copying
			jr nz,mpcrev0
			ld b,5
			ld a,(chmask)
			ld c,a
mpcrev0		exx						;back to primary reg.set
			jr mpcmskp

	
mload		ld a,(slottab)			;check if at least one saveslot exists
			or a
			jr z,mdelx				;if not, abort			
			xor a
			call ldsav
			ld a,$c9				;modify code
			ld (reswitch),a
			jp mxrest2				;and restart Houston Tracker

msave		ld a,1
mlsj		call ldsav
mdelx		call restdisp
			jp mmexit				;and we're done

mswap		ld a,(slottab)			;check if at least one saveslot exists
			or a
			jr z,mdelx				;if not, abort
			ld a,2
			jr mlsj

mzap		ld hl,menumsg+9			;point to "ZAP"
			call dlm3				;print it
			ld hl,msall				;point to " ALL"
			call mxsetup			;print the usual crap and modify hex keyhandler
			call mhexkhd			;call hex keyhandler (which now just reads [Y=] and [CLEAR]
			or a					;check if user pressed [CLEAR]
			jp z,mmexit				;if so, exit to menu keyhandler
			ld a,$03				;revert code modification
			ld (mhxswitch),a
mzapx		ld a,$c9				;modify code
			ld (reswitch),a
			ld a,$ff				;put an end marker at the start of the song data
			ld c,0
			ld hl,sdata
			ld (hl),a
mzxloop		inc hl					;increase pointer
			ld b,(hl)				;look up value at pointer
			ld (hl),c				;write a $00 byte at pointer
			cp b					;check if we have reached an end marker
			jr z,mxrest				;if so, restart Houston Tracker
			jr mzxloop				;if not... we gotta copy some more 0s
			
mxrest		ld hl,sdend				;restore permanent end marker
mxrest1		ld (hl),a
mxrest2		call init				;restart Houston Tracker
			ld a,$00				;revert code modification
			ld (reswitch),a
			cpl						;set a=$ff so menu keyhandler knows it should exit to main keyhandler
			ret						;and that's that.
						
restdisp	ld bc,768				;copy saferam1 to graph_mem
			ld hl,saferam1
			ld de,graph_mem
			ldir
			ret

mxsetup		call dzmstr		;print whatever was pointed to
mxsetup2	ld de,$3801				;set print position to last line
			ld (pencol),de		
			ld hl,err3				;point to "[Y=] CONFIRM  [CLEAR] ABORT"
			call dzmstr		;print it
			ld a,$ea				;modify hex input keyhandler so it only reads [Y=] and [CLEAR]
			ld (mhxswitch),a
			xor a
			ret

holdlp		push af					;row holding for engines
holdllp		xor a						;keyhandler
			out (1),a					;mask port with 0
			in a,(1)					;read MODE key
			cpl
			or a
			jr nz,holdllp
			pop af
			ret
			
derowlp		dec hl						;row looping for engines
			dec hl
			dec hl
			dec hl
			dec hl
			ret
			
rowadjust	push hl						;pointer adjustment for copy/cut
			push bc
			call chkstart
			ld (sngpnt),hl
			xor a
			ld (colval),a
			pop bc
			pop hl
			ret

pastprep	push hl						;preparations for copy/paste
			call kdelay
			pop hl
			ld de,$3201
			call dlmde
			ld hl,msat
			call dzmstr
			ld de,(pencol)
			push de
			ld b,70
mpcllp		ld a,$20
			call mcharput
			djnz mpcllp
			ld a,3
			ld hl,mhxbuf+6
			pop de
			ld (pencol),de
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

msgsetu		call dlm3				;print it
			call mxsetup2			;print the usual crap and modify hex keyhandler
			call mhexkhd			;call hex keyhandler (which now just reads [Y=] and [CLEAR]
			or a					;check if user pressed [CLEAR]
			ret

;lslset		ld a,$03				;revert code modification
;			ld (mhxswitch),a
;			ld bc,10000				;swap 10000 bytes
;			ld hl,sdata
;			ld de,savebuf			
;			ret
			
;********************************************************************
;various pointers and temporary buffers
;********************************************************************			
			
intbuf1 .EQU $						;temporary buffer to hold song data pointer
			nop						;while calculating the row number
			nop						;also holds block length during copy
			
sngpnt .EQU $						;pointer to current position in song data
			nop
			nop
			
numfld .EQU $						;temporary buffer for 2 character codes
			nop
			nop
			nop						;let's make it a 0-terminated string

colval .EQU $						;this byte tells us which type of column is
			nop						;currently being edited
			
chmask .EQU $						;channel mute mask
			nop			

pbuf .EQU $							;temporary buffer for single row playback
			nop						;this byte is also used by menu routine
			nop
			nop
			nop
			nop
			.db $ff					;end marker

csrpos .EQU $						;cursor position
			.db $0e,$02

sbuf .EQU $
			nop						;stack pointer buffer
			nop

spdmsg								;this is obvious ;)
			.db "TEMPO",0

engmsg		.db "ENGINE",0

chnmsg		.db "CH D1234",0

menumsg		.db "JMP"
			.db "CPY"
			.db "CUT"
			.db "ZAP"
			.db "LD "
			.db "SAV"
			.db "DEL"				;replace this with DEL later

cmsg2		.db "PST"
cmsg3		.db "INS"			
			
msfrom		.db " FROM:",0
msto		.db " TO:",0
mslen		.db "LENGTH: ",0
msall		.db " ALL",0
msat		.db " AT:",0
			
err1		.db "FAIL: ",0
err2d		.db "end <= start",0
err2e		.db "target w/in source",0
err3		.db $c1					;"[" is evaluated incorrectly by Crash
			.db "Y=] CONFIRM   "
			.db	$c1
			.db "CLEAR] ABORT",0
			
;lsnew		.db "NEW "
lsslot		.db "SLOT ",0
lsfree		.db " B FREE",0			
			
cmsgpnt		nop
			nop
			
;************************************************************************
;Various Subroutines
;************************************************************************

mhexkhd						;Routine for handling hex input in menu functions
.INCLUDE "txtrack/mhexkhd.asm"

num2hex						;the number to character code converter
.INCLUDE "txtrack/num2hex.asm"

linediv						;the 16-bit division subroutine
.INCLUDE "txtrack/linediv.asm"

hex2ln						;the ascii to line number converter
.INCLUDE "txtrack/hex2ln.asm"

etrap						;the error trapping subroutine
.INCLUDE "txtrack/etrap.asm"

ldsav						;the file manager subroutine
.INCLUDE "txtrack/ldsav.asm"

player						;engine 1 and drum routines
.INCLUDE "txtrack/tim4.asm"	

player2						;engine 2
.INCLUDE "txtrack/tim5.asm"	

player3						;engine 3
.INCLUDE "txtrack/tim7.asm"	

;***********************************************************************
;song data buffer
;***********************************************************************

engpnt .EQU $
			.db $01			;this holds the engine currently used

spdpnt .EQU $				;this holds the song speed
			.db $10
			
sdata .EQU $
			.db $ff			;initial data end marker
#ifdef LIGHT
			.BLOCK 4999
#else			
			.BLOCK 8999		;reserve space for song data
#endif			
sdend		.db	$ff			;song data end marker

savebuf .EQU $
#ifdef LIGHT 
			.BLOCK 5002
#else
			.BLOCK 9002
#endif
saveend		.db $ff

.END
	.dw $0000
.END
