;the file manager subroutine
;in: a - fm-mode: $00=load, $01=save, $02=del
;out: nothing
;destroyed: af,bc,de,hl


lsinit		push af
				bcall(_clrlcdf)
				ld de,$0253
				ld (pencol),de
				ld hl,menumsg+12
lsfmode			or a					;determine fm-mode
				jr z,lsmpri
				inc hl					;adjust message pointer
				inc hl
				inc hl
				dec a
				jr lsfmode
				
lsmpri			call dlm3				;print fm-mode			
				ld bc,freemem+1
				ld a,(bc)
				call num2hex
				ld de,$0839
				ld (pencol),de
				call nfstr
				dec bc
				ld a,(bc)
				call num2hex
				call nfstr
				ld hl,lsfree
				call dzmstr				;print " B FREE"
			pop af
			cp 1
			jp z,lssav
			push af
				
				ld hl,slottab			;setup slot list
				ld b,$01				;b = slot #
				ld de,$0204
				ld (pencol),de
				push de
lstabplp			ld a,(hl)				;check if slot exists
					ld d,a					;+if it doesn't, there will be 2 consecutive $00 bytes
					inc hl					;+
					ld a,(hl)				;+
					dec hl					;+
					or d
					jr z,lsnewsl			;if not, skip to print "NEW SLOT "
					ld a,b				
					inc b					;increment slot counter and max. slot #
					push hl
						ld hl,lsslot		;print "SLOT "
						call dzmstr
						call num2hex		;print slot #
						call nfstr
					pop hl
										;calculate slot length, omitted for now
					inc hl				;increase table pointer
					inc hl
				pop de
				ld a,6
				add a,d
				ld d,a
				ld (pencol),de
					push de
					jr lstabplp
				
lsnewsl			pop de
				ld a,$0b				;check if # slots has reached maximum (10)
				cp b
				jr z,lskeyhdj			;if so, skip to keyhandler
			;pop af					;check if fm-mode is SAV
			;cp 1
			;jr nz,lskeyhdi			;if not, skip to keyhandler
			;ld hl,lsnew				;otherwise, print "NEW SLOT "
			;call dzmstr
			;inc b

lskeyhdi	;push af
lskeyhdj		dec b
				dec b
				ld c,b				;save current slot # - 1 as max slot #
				ld b,0				;set current slot # to 0
				ld de,$0200
				push de
					ld (pencol),de
					ld a,$05
					call mcharput			;print cursor
				pop de
				
lskeyhd			ld a,%11111110			;mask keys
				out (1),a
				in a,(1)				;read arrow keys
				rra
				jr nc,lsDown
				rra
				rra
				rra
				jr nc,lsUp

				ld a,%11111101			;mask keys...
				out (1),a
				in a,(1)				
				bit 6,a					;read CLEAR key
				jr z,lsret				;if it is pressed, quit to menu				

				ld a,%10111111			;mask keys...
				out (1),a
				in a,(1)
				bit 4,a					;read Y= key
				jr z,lsact				;jump to mhxinit instead. Values: mxh2 $03, mhxinit $ea
				
				jr lskeyhd
				
lsDown			ld a,c					;check if max slot # reached
				cp b
				jr z,lskhdret			;if so, abort and return to keyhandler
				inc b
				ld (pencol),de
					push de
					ld a,$06			;delete cursor
					call mcharput
					pop de
				ld a,$06	
				add a,d					;update print position
				ld d,a
					push de
					ld a,$05
					ld (pencol),de
					call mcharput
					pop de
					
lskhdret			push bc
					call kdelay
					pop bc
				jr lskeyhd
				
lsUp			xor a					;check if top of list reached
				cp b
				jr z,lskhdret			;if so, abort and return to keyhandler
				dec b
				
					ld (pencol),de
					push de
					ld a,$06			;delete cursor
					call mcharput
					pop de
				ld a,d
				ld d,$06
				sub d					;update print position
				ld d,a
					push de
					ld a,$05
					ld (pencol),de
					call mcharput
					pop de
				
				jr lskhdret
				
lsret		pop af
			xor a
			ret

lsact		pop af					;check fm-mode and act accordingly
			or a
			jp z,lsld
			dec a
			jr z,lssav
			jp lsdel

lserror		ld hl,errls1
lserror1		push hl
				bcall(_clrlcdf)
				ld de,$0200
				ld (pencol),de
				call errsm				;print "FAIL: "
				pop hl
			call errwait			;print error message and display it for a few seconds

			ret						;abort
			
lssav		ld hl,freemem-4			;check if slot table is full
			ld b,(hl)
			inc hl
			ld a,(hl)
			ld hl,errls2
			or b
			jr nz,lserror1			;if yes, abort saving

			ld de,sdata				;make sure end marker is set, and no $fe byte is used
			ld hl,sdend-1
			ld a,(de)
			cp $ff					;check if song is empty
			jr z,lserror			;abort if necessary
lselp		ld a,(de)
			inc a					;check if $ff marker found
			jr z,lsedone			;if yes, we're ready for saving
			inc a					;check if $fe byte found
			jr z,lserror			;if yes, abort
			inc de
			push hl
			ccf
			sbc hl,de				;check if all song data has been checked
			pop hl
			jr nc,lselp
			jr lserror				;if no $ff marker found, abort
			
