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
module sqrt_struc();
  wire Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,in;
  wire [4:0] fnselect;
  control(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect);
  datapath(in,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0);
endmodule

module control(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect);
    input Go,B0;
    output over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect;
	 reg[7:0] q;
	 reg[7:0] p = 8'b00000000;
	 reg[5:0] fn = 6'b000000;
	 assign q = p;
	 // 
	 // q changes whenever go changes 
	 assign ldsqrt = q[0]|q[6];
	 assign ldsum = q[1]|q[3];
	 assign ldval = q[2]|q[5];
	 assign Tsqrt = q[0]|q[6];
	 assign Tval = q[3]|q[5];
	 assign Tsum = q[3]|q[4];
	 if(q[2]) begin
		fn = 6'b000001;
		fn = fn<<3;
		assign fnselect = fn; 
	 end
	 if(q[3]) begin
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
    always@ (Go or B0) begin
		if(q == p) begin
			p = 8'b00000001;
			q <= p;
		end
		if(q == 8'b00000001) begin
			if(Go) begin
				p = p << 1;
				q <= p;
			end
		end
		if((q[1]|q[2])|(q[3]))begin
			p = p << 1;
			q <= p;
		end
		if(q[4])begin
			if(B0) begin
				p = p << 3;
				q <= p;
			end
			if (~B0)begin
				p = p << 1;
				q <= p;
			end
		end
		if(q[7]) begin
			if(Go)begin
				q <= 8'b00000001;
				p = 8'b00000001;
			end
		end
		if(q[5])begin
			p = p << 1;
			q <= p;
		end
		if(q[6])begin
			p = p >> 2;
			q <= p;
		end
	 end	 
endmodule

module datapath(in,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0);
    input TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval;
	 input [7:0] in;
	 input [5:0] fnselect;
    output B0;
    reg[7:0] sqrt,sm,val;
    wire[7:0] X,Y,outwire;
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
            sm <= outwire;
        end
    end
    always@ (ldval)
    begin
        if(ldval) begin
            val <= outwire;
        end
    end
    if (TSW) begin
        assign X = in; 
    end
    if (Tsqrt) begin
        assign X = sqrt; 
    end
    if (Tsum) begin
        assign Y = sm; 
    end
    if (Tval) begin
        assign Y = val; 
    end
endmodule




module ALU(x,y,z,fnselect,B0);
    //the functions used are 
	 // i) zero ii) add iii) sub iv) keeping outwire as a constant value v) increment by const 2 vi) increment by const 1 
	 // v) can be implemented by keeping Y as constant value and fnselect as ii)
	 // to load the constants into X-bus or Y-bus use constX and constY registers.
	 //iv) can be implemented by keeping constY = c and constX = 0 and adding.
	 //addition:
	 input x,y,fnselect;
	 output B0,z;
	 wire overflow;
	 if(fnselect[1])begin
		assign {overflow,z} = x+y;
	 end
	 if(fnselect[2])begin
		assign z = x-y;
		//status detector.
		assign B0 = z[6];
	 end
	 if(fnselect[0]) begin
		assign z = 7'b0;
	 end
	 if(fnselect[3])begin
		assign z = 1;
	 end
	 if (fnselect[4]) begin
		assign z = y+2;
	 end
	 if (fnselect[5]) begin
		assign z = y+1;
	 end
	 
endmodule

