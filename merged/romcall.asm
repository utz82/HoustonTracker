;ROM call handler


#ifdef TI82

nfstde		
			ld (GRAF_CURS),de
nfstr		
			ld hl,numfld
dzmstr		
			ROM_CALL(D_ZM_STR)
			ret
dlmde		
			ld (GRAF_CURS),de
dlm3		
			ld b,3			
dlmstr		
			ROM_CALL(D_LM_STR)
			ret
nfmch		
			ld a,(numfld+1)
mcharput	
			ROM_CALL(M_CHARPUT)
			
#endif


#ifdef TI83
nfstde			ld (pencol),de
nfstr			ld hl,numfld
dzmstr			bcall(_vputs)
			ret
dlmde			ld (pencol),de
dlm3			ld b,3			
dlmstr			bcall(_VPutSN)
			ret
nfmch			ld a,(numfld+1)
mcharput		bcall(_vputmap)

#endif		

#ifdef TI83P
nfstde			ld (pencol),de
nfstr			ld hl,numfld
dzmstr			bcall(_vputs)
			ret
dlmde			ld (pencol),de
dlm3			ld b,3			
dlmstr			bcall(_VPutSN)
			ret
nfmch			ld a,(numfld+1)
mcharput		bcall(_vputmap)
#endif


#ifdef TI73
nfstde			ld (pencol),de
nfstr			ld hl,numfld
dzmstr			bcall(_vputs)
			ret
dlmde			ld (pencol),de
dlm3			ld b,3			
dlmstr			bcall(_VPutSN)
			ret
nfmch			ld a,(numfld+1)
mcharput		bcall(_vputmap)

#endif
	
			ret
