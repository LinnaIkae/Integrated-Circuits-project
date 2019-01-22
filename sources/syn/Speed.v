`timescale 1us / 10ns
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/11/2018 02:33:14 AM
// Design Name: 
// Module Name: Speed
// Project Name: ike computer
// Tarstart Devices: 
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


module Speed(en, clk, reed, circ, start, speed, valid, dividerbus, dividerres, dividercontrol);
    //add valid output
    
    //parameters of the module
    parameter WIDTH = 16;
    parameter WIDTH_speed = 12;
    parameter CONST = 16'b1001001_10111010;//approx 73.728;
    
    
    //IO
    input wire en, clk, reed, start;
    input [7:0] circ;
    output reg [WIDTH_speed-1:0] speed;
    output reg valid = 0;
    output reg[(2*WIDTH-1):0] dividerbus;
    input [WIDTH-1:0] dividerres;
    inout [3:0]dividercontrol; //indexes are 1 Busy,0 Ready, 2 master signal to avg_speed, 3 start division
    
    //internal variables
    reg [WIDTH-1:0]cnt = 0; //measures time between REEDS
    reg [WIDTH-1:0]tim = 0; //stores time between REEDS
    reg [1:0]waiting = 0;
    reg [WIDTH+8-1:0]cico = 0; //stores circ*const value as Q16.8
    wire Busy = dividercontrol[1];
    wire Ready = dividercontrol[0];
    reg Take_div = 0;
    assign dividercontrol[2] = (Ready) ? Take_div : 'bz;
    reg Start_div = 0;
    assign dividercontrol[3] = (Take_div) ? Start_div : 'bz;    
    
    initial begin
        cico <= circ*CONST;
    end
    always @(posedge clk)
    begin
        if (en == 1) begin
            cnt <= (reed == 1)? 0 : cnt + 1;
            tim <= (reed == 1)? cnt : tim;
           // A <= (A == 0) ? circ*CONST : A;
        end
        
        //topmodule asks for speed
        if (start == 1) begin
            valid  <= 0;
            Take_div <= 1;
        //sends to divider
            if (/*Busy == 1 &&*/ waiting == 0)begin
                waiting <= 1;
//            end else begin
//                dividerbus[2*WIDTH-1:WIDTH] <= cico[WIDTH+8-1:8];
//                dividerbus[WIDTH-1:0] <= tim;
//                Start_div <= 1;
//                waiting <= 2;
            end
        end
        if (waiting == 1 && Busy == 0)begin
            dividerbus[2*WIDTH-1:WIDTH] <= cico[WIDTH+8-1:8];
            dividerbus[WIDTH-1:0] <= tim;
            Start_div <= 1;
            waiting <= 2;
        end
        
        if (waiting == 2 && Busy == 1)begin
                    waiting <= 3;
        end
                        
        if (waiting == 3 && Ready == 1)begin
                    speed <= dividerres[WIDTH_speed-1:0];
                    valid <=1;
                    Start_div <= 0;
                    waiting <= 0;
                    Take_div <=0;
                end
    end
    
    
endmodule
