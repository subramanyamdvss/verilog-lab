`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:59:36 08/15/2017 
// Design Name: 
// Module Name:    alu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu(fnsel,x,y,z,bo);
	input[2:0] fnsel;
	input[7:0] x,y;
	output[7:0] z;
	output bo;
	wire[7:0] z;
	wire bo;
	wire co;
	assign z=fnsel[0]?x:'bz;
	assign z=fnsel[1]?0:'bz;
	assign z=fnsel[2]?1:'bz;
	assign {bo,z}=fnsel[3]?(x-y):'bz;
	assign z=fnsel[4]?y+1:'bz;
	assign z=fnsel[5]?x+2:'bz;
	assign {co,z}=fnsel[6]?x+y:'bz;
		
	/*always@(fnsel)
	begin
		if(fnsel[0])
			z=x;
		if(fnsel[1])
			z=0;
		if(fnsel[2])
			z=1;
		if(fnsel[3])
			{bo,z}=x-y;
		if(fnsel[4])
			z=y+1;
		if(fnsel[5])
			z=x+2;
		if(fnsel[6])
			z=x+y;
	end*/
endmodule
