`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2019 02:55:55 PM
// Design Name: 
// Module Name: tb_speed2
// Project Name: 
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


module tb_speed2;

// Testbench for testing only speed module.


parameter WIDTH = 16;
parameter WIDTH_speed = 12;
parameter CONST = 73.728;

parameter CLOCKPERIOD = 10;
parameter REED_PERIOD = 5;

reg en = 0;
reg clk = 1;
reg reed = 0;
reg [7:0] circ = 255;


reg get = 0;
reg [WIDTH-1: 0]  divisor = 0;
reg [2*WIDTH-1: 0]dividend = 0;
reg [WIDTH-1:0] dividerres = 0;
reg dividerready = 0;
reg dividerbusy = 0;


// Outputs
wire [WIDTH_speed-1:0] speed;

// Internal wires
wire [1:0] dividercontrol;
wire [(2*WIDTH-1):0] dividerbus;

assign dividercontrol = {dividerbusy, dividerready};
assign dividerbus = {dividend, divisor};


always #(CLOCKPERIOD/2) clk =  ~clk;

always begin
   repeat(REED_PERIOD) @(posedge clk);
   reed = 1;
   @(posedge clk);
   reed = 0;
end

initial begin
    en = 1;
    repeat(5) @(posedge clk);
    get = 1;
    dividerready = 1;
    repeat(5) @(posedge clk);
    divisor = 200;
    repeat(5) @(posedge clk);
    
    //TODO: add actual useful test inputs
    

end


Speed #(WIDTH) DUT (
    .en(en),
    .clk(clk), 
    .reed(reed), 
    .circ(circ), 
    .get(get), 
    .speed(speed),
    .dividerbus(dividerbus), 
    .dividerres(dividerres), 
    .dividercontrol(dividercontrol)
);
endmodule
