`timescale 1us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/08/2018 01:57:51 PM
// Design Name: 
// Module Name: divider
// Project Name: Bike computer
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divider(Dividend,Divisor,Res,Busy,Ready);

    //bit width of the divider, design uses 12
    parameter WIDTH = 12;
    //input and output ports.
    input [WIDTH-1:0] Dividend;
    input [WIDTH-1:0] Divisor;
    output [WIDTH-1:0] Res;
    output reg Busy, Ready;
    
    //internal variables    
    reg [WIDTH-1:0] Res = 0;
    reg [WIDTH-1:0] a1,b1;
    reg [WIDTH:0] p1;   
    integer i;

    always@ (Dividend or Divisor)
    begin
        //initialize the variables.
        Busy = 1;
        a1 = Dividend;
        b1 = Divisor;
        p1 = 0;
        Ready = 0;
        //check division by 0
        if (b1 == 0) begin
            Res = 0;
            Ready = 1;
            Busy = 0;
        end
        else begin
        
        //restoring division
            for(i=0;i < WIDTH;i=i+1)    begin 
                p1 = {p1[WIDTH-2:0],a1[WIDTH-1]};#1;
                a1[WIDTH-1:1] = a1[WIDTH-2:0];#1;
                p1 = p1-b1;#1;
                if(p1[WIDTH] == 1)    begin
                   a1[0] = 0;#1;
                   p1 = p1 + b1;#1;
                end
                else
                    a1[0] = 1;#1;
                end
             
            Res = a1;
            Ready = 1;
            Busy = 0;   
        end
     end 

endmodule
