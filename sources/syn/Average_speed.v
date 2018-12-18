`timescale 1us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/11/2018 02:33:14 AM
// Design Name: 
// Module Name: Average_speed
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


module Average_speed( clk, en, r, get, trip_time, trip_distance, out, dividerbus, dividerres, dividercontrol 
    );
    
        //parameters of the module
    parameter WIDTH_div = 16;
    parameter WIDTH_out = 12;
    parameter CONST = 3600;
    
    //IO
    input clk, en, r, get;
    input [WIDTH_div-1:0] trip_time;
    input [WIDTH_div-1:0] trip_distance;
    output reg [WIDTH_out-1:0] out;
    output reg[(2*WIDTH_div-1):0] dividerbus;
    input [WIDTH_div-1:0] dividerres;
    inout [1:0]dividercontrol; //indexes are 1 Busy,0 Ready
    
    //internal variables
    reg [1:0]waiting = 0;
    reg [WIDTH_div-1:0]A = 0;
    wire Busy = dividercontrol[1];
    wire Ready = dividercontrol[0];
    
    always @(posedge clk)
    begin
        if (en == 1) begin
            A <= (A == 0) ? trip_distance*CONST : A;
        end
        
        //topmodule asks for average  speed
        if (get == 1) begin
        //sends to divider
            if (Busy == 1)begin
                waiting <= 1;
            end else begin
                dividerbus[2*WIDTH_div-1:WIDTH_div] <= A;
                dividerbus[WIDTH_div-1:0] <= trip_time;
                waiting <= 2;
            end
        end
        if (waiting == 1 && Busy == 0)begin
            dividerbus[2*WIDTH_div-1:WIDTH_div] <= A;
            dividerbus[WIDTH_div-1:0] <= trip_time;
            waiting <= 2;
        end
        if (waiting == 2 && Ready == 1)begin
                    out <= dividerres[WIDTH_out-1:0];
                    
                    waiting <= 0;
                end
    end
    
endmodule
