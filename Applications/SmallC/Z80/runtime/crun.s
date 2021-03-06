;
;	Runtime support routines for the compiler itself. These are
;	generated by the compiler in the compiled code
;
;	Converted from 8080 to Z80 and tidied up a bit. Some optimized
;	Z80 routines used.
;
;	
;
	.code

	.export	ccgchar
	.export	ccgint
	.export	ccpchar
	.export	ccpint
	.export	ccsxt
	.export	ccor
	.export	ccand
	.export	ccxor
	.export	cceq
	.export	ccne
	.export	ccgt
	.export	ccle
	.export	ccge
	.export	cclt
	.export	ccuge
	.export ccult
	.export ccugt
	.export ccule
	.export ccasr
	.export	ccasl
	.export	ccsub
	.export	ccneg
	.export cccom
	.export	cclneg
	.export	ccboot
	.export	ccmul
	.export	ccumul
	.export	ccdiv
;	.export	ccudiv
	.export	cccase
	.export	cccallhl

ccgchar:
	ld	a,(hl)
ccsxt:
	ld	l,a
	rlca
	sbc	a,a
	ld	h,a
	ret
ccgint:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret
ccpchar:
	ld	a,l
	ld	(de),a
	ret
ccpint:
	ld	a,l
	ld	(de),a
	inc	de
	ld	a,h
	ld	(de),a
	ret
ccor:	ld 	a,h
	or	d
	ld	h,a
	ld	a,l
	or	e
	ld	l,a
	ret
ccxor:	ld	a,h
	xor	d
	ld	h,a
	ld	a,l
	xor	e
	ld	e,a
	ret
ccand:	ld	a,h
	and	d
	ld	h,a
	ld	a,l
	and	e
	ld	e,a
	ret
cceq:	call	cccmp
	ret	z
	dec	hl
	ret
ccne:	call	cccmp
	ret	nz
	dec	hl
	ret
ccgt:	ex	de,hl
	call	cccmp
	ret	c
	dec	hl
	ret
ccle:	call	cccmp
	ret	c
	ret	z
	dec	hl
	ret
ccge:	call	cccmp
	ret	nc
	dec	hl
	ret
cclt:	call	cccmp
	ret	c
	dec	hl
	ret
ccuge:	call	ccucmp
	ret	nc
	dec	hl
	ret
ccult:	call	ccucmp
	ret	c
	dec	hl
	ret
ccule:	call	ccucmp
	ret	z
	ret	c
	dec	hl
	ret
cccmp:
	ld	a,e
	sub	l
	ld	e,a
	ld	a,d
	sub	h
	ld	hl,1
	jp	m,cccmp1
	or	e
	ret
cccmp1:	or	e
	scf
	ret

ccucmp:
	ld	a,d
	cp	h
	jr	nz,ccret1
	ld	a,e
	cp	l
ccret1:
	ld	hl,1
	ret

ccasr:	ld	a,l
	or	a
	ret	z
ccasrl:
	sra	d
	rr	e
	dec	a
	jr	nz,ccasrl
	ret
ccasl:	ld	a,l
	or	a
	ret	z
ccasll:	sla	e
	rl	d
	dec	a
	jr	nz,ccasll
	ret
ccsub:	ex	de,hl
	or	a
	sbc	hl,de
	ret
ccneg:	call	cccomm
	inc	hl
	ret
cccom:	ld	a,h
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld	l,a
	ret
cclneg:	ld	a,h
	or	l
	jr	nz,ret0
	inc	hl
	ret
ret0:	ld	hl,0
	ret
ccbool:	ld	a,h
	or	l
	ret	z
	ld	hl,#1
	ret

;
;	These might want to live somewhere else as they are bigger
;
;	HL = DE * HL (signed)
;
ccumul:
ccmul:	push	bc
	ld	a,h
	ld	c,l
	ld	b,16
ccmul_1:
	add	hl,hl
	sla	c
	rla
	jr	nc, ccmul_2
	add	hl,de
ccmul_2:
	djnz	ccmul_1
	pop	bc
	ret

;
;	Outputs HL = DE/HL and DE = DE % HL
;
ccudiv:
	push	bc
	ex	de,hl
	ld	a,h
	ld	b,8
	ld	c,l
	ld	hl,0
ccdiv_1:
	rla
	adc	hl,hl
	sbc	hl,de
	jr	nc, ccdiv_2
	add	hl,de
ccdiv_2:
	djnz	ccdiv_1
	rla
	cpl
	ld	b,a
	ld	a,c
	ld	c,b
	ld	b,8
ccdiv_3:
	rla
	adc	hl,hl
	sbc	hl,de
	jr	nc, ccdiv_4
	add	hl,de
ccdiv_4:
	djnz	ccdiv_3
	rla
	cpl
	ex	de,hl
	ld	h,c
	ld	l,a
	pop	bc
	ret

;
;	As above but signed
;
;ccdiv:	TODO

cccase:
	ex	de,hl
	pop	hl
cccase1:
	call	cccase4
	ld	a,e
	cp	c
	jr	nz,cccase2
	ld	a,d
	cp	b
	jr	nz,cccase2
	call	cccase4
	jr	z,cccase3
	push	bc
	ret
cccase2:
	call	cccase4
	jr	nz,cccase1
cccase3:
	dec	hl
	dec	hl
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	ex	de,hl
cccallhl:
	jp	(hl)
cccase4:
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a,c
	or	b
	ret
