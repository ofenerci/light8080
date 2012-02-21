; <><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
; <><><><><>   CP/M Large String Space Version   <><><><><>
; <><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
;
	code
	org #0000
	ld hl,3072
	ld sp,hl
	call __main
;//---------------------------------------------------------------------------------------
;//	Project:			light8080 SOC		WiCores Solutions 
;//
;//	File name:			hello.c 				(February 04, 2012)
;//
;//	Writer:				Moti Litochevski 
;//
;//	Description:
;//		This file contains a simple program written in Small-C that sends a string to 
;//		the UART and then switches to echo received bytes. 
;//
;//	Revision History:
;//
;//	Rev <revnumber>			<Date>			<owner> 
;//		<comment>
;//---------------------------------------------------------------------------------------
;#include ..\tools\c80\c80.lib
;#asm
;
;------------------------------------------------------------------
;	Small-C  Run-time Librray
;
;	V4d	As of July 16, 1980 (gtf)
;		   Added EXIT() function
;------------------------------------------------------------------
;
;Fetch a single byte from the address in HL and sign extend into HL
ccgchar: 
	ld a,(hl)
ccsxt:	
	ld l,a
	rlca
	sbc	a
	ld	h,a
	ret
;Fetch a full 16-bit integer from the address in HL
ccgint: 
	ld a,(hl)
	inc	hl
	ld	h,(hl)
	ld l,a
	ret
;Store a single byte from HL at the address in DE
ccpchar: 
	ld	a,l
	ld	(de),a
	ret
;Store a 16-bit integer in HL at the address in DE
ccpint: 
	ld	a,l
	ld	(de),a
	inc	de
	ld	a,h
	ld	(de),a
	ret
;Inclusive "or" HL and DE into HL
ccor:	
	ld	a,l
	or	e
	ld l,a
	ld	a,h
	or	d
	ld	h,a
	ret
;Exclusive "or" HL and DE into HL
ccxor:	
	ld	a,l
	xor	e
	ld l,a
	ld	a,h
	xor	d
	ld	h,a
	ret
;"And" HL and DE into HL
ccand:	
	ld	a,l
	and	e
	ld l,a
	ld	a,h
	and	d
	ld	h,a
	ret
;Test if HL = DE and set HL = 1 if true else 0
cceq:	
	call cccmp
	ret z
	dec	hl
	ret
;Test if DE ~= HL
ccne:	
	call cccmp
	ret nz
	dec	hl
	ret
;Test if DE > HL (signed)
ccgt:	
	ex de,hl
	call cccmp
	ret c
	dec	hl
	ret
;Test if DE <= HL (signed)
ccle:	
	call cccmp
	ret z
	ret c
	dec hl
	ret
;Test if DE >= HL (signed)
ccge:	
	call cccmp
	ret nc
	dec hl
	ret
;Test if DE < HL (signed)
cclt:	
	call cccmp
	ret c
	dec hl
	ret
; Signed compare of DE and HL
; Performs DE - HL and sets the conditions:
;	Carry reflects sign of difference (set means DE < HL)
;	Zero/non-zero set according to equality.
cccmp:
	ld	a,e
	sub	l
	ld	e,a
	ld	a,d
	sbc	h
	ld	hl,1
	jp	m,cccmp1
	or	e	;"OR" resets carry
	ret
cccmp1: 
	or	e
	scf		;set carry to signal minus
	ret
;Test if DE >= HL (unsigned)
ccuge:	
	call ccucmp
	ret nc
	dec hl
	ret	
;Test if DE < HL (unsigned)
ccult:	
	call ccucmp
	ret c
	dec hl
	ret
;Test if DE > HL (unsigned)
ccugt:	
	ex de,hl
	call ccucmp
	ret c
	dec hl
	ret
;Test if DE <= HL (unsigned)
ccule:	
	call ccucmp
	ret z
	ret c
	dec hl
	ret
