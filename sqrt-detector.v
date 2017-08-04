module sqrt_struc();
  
endmodule

module control(Go,B0,over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect);
    input Go,B0;
    output over,TSW,ldsqrt,Tsqrt,ldsum,Tsum,Tval,fnselect;
    
endmodule

module datapath(in,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect,B0);
    input in,TSW,ldsqrt,Tsqrt,ldsum,Tsum,ldval,Tval,fnselect;
    output B0;
    reg[255:0] in,sqrt,sm,val;
    wire X,Y,outwire;
    ALU alu(X,Y,outwire,fnselect,B0)
    //code for loading info into registers
    always@ (ldsqrt )
    begin
        if(ldsqrt)
            sqrt <= outwire;
    end
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
        X = in; 
    end
    if (Tsqrt) begin
        X = sqrt; 
    end
    if (Tsum) begin
        Y = sm; 
    end
    if (Tval) begin
        Y = val; 
    end
    
endmodule

module ALU(x,y,z,fnselect,B0)
    
endmodule
