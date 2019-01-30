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


module Speed(en, rst, clk, reed, circ, start, speed, valid, dividend, divisor, dividerres, Busy, Ready, select);
    //add valid output
    
    //parameters of the module
    parameter WIDTH = 16;
    parameter WIDTH_speed = 7;
    parameter CONST = 16'b1001001_10111010; //approx 73.728;
    
    //IO
    input wire en, rst, clk, reed, start, Busy, Ready, select;
    input [7:0] circ;
    output reg [WIDTH_speed-1:0] speed;
    output reg valid = 0;
    output reg[WIDTH-1:0] dividend, divisor;
    input [WIDTH-1:0] dividerres;
    
    //internal variables
    reg [WIDTH-1:0]cnt = 0; //counts time between REEDS
    reg [WIDTH-1:0]tim = 0; //stores time between REEDS
    reg [2:0]waiting = 0;
    reg [WIDTH+8-1:0]cico = 0; //stores circ*const value as Q16.8
    
    always @(posedge clk)
    begin
        cico = circ*CONST;
        if (rst == 1) begin
             cnt <= 0;
             tim <= 0;
             speed <= 0;
             valid <= 0;
             dividend <= 0;
             divisor <= 0;
        end
        else begin
            if (en == 1) begin
                cnt <= (reed == 1)? 0 : cnt + 1;
                tim <= (reed == 1)? cnt : tim;
            end
            
            //topmodule asks for speed
            if (start == 1) begin
                valid  <= 0;
                //sends to divider
                if (waiting == 0)begin
                    waiting <= 1;
                end
            end
            if (waiting == 1 && Busy == 0)begin
                dividend <= cico[WIDTH+8-1:8];
                divisor <= tim;
                waiting <= 2;
            end
            
            if (waiting == 2 && Busy == 1)begin
                waiting <= 3;
            end
            
            if (waiting == 3 && Busy == 1) begin
                waiting <= 4;
            end

            if (waiting == 4 && Ready == 1)begin
                speed <= (dividerres[WIDTH_speed-1:0]>99) ? 99 : dividerres[WIDTH_speed-1:0]; //detects overflow
                valid <=1;
                waiting <= 0;
            end
        end
    end
    
    
endmodule
