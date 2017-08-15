
`timescale 1ns / 1ps


module top_module();
    wire Go,over,reset;
	 wire[7:0] n,sqrt;
    wire[8:0] q;
    wire[7:0] sum;
    wire[7:0] val;
    wire[5:0] fnselect;
    wire[7:0] outwire;
    wire B0;
    wire clk;
    
    sqrt_beh uut (
		.Go(Go), 
		.n(n), 
		.over(over),
		.reset(reset),
		.sqrt(sqrt),
        .q(q),
        .sum(sum),
        .val(val),
        .B0(B0),
        .fnselect(fnselect),
        .outwire(outwire),
        .Go1(Go1),
        .Go2(Go2),
        .Go3(Go3)
	);

    test_bench uutd(Go,n,over,reset,sqrt,q,sum,val,B0,fnselect,outwire,Go1,Go2,Go3);
endmodule

module test_bench(Go,n,over,reset,sqrt,q,sum,val,B0,fnselect,outwire,Go1,Go2,Go3);
    //you need to add extra debug info.
    output Go;
    output[7:0] n;
    output reset;
    output Go2,Go1,Go3;
    input[7:0] outwire;
    input[8:0] q;
    input[5:0] fnselect;
    input[7:0] sqrt;
    input over;
    input[7:0] sum;
    input[7:0] val;
    input B0;  
	reg[7:0] n;
	reg Go;
    reg Go1;
    reg Go2;
    reg Go3;
	wire[7:0] sqrt;
    wire[7:0] sum;
    wire[7:0] val;
    wire B0;
	reg reset;	
    integer j,seed; 
	initial begin
        n = 128;
        Go = 0;
        Go1 = 0;
        Go2 = 0;
        Go3 = 0;
        #10000
		reset = 1'b0;
        
        #10000
        
        reset = 1'b1;
        #10000
        $display("q = %9b ",q);
        reset = 1'b0;
	end

    always @(posedge over) 
    begin
            if(over) begin
                $display("n = %8b sum = %8b val = %8b B0 = %b over = %b\n",n,sum,val,B0,over);                
                $finish;
                
            end
		            
    end

	initial begin
		
        #50003
        #100000;
		forever begin
			#100000;
			Go = ~Go;
            
		end
    
	end
    initial begin
     #60003
        forever begin
            #100000;
            Go1 = ~Go1;        
        end    
    end

    initial begin
     #70003
        forever begin
            #100000;
            Go2 = ~Go2; 
                   
        end    
    end

    initial begin
     #80003
        forever begin
            #100000;
            Go3 = ~Go3;        
        end    
    end
	
    
	/*always @(posedge over)
	begin		
        #2;
		n = $random(seed)%256; //input should below 256
      seed = seed +1;
		j = j+1;
	end*/
	always@(sum,val,q,sqrt,B0) begin
        
        $display("q = %9b sum = %8b val = %8b B0 = %b out=%8b fnselect = %6b aluz = %8b",q,sum,val,B0,sqrt,fnselect,outwire);
    end
	
endmodule


module sqrt_beh(Go,n,over,reset,sqrt,q,sum,val,B0,fnselect,outwire,Go1,Go2,Go3);
  input Go;
  input[7:0] n;
  input reset;
  input Go1,Go2,Go3;
  output[7:0] sum;
  output[7:0] val;
  output B0; 
  output[7:0] sqrt;
  output over;
  output[8:0] q;
  output[5:0] fnselect;
  output[7:0] outwire;
  wire[7:0] sqrt;
  wire[7:0] outwire;
  wire Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,ldval,Tsum,Tval,reset,Go1,Go2,Go3;
  wire [5:0] fnselect;
  control ctrl(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,ldval,Tsum,Tval,fnselect,reset,q);
  datapath dp(n,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0,sqrt,sum,val,outwire,Go1,Go2,Go3);
endmodule

module control(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,ldval,Tsum,Tval,fnselect,reset,q);
     input Go,B0;
	 input reset;
     output over,TSW,ldsqrt,Tsqrt,ldsum,ldval,Tsum,Tval;
     output[8:0] q;
	 output[5:0] fnselect;
     reg over;
	 reg[5:0] fnselect;
	 reg[8:0] q ;
	 reg[5:0] fn ;
	 wire tmp;
	 // q changes whenever go changes 
	 assign TSW = q[4];
	 assign ldsqrt = q[0]|q[6];
	 assign ldsum = q[1]|q[3]|q[7];
	 assign ldval = q[2]|q[5];
	 assign Tsqrt = q[0]|q[6];
	 assign Tval = q[3]|q[5]|q[7];
	 assign Tsum = q[3]|q[4]|q[7];
	 assign tmp = Go || B0;
	 always@(posedge tmp or posedge reset) begin
		 if(reset) begin
			//initialize the state register
			q<=9'b000000001;
			fnselect <= 6'b000001;
			over <= 1'b0;
		 end else begin 
			if(q[0]) begin
			//when it is in then 
			q <= 9'b000000010;
            over <= 0;
			fn <= 6'b000001;
			fnselect <= 6'b000001;
		 end
		 else  begin if(q[1])begin
			//if q[1] is 1
			fn <= 6'b000001;
			fnselect <= 6'b001000;
			q <= q << 1;
		 end
		 else begin if(q[2]) begin
			//fn = 6'b000001;
			//fn = fn<<3;
			fnselect <=6'b000010;
			q <= q << 1;
		 end
		 else begin if(q[3]) begin
			fnselect <= 6'b000100; 
			q <= q << 1;
		 end
		 else begin if(q[7])begin
			fnselect <= 6'b000100; 
			q <= q >> 3;
		 end
		 else begin if(q[4]) begin
			
			if(B0) begin
				q <= q << 4;
				fnselect <= 6'b000001; 
			end
			else begin
				q <= q << 1;
                fnselect <= 6'b010000; 
			end
		 end
		 else begin if(q[5]) begin
			fnselect <= 6'b100000; 
			q <= q << 1;
		 end
		 else begin if(q[6]) begin
			fnselect <= 6'b000010; 
			q <= q << 1;
		 end
		else  begin
			//q[8]
			over <=1;
			q <= 9'b000000001;
			
		end
		
	 end
	 end
	 end
	 end
	 end
	 end
	 end
	 end
	 end
endmodule

module datapath(n,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0,sqrt,sum,val,outwire,Go1,Go2,Go3);
    input TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval;
	 input [7:0] n;
	 input [5:0] fnselect;
	 input Go1;
    input Go2;
    input Go3;
    output B0;
	 output[7:0] sqrt;
    output[7:0] sum,val,outwire;
    
    reg[7:0] sqrt,sum,val;
    wire[7:0] outwire;
	 reg[7:0] X,Y;
    ALU alu(.x(X),.y(Y),.z(outwire),.fnselect(fnselect),.B0(B0),.Go2(Go2));
    //code for loading info into registers
	 //ldsqrt,ldsum,ldval,TSW ,Tsqrt , Tsum , Tval
	 //first the alu calculation should be done then the assignment should be done.
    
     


    always@(posedge Go1) begin
         if (TSW) begin
			  X <= n; 
		 end
		 else begin if(Tval) begin
			  X <= val; 
		 end
         else begin
            X<=X;
         end
        end
		 if(Tsum) begin
			  Y <= sum; 
		 end
		 else  begin if(Tsqrt) begin
			  Y <= sqrt; 
		 end
         else begin
              Y<=Y;
         
         end
         end
    end

	
    always@ (posedge Go3)
    begin
        if(ldsqrt) begin
            sqrt <= outwire;
        end
   
        else begin if(ldsum) begin
            sum <= outwire;
        end
        else begin if(ldval) begin
            val <= outwire;
        end
		else begin
            sqrt<=sqrt;
            sum<=sum;
            val<=val;            
    	end
	  end
	  end
	  end
endmodule




module ALU(x,y,z,fnselect,B0,Go2);
    //the functions used are 
	 // i) zero ii) add iii) sub iv) keeping outwire as a constant value v) increment by const 2 vi) increment by const 1 
	 // v) can be implemented by keeping Y as constant value and fnselect as ii)
	 // to load the constants into X-bus or Y-bus use constX and constY registers.
	 //iv) can be implemented by keeping constY = c and constX = 0 and adding.
	 //addition:
	 input[7:0] x,y;
	 input Go2;
	 input[5:0] fnselect;
	 output B0;
	 output [7:0] z;
	 reg[7:0] z;
     reg B0;
     
	 always@(posedge Go2) begin
		 if(fnselect[1])begin
			z <= x+y;
		 end
		 else begin if(fnselect[2])begin
			z <= x-y;
            B0 <= z[7];
		 end
		 else begin if(fnselect[0]) begin
           
			z <= 8'b00000000;
             
		 end
		 else begin if(fnselect[3])begin
			z <= 1;
		 end
		 else begin if (fnselect[4]) begin
			z <= x+2;
		 end
		 else  begin
			z <= y+1;
		 
	  end
	  end
	  end
	  end
	  end
	  end
	  
endmodule
