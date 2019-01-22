`timescale 1us / 10ns
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/11/2018 02:33:14 AM
// Design Name: 
// Module Name: Max_speed
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


module Max_speed(  clk, r , speed,out
    );
    parameter WIDTH = 12; 
    input [WIDTH-1:0]speed;
    input wire clk, r;
    output reg [WIDTH-1:0] out = 0;
    
    always @(posedge clk) begin
        if (r) out <= 0;
        else out  <= (speed > out)? speed : out;
    end
    
    
endmodule
