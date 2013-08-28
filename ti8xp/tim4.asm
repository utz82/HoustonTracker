pbegin	di
		call pinit
		ei
pex .EQU $
		ret nz
		ld hl,sdata
		jr pbegin

pinit	ld a,(spdpnt)			;read speed byte
		inc a
		ld b,a					;
		ld c,a					;now bc1 holds speed counter
		
rdata	ld a,(hl)				;load drum byte
		cp $ff					;if it is $ff
		ret z					;exit player
		
		srl a					;check for speed change
		srl a
		srl a
		srl a
		or a
		jr z,t4ssk1
		inc a
		ld b,a					;
		ld c,a					;now bc1 holds speed counter
t4ssk1	call dtrig
		cpl						
		push bc					;preserve speed counter
		ld d,a					;load note byte to counter d1
		inc hl					;increase data pointer
		ld a,(hl)				;load note byte ch2
		cpl
		ld e,a					;to counter e1
		cp $ff
		jr nz,skk1
		ld e,d
skk1	ld a,d
		cp $ff
		jr nz,skk1a
		ld d,e
skk1a	inc hl					;increase pointer
		ld b,d					;backup de1 in bc1
		ld c,e
		push hl					;preserve
		exx						;switch to register set 2
		pop hl					;retrieve data pointer
		ld a,(hl)				;load note byte ch3
		cpl
		ld d,a					;to counter d2
		inc hl					;increase data pointer
		ld a,(hl)				;load note byte ch4
		cpl
		ld e,a					;to counter e2
		cp $ff
		jr nz,skk2
		ld e,d
skk2	ld a,d
		cp $ff
		jr nz,skk2a
		ld d,e
skk2a	inc hl					;skip drum for now
		
		ld b,d					;backup de2 in bc2
		ld c,e
		ld (intbuf1),bc
		
sndlp	ld bc,(intbuf1)		;20
		ld a,$00			;7	;output mask set to both lines high (sound off)		
		dec d				;4	;decrement counter d2
		jr nz,skip1
		or %00000010		;7	;if 0 reached, switch output mask line2
		ld d,b				;4 
		
skip1	dec e				;4	;decrement counter e2
		jr nz,chkmt1		;12/7
		or %00000010		;7	;if 0 reached, switch output mask line2
		ld e,c				;4

chkmt1 	ex af,af'			;4	;to af'
		inc bc
		ld a,b				;4	;if both channels were muted...
		or c				;4
		jr nz,skip2x		;12/7
		ex af,af'			;4
		ld a,$00			;7
		ex af,af'			;4
		nop					;4
		nop					;4
		jr skip2			;12 \ 40
skip2x	call sadj			;+27 \ 39
skip2	dec bc				;6
		ex af,af'			;4	;and back to af... phewww ;)
		push hl				;11
		exx					;4	;switch to register set 1

		dec d				;4	;decrement counter d1
		jr nz,pskip3		;12/7
		or %00000001		;7	;if 0 reached, switch output mask line1
		ld d,b				;4	;restore counter
							;ignore 13t overhead

pskip3	dec e				;4	;decrement counter e1
		jr nz,chkmt2		;12/7
		or %00000001		;7	;if 0 reached, switch output mask line1
		ld e,c				;4	;restore counter

chkmt2	pop hl				;10
		ex af,af'			;4	;to af'
		inc bc
		ld a,b				;4	;if both channels were muted...
		or c				;4
		jr nz,outpx			;12/7
		ex af,af'			;4	;to af
		res 0,a				;8	;check if line1 is on
		;res 4,a				;8
		dec bc				;6

chm2a	ex af,af'			;4	;to af'	
		jr outp				;12 \ 47
outpx	call sadj			;+27 
		dec bc				;6
		;nop					;4
outp	ex af,af'			;4	;and back to af
		out (0),a			;11
		exx					;4	;switch to register set 2
		pop bc				;10
		dec bc				;6
		push bc				;11
		ld a,b				;4
		or c				;4
		jr nz,sndlp			;12/7 
							;368/+9 + overhead

keyhd	exx
		pop bc
		ld a,(spdpnt)
		ld b,a
		ld c,a
		xor a						;fast masking
		out (1),a					;mask port with 0
		in a,(1)					;read MODE key
		cpl
		bit 6,a						;read CLEAR key
		ret nz						;exit player if key pressed
		bit 5,a						;read [^] key
		call nz,holdlp
		bit 4,a
		call nz,derowlp
		jp rdata

dtrig	ld a,(hl)

		push hl
		ld hl,$3000
		or $f0					;clear upper nibble
		xor $f0
		dec a
		call z,drum1
		dec a
		call z,drum2
		dec a
		call z,drum3
		pop hl
		inc hl
		ld a,(hl)				;load note byte ch1		
		ret		
		
		
drum3	dec b
		push bc
		;ld a,$d0
		xor a
		ld b,$20
dlp5	ex af,af'
		ld a,r
dlp6	dec a
		jr nz,dlp6
		ex af,af'
		out (0),a
		xor %00000011
		push hl
		pop hl
		djnz dlp5
		pop bc
		ret			
		
		
drum2	dec b				;4
		push bc				;11
		ld bc,$032D			;10
dlp2	call dlpx			;17+72
		ld a,b				;4
		or c				;4
		jr nz,dlp2			;12/7 \101*
		pop bc				;10
sadj	ret					;10 \+52

drum1	dec b				;4		;-368*256=94028
		push bc				;11
		ld de,$0809			;10
		ld b,72				;7
dlp3	call dlpx			;17+100 [assumed +72]
dlp4	ld a,$03			;7		
		out (0),a			;11
		dec d				;4
		jr nz,dlp4			;12/7
		ld d,e				;4	
		inc e				;4
		djnz dlp3			;13/8	;50*??? whatever, math sucks
		pop bc				;10
		ret					;10
		
dlpx	ld a,(hl)			;7
		or $fc					;4
		xor $fc					;4
		push hl
		pop hl
		push hl
		pop hl
		out (0),a			;11
		inc hl				;6
		dec bc				;6
		ret					;10 \ 100 (wrongly assumed 72)
