;TIM-FX (TIM-5)	1-bit music routine by utz 02/2013
;note data should be drum/end, ch1, ch2, fx#, fx-param

t5begin		di
			call t5init
			jr nz,t5ppx
			xor a				;make sure main routine doesn't jump into the next player upon returning
			cpl
t5pex .EQU $
			nop			
			ld hl,sdata
			jr z,t5begin
t5ppx		ei			
			ld a,$78			;revert possible code modifications
			ld (volsw),a
			ld a,$fc
			ld (tout1),a
			ld (tout2),a
			ld a,$7e
			ld (t5s61),a
			ld a,$32
			ld (t5s62),a
			ret

t5init		ld a,(spdpnt)		;read speed byte
			inc a				;adjust (for drums)
			ld (t5spd),a
			;ld hl,musicData		;load data pointer
		
t5rdata		ld a,(hl)			;load drum byte
			cp $ff				;if it is $ff
			ret z				;exit player
			srl a
			srl a
			srl a
			srl a
			or a
			jr z,t5ssk1
			inc a
			ld (t5spd),a
t5ssk1		ld a,(t5spd)
			ld b,a				;
			ld c,a				;now bc1 holds speed counter
			call dtrig
			cpl						
			ld d,a				;note ch1 to d
			inc hl
			ld a,(hl)
			cpl
			ld e,a				;note ch2 to e
			
			ld a,$ff			;quick and dirty fix for the "1 channel muted destabilizes timing" problem
			cp d				;which I haven't tracked down yet ... does it really fix the issue???
			jr nz,t5rs0
			ld d,e
t5rs0		cp e
			jr nz,t5rs1
			ld e,d
t5rs1		push de
			
			inc hl				;inc pointer
			ld a,(hl)			;read fx # byte
			inc hl
			or a				;if it's 0
			jr z,t5s11			;we're done reading data
			

t5s3		bit 4,a				;change volume if fx byte was $1x
			push af
			jr nz,t5s4			;if volume param is $00
			ld a,$78			;(un)modify code
			ld (volsw),a
			jr t5s41
t5s4		ld a,$79			;otherwise
			ld (volsw),a		;modify code accordingly
t5s41		pop af
			res 4,a
			jr t5s0
			
			
t5s0		dec a
			jr nz,t5s1			;if it's 1 (now 0)
			push af
			ld a,(hl)			;read fx param byte
			cpl					;complement (so effectively it will be subtracted later)
			ld (sweep+1),a		;preserve fx byte
			pop af
			jr t5s11			;and we're done reading data
			
t5s1		dec a				;if it's 2 (now 0)
			jr nz,t5s2
			ld a,(hl)			;read fx param byte
			ld (sweep+1),a
t5s11		jr t5sndlp
				
t5s2		cp $0d				;change tempo if fx byte was $0f (now $0d)
			jr nz,t5s5
			ld a,(hl)			;update tempo value from fx param byte
			or a		
			jr z,t5sndlp		;ignore change if param byte is 0
			inc a				;adjust (for drum)
			or a
			jr nz,t5ok			;check if user entered $ff as tempo
			dec a
t5ok		ld (t5spd),a
			ld b,a
			ld c,a
			jr t5sndlp

			
t5s5		cp $06				;change panning if fx byte was $08
			jr nz,t5s6
			ld a,(hl)
			or a
			jr nz,t5s51			;if fx byte = 0
			ld a,$fc			;set output to center
			jr t5s54
t5s51		dec a				
			jr nz,t5s52			;if fx byte = 1
			ld a,$d4			;set output to left ch
			jr t5s54
t5s52		dec a				;if fx byte = 2
			jr nz,t5s53
			ld a,$e8			;set output to right ch
			jr t5s54
t5s53		dec a				;if fx byte = 3
			jr nz,t5sndlp
			ld a,$d4			;set ouput ch1 to left ch
			ld (tout1),a
			ld a,$e8			;set output ch2 to right ch
			jr t5s55
t5s54		ld (tout1),a		;store output mask ch1
t5s55		ld (tout2),a		;store output mask ch2
			jr t5sndlp
			
