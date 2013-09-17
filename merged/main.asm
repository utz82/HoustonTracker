;*************************************************************************************
;HoustonTracker by utz                         https://github.com/utz82/HoustonTracker
;Released under LGPL v3
;*************************************************************************************


;#define LIGHT					;uncomment to compile "light" version
;#define R196					;uncomment to compile for Parcus

#ifdef LIGHT
MBUF = 4999
BBUF = 5002
MAXL = $03de
#endif

#define .db .byte
#define .dw .word

;*************************************************************************************
;target-specific declarations
;*************************************************************************************

#ifdef TI82
#ifdef R196
#include CRASH196.INC
LPON = $d3
LPOFF = $d0
LPL = $d1
LPR = $d2
LPSW = $03
LPSWL = $02
LPSWR = $01
#else
#include CRASH82.INC
LPON = $fc
LPOFF = $c0
LPL = $d4
LPR = $e8
LPSW = $3c
LPSWL = %00101000
LPSWR = %00010100
LMSK = $fcfc
#endif

#ifndef LIGHT
MBUF = 9999
BBUF = 10002
MAXL = $07c6
#endif			
#endif

;*************************************************************************************

#ifdef TI83
#include ion.inc
#define GRAF_CURS pencol
#define APD_BUF saferam1
#define GRAPH_MEM graph_mem
LPON = $d3
LPOFF = $d0
LPL = $d1
LPR = $d2
LPSW = $03
LPSWL = $02
LMSK = $d3d3
LPSWR = $01
#ifndef LIGHT
MBUF = 8999
BBUF = 9002
MAXL = $06fe
#endif
			
			.ORG	progstart
			xor a
			jr	nc,begin
			ret	
#endif

;*************************************************************************************

#ifdef TI83P
#include ion2.inc
#define GRAF_CURS pencol
#define APD_BUF saferam1
#define GRAPH_MEM graph_mem
LPON = $03
LPOFF = $00
LPL = $01
LPR = $02
LPSW = $03
LPSWL = $02
LMSK = $0303
LPSWR = $01
#ifndef LIGHT
MBUF = 7999
BBUF = 8002
MAXL = $0636
#endif
			
			.ORG	progstart-2
			.db $BB,$6D
			xor a
			jr	nc,begin
			ret			
#endif

;*************************************************************************************

#ifdef TI73
#include mallard.inc
#define GRAF_CURS pencol
#define APD_BUF saferam1
#define GRAPH_MEM graph_mem
LPON = $03
LPOFF = $00
LPL = $01
LPR = $02
LPSW = $03
LPSWL = $02
LMSK = $0303
LPSWR = $01			
#ifndef LIGHT
MBUF = 7999
BBUF = 8002
MAXL = $0636
#endif
			
			.ORG userMem
			.db $D9,$00,"Duck"
			.dw begin
#endif

;*************************************************************************************
;header
;*************************************************************************************

.DB "houstontracker 0.3", 0


begin		
			push ix			;wrapper
			ld (sbuf),sp		;probably not needed, but let's not take a risk here
			call init
			ld sp,(sbuf)
			pop ix
			res 3,(iy+$05)
			ret

;***********************************************************************************
;initialize buffers and set up the initial screen
;***********************************************************************************			
			
			#include "Housto~1/merged/scrinit.asm"
			
;***********************************************************************************
;main key handler
;***********************************************************************************			
			
			#include "Housto~1/merged/keyhd.asm"
			
;***********************************************************************************
;hexadecimal input handler
;***********************************************************************************

			#include "Housto~1/merged/hexinput.asm"		

;***********************************************************************************
;scrolling routines		
;***********************************************************************************

			#include "Housto~1/merged/scroll.asm"
			
;***********************************************************************************
;various calls to ROM_CALLs
;***********************************************************************************

			#include "Housto~1/merged/romcall.asm"
			
;***********************************************************************************
;routine for printing a single line of song data
;***********************************************************************************

			#include "Housto~1/merged/newline.asm"
			
;***********************************************************************************
;cursor printing routine
;***********************************************************************************
			
			#include "Housto~1/merged/cursor.asm"

;***********************************************************************************
;standard delay (used by multiple routines)
;***********************************************************************************
			
			#include "Housto~1/merged/delay.asm"

;***********************************************************************************
;determine row start point
;***********************************************************************************

			#include "Housto~1/merged/rowcheck.asm"

;***********************************************************************************
;menu subroutine
;***********************************************************************************

			#include "Housto~1/merged/menu.asm"

;***********************************************************************************
;various pointers and temporary buffers
;***********************************************************************************
			
			#include "Housto~1/merged/buffers.asm"
			
;***********************************************************************************
;Various Subroutines
;***********************************************************************************

mhexkhd						;Routine for handling hex input in menu functions
			#include "Housto~1/merged/mhexkhd.asm"

num2hex						;the number to character code converter
			#include "Housto~1/merged/num2hex.asm"

linediv						;the 16-bit division subroutine
			#include "Housto~1/merged/linediv.asm"

hex2ln						;the ascii to line number converter
			#include "Housto~1/merged/hex2ln.asm"

etrap						;the error trapping subroutine
			#include "Housto~1/merged/etrap.asm"

ldsav						;the file manager subroutine
			#include "Housto~1/merged/ldsav.asm"

#ifdef R196

player
			#include "Housto~1/merged/tim4.asm"	

player2						;engine 2
			#include "Housto~1/merged/tim5.asm"	

player3						;engine 3
			#include "Housto~1/merged/tim7.asm"

#else

player						;engine 1 and drum routines
			#include "Housto~1/merged/tim4.asm"	

player2						;engine 2
			#include "Housto~1/merged/tim5.asm"	

player3						;engine 3
			#include "Housto~1/merged/tim7.asm"
#endif	

;spl						;sample playback, unfinished
;#include "Housto~1/ti82/smp.asm"

;***********************************************************************************
;song data buffer
;***********************************************************************************

engpnt .EQU $
			.db $01			;this holds the engine currently used

spdpnt .EQU $				;this holds the song speed
			.db $10
			
sdata .EQU $
			.db $ff			;initial data end marker
			.BLOCK MBUF
sdend		
			.db $ff			;song data end marker

savebuf .EQU $
			.BLOCK BBUF

saveend		
			.db $ff

#ifndef TI82
.END
#ifndef TI73
	.dw $0000
.END
#endif
#endif