lsedone		cp h					;??? why we need this is unclear, but it doesn't work without
			ld hl,sdata-1			;position of end marker is in de
			ccf			
			ex de,hl				;now pos. of end marker is in hl, de = sdata

			sbc hl,de				;calculate length of data to be saved
			ld b,h					;store length in bc
			ld c,l
			inc bc					;adding 2 bytes for engine and speed values
			inc bc
			ld hl,(freemem)
			sbc hl,bc				;check if enough free memory is available
			jr nc,lsizeok			;if not, abort
			ld hl,errls2
			jr lserror1
			
lsizeok		inc hl
			ld (freemem),hl			;save new free mem value
			ld hl,sdata
			ld de,slottab
			ld (tabpos),de
			ld de,savebuf			
				push hl				;get save position from slot table
				ld hl,slottab
				ld a,(hl)
				or a
				jr z,lposd			;if slot table is empty, save pos = savebuf
lposlp			ld a,(hl)
				inc hl
				or a
				jr nz,lposlp		;read table until $00 found
				dec hl
				dec hl				;why on earth we can't use lputslot subroutine here is a mystery
				ld d,(hl)			;get pointer into de
				dec hl
				ld e,(hl)
				inc hl
				inc hl
				ld (tabpos),hl		;get next pointer into (tabpos)
				inc bc
lposd			pop hl

			ld a,(engpnt)		;NEW: save engine and speed
			ld (de),a
			inc de
			ld a,(spdpnt)
			ld (de),a
			inc de
			dec bc				;readjust copy block size
			dec bc
			dec bc
			ldir
tabpos .EQU $+2
			ld (slottab),de			;save block end to slot table
			ld de,$0200
			ld hl,errls3			;print "Success!"
			ld (pencol),de
			call errwait
			ret
			
lsld		call lslotdet			;setup hl as slot table pointer, a=0, de=savebuf
			or c					;check if we're loading from the first slot
			call nz,lputslot
			
lldfirst	ld c,(hl)				;put block end into bc
			inc hl
			ld b,(hl)
			ld h,b
			ld l,c					;now block end is in hl
			ccf
			sbc hl,de				;block end - prev. block end + 1 = block length
			inc hl
			ld b,h					;load block length into bc
			ld c,l
			
			dec bc
			dec bc
			
			ld hl,sdata				;load write pointer
			ex de,hl				;and put it in de
			
			ld a,(hl)				;NEW: read engine and speed
			ld (engpnt),a
			inc hl
			ld a,(hl)
			ld (spdpnt),a
			inc hl
			
			ldir					;copy stuff
			ld a,$ff				;write end marker
			ld (de),a
			ret

lsdel		call lslotdet			;setup hl as slot table pointer, set a=0
				push hl
				or c				;check if we're deleting the first slot
				call nz,lputslot	;de = end of previous slot or savebuf
				inc de				;???
				ld c,(hl)
				inc hl
				ld b,(hl)
				ld h,b
				ld l,c
				inc hl				;hl = start of next slot
				
					push hl
					ccf
					sbc hl,de
					ld b,h
					ld c,l
					pop hl			;bc = cut length
					;dec bc			;??? does this fix the "deleting too much" problem? NOPE
					push bc
					
					;ldir				;copy bytes
lsdlpp				ld a,(hl)
					cp $ff
					jr z,lsddone		;if final end marker reached, we're done
					ld (de),a
					inc hl
					inc de
					jr lsdlpp
										;clear rest of memory
lsddone				
					pop bc
				pop de				;de = table pos to be deleted
				push bc
					push de
					ccf
					ld hl,freemem-1
					sbc hl,de
					ld b,h
					ld c,l
					ld h,d
					ld l,e
					inc hl
					inc hl
					ldir

					pop de
				pop bc
				
			ex de,hl			;get table pointer in hl
tadjxlp		ld e,(hl)			;load value in de
			inc hl
			ld d,(hl)
			ld a,d
			or e
			jr z,ltadjd			;if it is 0, we're done
			ex de,hl
			ccf
			sbc hl,bc			;subtract del.block length from position
			ex de,hl			;get result in hl
			ld (hl),d			;store it at (de)
			dec hl
			ld (hl),e
			inc hl
			inc hl
			jr tadjxlp
				
ltadjd		ld hl,(freemem)		;adjust freemem value
			ccf
			add hl,bc
			ld (freemem),hl
			
			ret
			
lslotdet	ld de,savebuf
			ld hl,slottab			;hl = slot table pointer
			ld c,b					;b holds current slot #, copy to c
			ld b,0					
			sla c					;c*2 = offset in slot table
			add hl,bc				;add c to slot table pointer
			xor a
			ret
			
lputslot	dec hl					;put end value of previous slot into de
			ld d,(hl)
			dec hl
			ld e,(hl)
			inc hl					;readjust table pointer
			inc hl
			ret

slottab .EQU $						;slot table containing block end addresses + 2 bytes padding
			.BLOCK 22				;still 2 bytes shorter than adjusting values when moving table entries
freemem .EQU $
			.db $10,$27				;bytes free (initially $2710 bytes)
			
errls1		.db "bad data",0
errls2		.db "mem full",0
errls3		.db "Success!",0
			