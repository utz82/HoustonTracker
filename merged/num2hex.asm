;in: a - number to convert
;out: ascii in numfld & numfld+1
			push af
			ld de,numfld			;convert hex to ascii output
			call	num1
			pop af
			;ld	a,(hl)
			call	num2
			ret
		
num1		rra
			rra
			rra
			rra
num2		or $f0
			daa
			add	a,$a0
			adc	a,$40

			ld	(de),a
			inc	de
			ret
