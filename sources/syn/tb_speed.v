`timescale 1us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2018 03:45:08 AM
// Design Name: 
// Module Name: tb_speed
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
module tb_speed;


    parameter WIDTH = 16; //speed width is set 12 in speed module
    parameter WIDTH_speed = 12;
    //global
    reg en = 1;
    reg clk = 1;
    reg reed = 0;
    reg [7:0] circ = 255;
    
    
    // Inputs
    reg get = 0;
    
 
    // Outputs
    wire [WIDTH_speed-1:0] speed;
    wire [1:0] dividercontrol;
    
    //tb check variables
    reg ok = 1;
    reg [WIDTH-1:0] control;
    
    //internal variables
    wire [(2*WIDTH-1):0] dividerbus;
    wire [WIDTH-1:0] dividerres;
    //integer i;

    // Instantiate the division module (DUT)

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
    //instantiate divider module (DIV)
    divider #(WIDTH) DIV (
        .Dividend(dividerbus[2*WIDTH-1:WIDTH]), 
        .Divisor(dividerbus[WIDTH-1:0]), 
        .Res(dividerres),
        .Busy(dividercontrol[1]),
        .Ready(dividercontrol[0])
    );
    
    initial begin
        reed = 1; #1
        reed = 0; #1000
        reed = 1; #1
        reed = 0; #10
        get =1; # 100
        $finish;
        
    
    end
    always begin
        control = dividerbus[2*WIDTH-1:WIDTH];#1;
    end
    
    //clock
    always begin
        clk <= ~clk;
        #1;
    end
    
endmodule