t5s6		cp $0c					;intbuf1ger if fx byte was $0e
			jr nz,t5sndlp
t5s61 .EQU $
			ld a,(hl)				;$7e - self-modifying to nop
t5s62 .EQU $
			ld (intbuf1),a			;$32 xx xx -> $3a xx xx (ld a,())
			or a
			jr z,t5sndlp		;if fx byte was 0, proceed normal
			dec a
			jr z,t5revf			;if intbuf1ger counter is now 0, revert code modifications
			ld (intbuf1),a		;otherwise, update intbuf1ger counter
			dec hl				;adjust data pointer
			dec hl
			dec hl
			dec hl
			dec hl
			xor a				;modify code, see above
			ld (t5s61),a
			ld a,$3a
			ld (t5s62),a
			jr t5sndlp

t5revf		ld a,$7e			;revert code modifications
			ld (t5s61),a
			ld a,$32
			ld (t5s62),a

			
t5sndlp		ld a,$ff		;7		;check if ch1 is supposed to be muted
			cp d			;4
			jr z,t5sadj1	;12/7	;if yes, skip counter decrement
			xor a			;4
			dec d			;4		;decrement counter ch1
dcsk1		or d			;4	[7]	;check if it has reached 0
			jr nz,t5sadj1	;12/7	;if not, continue with ch2
			ld a,e			;4		;otherwise, hold counter ch2
			pop de			;10		;restore counter ch1
			push af			;11
			ld a,d			;4
			call sweep		;17+17
			ld d,a			;4
tout1 .EQU $+1
			ld a,$fc		;7
			ld (outswt),a	;13
			pop af			;10
			push de			;11
			ld e,a			;4		;restore counter ch2
			jr dcsk2		;12 [131]

t5sadj1		call t5sadjx	;+5+17+111-131=3t overhead... acceptable
				
dcsk2		ld a,$ff		;7		;check if ch2 is supposed to be muted
			cp e			;4
			jr z,t5sadj2	;12/7	;if yes, skip counter decrement
			xor a			;4
			dec e			;4		;decrement counter ch2
ecsk1		or e			;4	[7]	;check if it has reached 0
			jr nz,t5sadj2	;12/7	;if not, all is set for output
			ld a,d			;4		;otherwise, hold counter ch1
			pop de			;10		;restore counter ch2
			push af			;11
			ld a,e			;4
			call sweep		;17+17
			ld e,a			;4
			ld a,(outswt)	;13
tout2 .EQU $+1				
			or $fc			;7
			ld (outswt),a	;13
			pop af			;10
			push de			;11
			ld d,a			;4		;restore counter ch1
			jr ecsk2		;13

t5sadj2		call t5sadjx	;17+5+111-146=14t underrun			
				
outswt	.EQU $+1				
ecsk2		ld a,$c0		;7		;self-modifying
t5play		push bc			;11
			ld b,a			;4
			ld c,$c0		;7
			out (0),a		;11
			ld a,$c0		;7
			ld (outswt),a	;13
			
volsw .EQU $
			ld a,b			;4		;**$78, for low vol, replace with $79 (ld a,c)
			pop bc			;10
			out (0),a		;11		;switch off sound if vol is "quiet"
			
			dec bc			;6
			ld a,b			;4
			or c			;4
			jr nz,t5sndlp	;12/7

t5keyhd		pop de
			xor a						;keyhandler
			ld (sweep+1),a
			out (1),a					;mask port with 0
			in a,(1)					;read any key
			jr z,t5kkdh
t5khdex		inc hl
			jp t5rdata
			
t5kkdh		cpl
			bit 6,a						;test for keypresses on row MODE
			ret nz						;exit player if key pressed
			bit 5,a						;read [^] key
			call nz,holdlp
			bit 4,a
			call nz,derowlp
			jr t5khdex

sweep .EQU $
			add a,$00			;7		;self-modifying
			ret					;10

t5sadjx		push bc				;11
			ld b,5				;7
t5sadjlp	djnz t5sadjlp		;13/8 = 73	
			pop bc				;10
			ret					;10		;111 - not quite as much as is needed, but it does the trick and
										;improves the frequency range

t5spd .EQU $
		.db $10
