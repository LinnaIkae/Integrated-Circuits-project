`timescale 1us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/11/2018 02:33:14 AM
// Design Name: 
// Module Name: Speed
// Project Name: ike computer
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


module Speed(en, clk, reed, circ, get, speed,dividerbus, dividerres, dividercontrol);
    
    //parameters of the module
    parameter WIDTH = 16;
    parameter WIDTH_speed = 12;
    parameter CONST = 73.728;
    
    //IO
    input en, clk, reed, get;
    input [7:0] circ;
    output reg [WIDTH_speed-1:0] speed;
    output reg[(2*WIDTH-1):0] dividerbus;
    input [WIDTH-1:0] dividerres;
    inout [1:0]dividercontrol; //indexes are 1 Busy,0 Ready
    
    //internal variables
    reg [WIDTH-1:0]cnt = 0; //measures time between REEDS
    reg [WIDTH-1:0]tim = 0; //stores time between REEDS
    reg [1:0]waiting = 0;
    reg [WIDTH-1:0]A = 0;
    wire Busy = dividercontrol[1];
    wire Ready = dividercontrol[0];
    
    always @(posedge clk)
    begin
        if (en == 1) begin
            cnt <= (reed == 1)? 0 : cnt + 1;
            tim <= (reed == 1)? cnt : tim;
            A <= (A == 0) ? circ*CONST : A;
        end
        
        //topmodule asks for speed
        if (get == 1) begin
        //sends to divider
            if (Busy == 1)begin
                waiting <= 1;
            end else begin
                dividerbus[2*WIDTH-1:WIDTH] <= A;
                dividerbus[WIDTH-1:0] <= tim;
                waiting <= 2;
            end
        end
        if (waiting == 1 && Busy == 0)begin
            dividerbus[2*WIDTH-1:WIDTH] <= A;
            dividerbus[WIDTH-1:0] <= tim;
            waiting <= 2;
        end
        if (waiting == 2 && Ready == 1)begin
                    speed <= dividerres[WIDTH_speed-1:0];
                    
                    waiting <= 0;
                end
    end
    
    
endmodule
