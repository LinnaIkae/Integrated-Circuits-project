`timescale 1us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/11/2018 02:33:14 AM
// Design Name: 
// Module Name: tb_Max_speed
// Project Name: Bike computer
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: The OK signal is out of sync, due to delay of the divider
// needs to be fixed, also control signal needs to fix division by 0
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_Max_speed;
    parameter WIDTH = 12;
    // Inputs
    reg [WIDTH-1:0] in=0;
    reg r = 1, clk = 1;
    // Outputs
    wire [WIDTH-1:0] out;
    
    //tb check variables
    reg ok = 1;
    reg [WIDTH-1:0] Control  = 0;

    
    //internal variables
    integer i=0, range=0;

    // Instantiate the division module (DUT)
    Max_speed #(WIDTH) DUT (
        .clk(clk), 
        .r(r) ,
        .speed(in),
        .out(out)
    );

    initial begin
        
        range = 2 ** WIDTH -1;
        #10;
        r=0;
        for (i=0;i<range;i=i+1)begin
            
            in = i;
            
            #10;//wait for module to process on clk   
            Control = i;
            ok = (out == Control) ? 1 : 0 ;
           
        end
        r=1;
        #10;
        r=0;
        #10;

                    
        $finish;
    end
    always begin
        clk<=!clk;
        #5;
    end
      
endmodule