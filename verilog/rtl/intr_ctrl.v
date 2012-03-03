//---------------------------------------------------------------------------------------
//	Project:			light8080 SOC		WiCores Solutions 
//
//	File name:			intr_ctrl.v 		(March 02, 2012)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains the light8080 SOC interrupt controller. The controller 
//		supports 4 external interrupt requests with fixed interrupt vector addresses. 
//		The interrupt vectors code is implemented in the "intr_vec.h" file included in 
//		the projects C directory. 
//		Note that the controller clears the interrupt request after the CPU read the 
//		interrupt vector. 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
// 
//---------------------------------------------------------------------------------------
// 
//	Copyright (C) 2012 Moti Litochevski 
// 
//	This source file may be used and distributed without restriction provided that this 
//	copyright statement is not removed from the file and that any derivative work 
//	contains the original copyright notice and the associated disclaimer.
//
//	THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, 
//	INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND 
//	FITNESS FOR A PARTICULAR PURPOSE. 
// 
//---------------------------------------------------------------------------------------

module intr_ctrl 
(
	clock, reset,
	ext_intr, cpu_intr, 
	cpu_inte, cpu_inta, 
	cpu_rd, cpu_inst, 
	intr_ena 
);
//---------------------------------------------------------------------------------------
// module interfaces 
// global signals 
input 			clock;		// global clock input 
input 			reset;		// global reset input 
// external interrupt sources 
// least significant bit has the highest priority, most significant bit has the lowest 
// priority. 
input	[3:0]	ext_intr;	// active high 
// CPU interface 
output			cpu_intr;	// CPU interrupt request 
input			cpu_inte;	// CPU interrupt enable - just to mask 
input			cpu_inta;	// CPU interrupt acknowledge 
input			cpu_rd;		// CPU read signal 
output	[7:0]	cpu_inst;	// interrupt calling instruction 

// interrupt enable register 
input	[3:0]	intr_ena;	// set high to enable respective interrupt 

//---------------------------------------------------------------------------------------
// 8080 assembly code constants 
// call instruction opcode used to call interrupt routine 
`define CALL_INST			8'hcd 
// interrupt vectors fixed addresses - high address byte is 0 
`define INT0_VEC			8'h08
`define INT1_VEC			8'h18
`define INT2_VEC			8'h28
`define INT3_VEC			8'h38

//---------------------------------------------------------------------------------------
// internal declarations 
// registered output 
reg [7:0] cpu_inst;

// internals 
reg [1:0] intSq, intSel;
reg [3:0] act_int, int_clr;
reg [7:0] int_vec;

//---------------------------------------------------------------------------------------
// module implementation 
// main interrupt controller control process 
always @ (posedge reset or posedge clock) 
begin 
	if (reset) 
	begin 
		intSq <= 2'b0;
		intSel <= 2'b0;
		cpu_inst <= 8'b0;
	end 
	else 
	begin 
		// interrupt controller state machine 
		case (intSq) 
			2'd0:		// idle state - wait for active interrupt 
				if ((act_int != 4'b0) && cpu_inte)
				begin 
					// latch the index of the active interrupt according to priority 
					if (act_int[0]) 		intSel <= 2'd0;
					else if (act_int[2])	intSel <= 2'd1;
					else if (act_int[3])	intSel <= 2'd2;
					else 					intSel <= 2'd3;
					// switch to next state 
					intSq <= 2'd1;
				end 
			default:	// all other states increment the state register on inta read 
				if (cpu_inta && cpu_rd)
				begin 
					// update state 
					intSq <= intSq + 1;
					
					// update instruction opcode for each byte read during inta 
					case (intSq) 
						2'd1:		cpu_inst <= `CALL_INST;
						2'd2:		cpu_inst <= int_vec;
						default:	cpu_inst <= 8'd0;
					endcase 
				end 
				else if (!cpu_inta) 
				begin 
					intSq <= 2'd0;
					cpu_inst <= 8'd0;
				end 
		endcase 
	end 
end 

// assign interrupt vector address according to selected interrupt 
always @ (intSel)
begin 
	case (intSel) 
		2'd0:	int_vec <= `INT0_VEC;
		2'd1:	int_vec <= `INT1_VEC;
		2'd2:	int_vec <= `INT2_VEC;
		2'd3:	int_vec <= `INT3_VEC;
	endcase 
end 

// latch active interrupt on rising edge 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
		act_int <= 4'b0;
	else 
		act_int <= (act_int & ~int_clr) | (ext_intr & intr_ena);
end 
// CPU interrupt is asserted when at least one interrupt is active 
assign cpu_intr = |act_int;

// clear serviced interrupt 
always @ (cpu_inta or cpu_rd or intSq or intSel) 
begin 
	if (cpu_inta && cpu_rd && (intSq == 2'd3))
	begin 
		case (intSel) 
			2'd0:	int_clr <= 4'b0001;
			2'd1:	int_clr <= 4'b0010;
			2'd2:	int_clr <= 4'b0100;
			2'd3:	int_clr <= 4'b1000;
		endcase 
	end 
	else 
		int_clr <= 4'b0;
end 

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
