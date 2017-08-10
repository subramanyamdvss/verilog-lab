`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:17:20 08/04/2017 
// Design Name: 
// Module Name:    sqrt_struc 
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
module sqrt_struc(Go,n,over,sqrt);
  input Go,n;
  output[7:0] sqrt;
  output over;
  wire[7:0] sqrt;
  wire Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,reset;
  wire [5:0] fnselect;
  control ctrl(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect,reset);
  datapath dp(n,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0,sqrt);
endmodule

module control(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect,reset);
    input Go,B0;
	 input reset;
    output over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval;
	 reg over;
	 output[5:0] fnselect;
	 reg[5:0] fnselect;
	 reg[8:0] q;
	 reg[5:0] fn ;
	 // q changes whenever go changes 
	 assign ldsqrt = q[0]|q[6];
	 assign ldsum = q[1]|q[3]|q[7];
	 assign ldval = q[2]|q[5];
	 assign Tsqrt = q[0]|q[6];
	 assign Tval = q[3]|q[5]|q[7];
	 assign Tsum = q[3]|q[4]|q[7];
	 wire 
	 always@((q[0],q[1],q[2],q[3],q[4],q[5],q[5],q[6],q[7]) or posedge reset) begin
		 if(reset) begin
			//initialize the state register
			q<=9'b000000000;
			fn <=6'b000000;
			
		 end
		 if(q[2]) begin
			fn = 6'b000001;
			fn = fn<<3;
			assign fnselect = fn; 
		 end
		 if(q[3]|q[7]) begin
			fn = 6'b000001;
			fn = fn<<1;
			assign fnselect = fn; 
		 end
		 if(q[4]) begin
			fn = 6'b000001;
			fn = fn<<2;
			assign fnselect = fn; 
		 end
		 if(q[5]) begin
			fn = 6'b000001;
			fn = fn<<4;
			assign fnselect = fn; 
		 end
		 if(q[6]) begin
			fn = 6'b000001;
			fn = fn<<5;
			assign fnselect = fn; 
		 end
		 if(q[1]) begin
			fn = 6'b000001;
			assign fnselect = fn; 
		 end
	 end
    always@ (Go or B0) begin
		if(q == 9'b000000000) begin
			q = 9'b000000001;
		end
		if(q == 9'b000000001) begin
			if(Go) begin
				q = q << 1;
			end
		end
		if((q[1]|q[2])|(q[3]))begin
			q = q << 1;
		end
		if(q[4])begin
			if(B0) begin
				q = q << 4;
				over =1;
			end
			if (~B0)begin
				q = q << 1;
			end
		end
		if(q[8]) begin
			q <= 9'b000000001;
			over <= 0;
		end
		if(q[5]|q[6])begin
			q = q << 1;
		end
		if(q[7])begin
			q = q >> 3;
			
		end
	 end	 
endmodule

module datapath(n,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0,sqrt);
    input TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval;
	 input [7:0] n;
	 input [5:0] fnselect;
    output B0;
	 output[7:0] sqrt;
    reg[7:0] sqrt,sum,val;
    wire[7:0] outwire;
	 reg[7:0] X,Y;
    ALU alu(.x(X),.y(Y),.z(outwire),.fnselect(fnselect),.B0(B0));
    //code for loading info into registers
  
    always@ (ldsqrt )
    begin
        if(ldsqrt) begin
            sqrt <= outwire;
        end
    end
    always@ (ldsum)
    begin
        if(ldsum) begin
            sum <= outwire;
        end
    end
    always@ (ldval)
    begin
        if(ldval) begin
            val <= outwire;
        end
    end
	 always@(TSW or Tsqrt or Tsum or Tval) begin
		 if (TSW) begin
			  assign X = n; 
		 end
		 if (Tval) begin
			  assign X = val; 
		 end
		 if (Tsum) begin
			  assign Y = sum; 
		 end
		 if (Tsqrt) begin
			  assign Y = sqrt; 
		 end
	  end
endmodule




module ALU(x,y,z,fnselect,B0);
    //the functions used are 
	 // i) zero ii) add iii) sub iv) keeping outwire as a constant value v) increment by const 2 vi) increment by const 1 
	 // v) can be implemented by keeping Y as constant value and fnselect as ii)
	 // to load the constants into X-bus or Y-bus use constX and constY registers.
	 //iv) can be implemented by keeping constY = c and constX = 0 and adding.
	 //addition:
	 input[7:0] x,y;
	 input[5:0] fnselect;
	 output B0;
	 reg B0;
	 output [7:0] z;
	 reg[7:0] z;
	 reg overflow;
	 always@(fnselect) begin
		 if(fnselect[1])begin
			assign {overflow,z} = x+y;
		 end
		 if(fnselect[2])begin
			assign {overflow,z} = x-y;
			//status detector.
			assign B0 = z[7];
		 end
		 if(fnselect[0]) begin
			assign z = 8'b00000000;
		 end
		 if(fnselect[3])begin
			assign z = 1;
		 end
		 if (fnselect[4]) begin
			assign z = x+2;
		 end
		 if (fnselect[5]) begin
			assign z = y+1;
		 end
	  end
endmodule