;Routine to perform unsigned compare
;carry set if DE < HL
;zero/nonzero set accordingly
ccucmp: 
	ld	a,d
	cp	h
	jp	nz,$+5
	ld	a,e
	cp	l
	ld	hl,1
	ret
;Shift DE arithmetically right by HL and return in HL
ccasr:	
	ex	de,hl
	ld	a,h
	rla
	ld	a,h
	rra
	ld	h,a
	ld	a,l
	rra
	ld	l,a
	dec	e
	jp	nz,ccasr+1
	ret
;Shift DE arithmetically left by HL and return in HL
ccasl:	
	ex	de,hl
	add	hl,hl
	dec	e
	jp	nz,ccasl+1
	ret
;Subtract HL from DE and return in HL
ccsub:	
	ld	a,e
	sub	l
	ld l,a
	ld	a,d
	sbc	h
	ld	h,a
	ret
;Form the two's complement of HL
ccneg:	
	call cccom
	inc	hl
	ret
;Form the one's complement of HL
cccom:	
	ld	a,h
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld l,a
	ret
;Multiply DE by HL and return in HL
ccmult: 
	ld	b,h
	ld	c,l
	ld	hl,0
ccmult1: 
	ld	a,c
	rrca
	jp	nc,$+4
	add	hl,de
	xor	a
	ld	a,b
	rra
	ld	b,a
	ld	a,c
	rra
	ld	c,a
	or	b
	ret z
	xor	a
	ld	a,e
	rla
	ld	e,a
	ld	a,d
	rla
	ld	d,a
	or	e
	ret z
	jp	ccmult1
;Divide DE by HL and return quotient in HL, remainder in DE
ccdiv:	
	ld	b,h
	ld	c,l
	ld	a,d
	xor	b
	push af
	ld	a,d
	or	a
	call m,ccdeneg
	ld	a,b
	or	a
	call m,ccbcneg
	ld	a,16
	push af 
	ex	de,hl
	ld	de,0
ccdiv1: 
	add hl,hl 
	call ccrdel
	jp	z,ccdiv2
	call cccmpbcde
	jp	m,ccdiv2
	ld	a,l
	or	1
	ld l,a
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
ccdiv2: 
	pop af
	dec	a
	jp	z,ccdiv3
	push af
	jp	ccdiv1
ccdiv3: 
	pop af
	ret	p
	call ccdeneg
	ex de,hl
	call ccdeneg
	ex de,hl
	ret
ccdeneg: 
	ld	a,d
	cpl
	ld	d,a
	ld	a,e
	cpl
	ld	e,a
	inc	de
	ret
ccbcneg: 
	ld	a,b
	cpl
	ld	b,a
	ld	a,c
	cpl
	ld	c,a
	inc	bc
	ret
ccrdel: 
	ld	a,e
	rla
	ld	e,a
	ld	a,d
	rla
	ld	d,a
	or	e
	ret
cccmpbcde: 
	ld	a,e
	sub	c
	ld	a,d
	sbc	b
	ret
;// UART IO registers 
;port (128) UDATA;		// uart data register used for both transmit and receive 
;port (129) UBAUDL;		// low byte of baud rate register 
;port (130) UBAUDH;		// low byte of baud rate register 
;port (131) USTAT;		// uart status register 
;// digital IO ports registers 
;port (132) P1REG;     	// output port1 - used as first attenuator control 
;port (133) P2REG;		// output port2 - used as low digit LCD 
;port (134) P3REG;		// output port3 - used as high digit LCD 
;port (135) P4REG;		// output port4 
;// simulation end register 
;// writing any value to this port will end the verilog simulation when using tb_l80soc 
;// test bench. 
;port (255) SIMEND;
;// registers bit fields definition 
;// uart status register decoding 
;#define UTXBUSY		1
;#define URXFULL		16
;// globals 
;char rxbyte;		// byte received from the uart 
;int tstary[2] = {1234, 5678};
;//---------------------------------------------------------------------------------------
;// send a single byte to the UART 
;sendbyte(by) 
__sendbyte:
;char by;
;{
;	while (USTAT & UTXBUSY);
cc2:
	in a,(131)
	call ccsxt
	push hl
	ld hl,1
	pop de
	call ccand
	ld a,h
	or l
	jp z,cc3
	jp cc2
cc3:
;	UDATA = by;
	ld hl,2
	add hl,sp
	call ccgchar
	ld a,l
	out (128),a

;}
	ret
