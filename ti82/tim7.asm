;Mark-2 (TIM-7)	1-bit music routine by utz 04/2013 
;note data should be drum/end, ch1, ch2, ch3, tempo or $00

t7begin		di

			call t7init

t7pex .EQU $			
			nop
			ld hl,sdata
			jr z,t7begin
			ld a,$fc
			out (0),a
			ei			
			ret

t7init		ld (intbuf1),hl
		
t7rdata		ld hl,(intbuf1)
			ld a,(spdpnt)		;read speed byte
			inc a				;adjust (for drums)
			ld b,a				;
			ld c,a				;now bc1 holds speed counter
			ld a,(hl)			;load drum byte
			cp $ff				;if it is $ff
			ret z				;exit player
			or $0f
			xor $0f
			or a
			jr z,t7drum
			ld a,%00101000		
			ld (t7smask1),a
			srl a				;ld a,%00010100
			ld (t7smask2),a
t7drum		call dtrig
			or a
			jr nz,t7rsk1		;if channel is supposed to be muted
			ld (t7mute1),a		;replace counter decrement with nop
t7rsk1		cpl						
			ld d,a				;note ch1 to d1
			inc hl
			ld a,(hl)
			or a
			jr nz,t7rsk2
			ld (t7mute2),a
t7rsk2		cpl
			ld e,a				;note ch2 to e1
			inc hl
			push de
			push hl
			ld hl,$fcfc
			exx
			pop hl
			pop de
			ld a,(hl)
			or a
			jr nz,t7rsk3
			ld (t7mute3),a
t7rsk3		cpl
			ld b,a				;now b' holds counter ch3
			inc hl
			ld a,(hl)
			or a
			jr z,t7rsk4
			exx
			inc a
			or a
			jr nz,t7rsok		;check if user entered $ff as tempo
			dec a
t7rsok		ld b,a
			ld c,a
			exx
t7rsk4		inc hl
			ld (intbuf1),hl
			push bc
			push de
			ld h,$fc			;output mask to xor against

			
t7out		pop de
			ld a,h
t7smask1 .EQU $+1			
			xor %00111100		;00101000
			out (0),a
t7mute3 .EQU $			
			dec b				;self-modifying, dec b ~ $05
			jr nz,t7sk4
			ld h,a
			ld a,c
			pop bc
			push bc
			ld c,a

t7sk4		push de
			exx
			
			ld a,h
t7smask2 .EQU $+1			
			xor %00111100		;00010100
			out (0),a
t7mute1 .EQU $			
			dec d				;self-modifying, dec d ~ $15
			jr nz,t7sk1
			ld h,a
			ld a,e
			pop de
			push de
			ld e,a

t7sk1		ld a,l
			xor %00111100
			out (0),a
t7mute2 .EQU $			
			dec e				;self-modifying, dec e ~ $1d
			jr nz,t7sk2
			ld l,a
			ld a,d
			pop de
			push de
			ld d,a

t7sk2		dec bc
			ld a,b
			or c
			exx
			jr nz,t7out
			
t7keyhd		exx
			ld a,$05					;revert code modifications
			ld (t7mute3),a
			or %00010000		;short ld a,$15
			ld (t7mute1),a
			ld a,$1d
			ld (t7mute2),a
			ld a,%00111100		;$3c
			ld (t7smask1),a
			ld (t7smask2),a
			xor a						;keyhandler
			pop de
			pop bc
			out (1),a					;mask port with 0
			in a,(1)					;read MODE key
			jr z,t7khdd

t7khdex		jp t7rdata

t7khdd		cpl
			bit 6,a						;test for keypresses on row MODE
			ret nz						;exit player if key pressed
			bit 5,a						;read [^] key
			call nz,holdlp
			bit 4,a
			jr nz,t7hold
			jr t7khdex

t7hold 		ld hl,(intbuf1)
			call derowlp
			ld (intbuf1),hl
			jr t7khdex
