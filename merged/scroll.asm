;main screen scrolling routine

scrlup		
			ld hl,(sngpnt)			;check if we're at the last line of song data
			push hl
			ld de,sdend-5				
			sbc hl,de
			pop hl
			ret nc					;if so, don't scroll
			ld de,$0005				;update data pointer
			add hl,de
			call backupdsp


			ld hl,GRAPH_MEM+24+72	;chickendude's optimized scrolly
			ld de,GRAPH_MEM+24
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
#ifdef TI82		
			call CR_GRBCopy			;... it's time to print the screen
#else
			call ionFastCopy
#endif
			ld de,$3800				;printing pos = start of lowest line
			call newline			;now let's fetch the correct line number
			ret

			
scrldown	
			ld hl,(sngpnt)			;check if we're at the first line of song data
			push hl
			ld de,sdata+5				
			sbc hl,de
			pop hl
			ret c					;if so, don't scroll
			ld de,$0005				;update data pointer
			sbc hl,de
			call backupdsp

			ld hl,GRAPH_MEM+768-24-72-5	;chickendude's optimized scrolly again
			ld de,GRAPH_MEM+768-24-5	;skip an extra 4 bytes (right side screen)
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
			
#ifdef TI82		
			call CR_GRBCopy			;... it's time to print the screen
#else
			call ionFastCopy
#endif
			ld de,$0200				;printing pos = start of top line
			call newline			
			ret	

backupdsp	
			ld (sngpnt),hl
#ifdef TI82
			ROM_CALL(BACKUP_DISP)	;copy current screen to APD_BUF
#else			
			bcall(_savedisp)	;copy current screen to saferam1
#endif
			ld bc,768
			ld hl,APD_BUF
			ld de,GRAPH_MEM
			ldir
			ret