;// check if a byte was received by the uart 
;getbyte()
__getbyte:
;{
;	if (USTAT & URXFULL) {
	in a,(131)
	call ccsxt
	push hl
	ld hl,16
	pop de
	call ccand
	ld a,h
	or l
	jp z,cc4
;		rxbyte = UDATA;
	in a,(128)
	call ccsxt
	ld a,l
	ld (__rxbyte),a
;		return 1;
	ld hl,1
	ret
;	} 
;	else 
	jp cc5
cc4:
;		return 0;
	ld hl,0
	ret
cc5:
;}
	ret
;// send new line to the UART 
;nl()
__nl:
;{
;	sendbyte(13);
	ld hl,13
	push hl
	call __sendbyte
	pop bc
;	sendbyte(10);
	ld hl,10
	push hl
	call __sendbyte
	pop bc
;}
	ret
;// sends a string to the UART 
;printstr(sptr)
__printstr:
;char *sptr;
;{
;	while (*sptr != 0) 
cc6:
	ld hl,2
	add hl,sp
	call ccgint
	call ccgchar
	push hl
	ld hl,0
	pop de
	call ccne
	ld a,h
	or l
	jp z,cc7
;		sendbyte(*sptr++);
	ld hl,2
	add hl,sp
	push hl
	call ccgint
	inc hl
	pop de
	call ccpint
	dec hl
	call ccgchar
	push hl
	call __sendbyte
	pop bc
	jp cc6
cc7:
;}
	ret
;// sends a decimal value to the UART 
;printdec(dval) 
__printdec:
;int dval;
;{
;	if (dval<0) {
	ld hl,2
	add hl,sp
	call ccgint
	push hl
	ld hl,0
	pop de
	call cclt
	ld a,h
	or l
	jp z,cc8
;		sendbyte('-');
	ld hl,45
	push hl
	call __sendbyte
	pop bc
;		dval = -dval;
	ld hl,2
	add hl,sp
	push hl
	ld hl,4
	add hl,sp
	call ccgint
	call ccneg
	pop de
	call ccpint
;	}
;	outint(dval);
cc8:
	ld hl,2
	add hl,sp
	call ccgint
	push hl
	call __outint
	pop bc
;}
	ret
;// function copied from c80dos.c 
;outint(n)	
__outint:
;int n;
;{	
;int q;
	push bc
;	q = n/10;
	ld hl,0
	add hl,sp
	push hl
	ld hl,6
	add hl,sp
	call ccgint
	push hl
	ld hl,10
	pop de
	call ccdiv
	pop de
	call ccpint
;	if (q) outint(q);
	ld hl,0
	add hl,sp
	call ccgint
	ld a,h
	or l
	jp z,cc9
	ld hl,0
	add hl,sp
	call ccgint
	push hl
	call __outint
	pop bc
;	sendbyte('0'+(n-q*10));
cc9:
	ld hl,48
	push hl
	ld hl,6
	add hl,sp
	call ccgint
	push hl
	ld hl,4
	add hl,sp
	call ccgint
	push hl
	ld hl,10
	pop de
	call ccmult
	pop de
	call ccsub
	pop de
	add hl,de
	push hl
	call __sendbyte
	pop bc
;}
	pop bc
	ret
