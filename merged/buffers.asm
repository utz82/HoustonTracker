
			
intbuf1 .EQU $						
							;temporary buffer to hold song data pointer
			nop				;while calculating the row number
			nop				;also holds block length during copy
			
sngpnt .EQU $						
							;pointer to current position in song data
			nop
			nop
			
numfld .EQU $						
							;temporary buffer for 2 character codes
			nop
			nop
			nop				;let's make it a 0-terminated string

colval .EQU $						;this byte tells us which type of column is
			nop				;currently being edited
			
chmask .EQU $						;channel mute mask
			nop			

pbuf .EQU $						;temporary buffer for single row playback
			nop				;this byte is also used by menu routine
			nop
			nop
			nop
			nop
			.db $ff				;end marker

csrpos .EQU $						;cursor position
			.db $0e,$02

sbuf .EQU $
			nop				;stack pointer buffer
			nop

spdmsg								;this is obvious ;)
			.db "TEMPO",0
;various buffers

engmsg		
			.db "ENGINE",0

chnmsg		
			.db "CH D1234",0

menumsg		
			.db "JMP"
			.db "CPY"
			.db "CUT"
			.db "ZAP"
			.db "LD "
			.db "SAV"
			.db "DEL"

cmsg2		
			.db "PST"
cmsg3		
			.db "INS"			
			
msfrom		
			.db " FROM:",0
msto		
			.db " TO:",0
mslen		
			.db "LENGTH: ",0
msall		
			.db " ALL",0
msat		
			.db " AT:",0
			
err1		
			.db "FAIL: ",0
err2d		
			.db "end <= start",0
err2e		
			.db "target w/in source",0
err3		
			.db $c1					;"[" is evaluated incorrectly by Crash
			.db "Y=] CONFIRM   "
			.db	$c1
			.db "CLEAR] ABORT",0
			
;lsnew		
			.db "NEW "
lsslot		
			.db "SLOT ",0
lsfree		
			.db " B FREE",0			
			
cmsgpnt		
			nop
			nop
