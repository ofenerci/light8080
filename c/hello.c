//---------------------------------------------------------------------------------------
//	Project:			light8080 SOC		WiCores Solutions 
//
//	File name:			hello.c 				(February 04, 2012)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains a simple program written in Small-C that sends a string to 
//		the UART and then switches to echo received bytes. 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
//---------------------------------------------------------------------------------------

#include ..\tools\c80\c80.lib

// UART IO registers 
port (128) UDATA;		// uart data register used for both transmit and receive 
port (129) UBAUDL;		// low byte of baud rate register 
port (130) UBAUDH;		// low byte of baud rate register 
port (131) USTAT;		// uart status register 
// digital IO ports registers 
port (132) P1REG;     	// output port1 - used as first attenuator control 
port (133) P2REG;		// output port2 - used as low digit LCD 
port (134) P3REG;		// output port3 - used as high digit LCD 
port (135) P4REG;		// output port4 
// simulation end register 
// writing any value to this port will end the verilog simulation when using tb_l80soc 
// test bench. 
port (255) SIMEND;

// registers bit fields definition 
// uart status register decoding 
#define UTXBUSY		1
#define URXFULL		16

// globals 
char rxbyte;		// byte received from the uart 
int tstary[2] = {1234, 5678};

//---------------------------------------------------------------------------------------
// send a single byte to the UART 
sendbyte(by) 
char by;
{
	while (USTAT & UTXBUSY);
	UDATA = by;
}

// check if a byte was received by the uart 
getbyte()
{
	if (USTAT & URXFULL) {
		rxbyte = UDATA;
		return 1;
	} 
	else 
		return 0;
}

// send new line to the UART 
nl()
{
	sendbyte(13);
	sendbyte(10);
}

// sends a string to the UART 
printstr(sptr)
char *sptr;
{
	while (*sptr != 0) 
		sendbyte(*sptr++);
}

// sends a decimal value to the UART 
printdec(dval) 
int dval;
{
	if (dval<0) {
		sendbyte('-');
		dval = -dval;
	}
	outint(dval);
}

// function copied from c80dos.c 
outint(n)	
int n;
{	
int q;

	q = n/10;
	if (q) outint(q);
	sendbyte('0'+(n-q*10));
}

// sends a hexadecimal value to the UART 
printhex(hval)	
int hval;
{	
int q;

	q = hval/16;
	if (q) printhex(q);
	q = hval-q*16;
	if (q > 9)
		sendbyte('A'+q-10);
	else 
		sendbyte('0'+q);
}

// program main routine 
main()
{
	// configure UART baud rate - set to 9600 for 30MHz clock 
	// BAUD = round(<clock>/<baud rate>/16) = round(30e6/9600/16) = 195 
	UBAUDL = 195;
	UBAUDH = 0;

	// print message 
	printstr("Hello World!!!"); nl();
	printstr("Dec value: "); printdec(tstary[1]); nl();
	printstr("Hex value: 0x"); printhex(tstary[0]); nl();
	printstr("Echoing received bytes: "); nl();
	
	// loop forever 
	while (1) {
		// check if a new byte was received 
		if (getbyte()) 
			// echo the received byte to the UART 
			sendbyte(rxbyte); 
	}
}

//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------