;// sends a hexadecimal value to the UART 
;printhex(hval)	
__printhex:
;int hval;
;{	
;int q;
	push bc
;	q = hval/16;
	ld hl,0
	add hl,sp
	push hl
	ld hl,6
	add hl,sp
	call ccgint
	push hl
	ld hl,16
	pop de
	call ccdiv
	pop de
	call ccpint
;	if (q) printhex(q);
	ld hl,0
	add hl,sp
	call ccgint
	ld a,h
	or l
	jp z,cc10
	ld hl,0
	add hl,sp
	call ccgint
	push hl
	call __printhex
	pop bc
;	q = hval-q*16;
cc10:
	ld hl,0
	add hl,sp
	push hl
	ld hl,6
	add hl,sp
	call ccgint
	push hl
	ld hl,4
	add hl,sp
	call ccgint
	push hl
	ld hl,16
	pop de
	call ccmult
	pop de
	call ccsub
	pop de
	call ccpint
;	if (q > 9)
	ld hl,0
	add hl,sp
	call ccgint
	push hl
	ld hl,9
	pop de
	call ccgt
	ld a,h
	or l
	jp z,cc11
;		sendbyte('A'+q-10);
	ld hl,65
	push hl
	ld hl,2
	add hl,sp
	call ccgint
	pop de
	add hl,de
	push hl
	ld hl,10
	pop de
	call ccsub
	push hl
	call __sendbyte
	pop bc
;	else 
	jp cc12
cc11:
;		sendbyte('0'+q);
	ld hl,48
	push hl
	ld hl,2
	add hl,sp
	call ccgint
	pop de
	add hl,de
	push hl
	call __sendbyte
	pop bc
cc12:
;}
	pop bc
	ret
;// program main routine 
;main()
__main:
;{
;	// configure UART baud rate - set to 9600 for 30MHz clock 
;	// BAUD = round(<clock>/<baud rate>/16) = round(30e6/9600/16) = 195 
;	UBAUDL = 195;
	ld hl,195
	ld a,l
	out (129),a

;	UBAUDH = 0;
	ld hl,0
	ld a,l
	out (130),a

;	// print message 
;	printstr("Hello World!!!"); nl();
	ld hl,cc1+0
	push hl
	call __printstr
	pop bc
	call __nl
;	printstr("Dec value: "); printdec(tstary[1]); nl();
	ld hl,cc1+15
	push hl
	call __printstr
	pop bc
	ld hl,__tstary
	push hl
	ld hl,1
	add hl,hl
	pop de
	add hl,de
	call ccgint
	push hl
	call __printdec
	pop bc
	call __nl
;	printstr("Hex value: 0x"); printhex(tstary[0]); nl();
	ld hl,cc1+27
	push hl
	call __printstr
	pop bc
	ld hl,__tstary
	push hl
	ld hl,0
	add hl,hl
	pop de
	add hl,de
	call ccgint
	push hl
	call __printhex
	pop bc
	call __nl
;	printstr("Echoing received bytes: "); nl();
	ld hl,cc1+41
	push hl
	call __printstr
	pop bc
	call __nl
;	
;	// loop forever 
;	while (1) {
cc13:
	ld hl,1
	ld a,h
	or l
	jp z,cc14
;		// check if a new byte was received 
;		if (getbyte()) 
	call __getbyte
	ld a,h
	or l
	jp z,cc15
;			// echo the received byte to the UART 
;			sendbyte(rxbyte); 
	ld a,(__rxbyte)
	call ccsxt
	push hl
	call __sendbyte
	pop bc
;	}
cc15:
	jp cc13
cc14:
;}
	ret
;//---------------------------------------------------------------------------------------
;//						Th.. Th.. Th.. Thats all folks !!!
;//---------------------------------------------------------------------------------------
cc1:
	db 72,101,108,108,111,32,87,111,114,108
	db 100,33,33,33,0,68,101,99,32,118
	db 97,108,117,101,58,32,0,72,101,120
	db 32,118,97,108,117,101,58,32,48,120
	db 0,69,99,104,111,105,110,103,32,114
	db 101,99,101,105,118,101,100,32,98,121
	db 116,101,115,58,32,0
__rxbyte:
	ds 1
__tstary:
	db -46,4,46,22

; --- End of Compilation ---
