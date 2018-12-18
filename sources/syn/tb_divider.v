`timescale 1us / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/10/2018 06:45:11 AM
// Design Name: 
// Module Name: tb_divider
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

module tb_divider;
    parameter WIDTH = 12;
    // Inputs
    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    // Outputs
    wire [WIDTH-1:0] Res;
    wire Busy, Ready;
    
    //tb check variables
    reg ok = 1;
    reg [WIDTH-1:0] Control;
    reg [WIDTH-1:0] test;
    
    //internal variables
    integer i, range, seed;

    // Instantiate the division module (DUT)
    divider #(WIDTH) DUT (
        .Dividend(A), 
        .Divisor(B), 
        .Res(Res),
        .Busy(Busy),
        .Ready(Ready)
    );

    initial begin
        
        range = 2 ** WIDTH -1;

        test = 1-10;        
        for (i=0;i<range;i=i+1)begin
            
            A = i;
            
            B = i; 
            Control = A/B; 
            ok = (Res == Control) ? 1 : 0 ;
            #100;
            
        end
       
        
        A = 0;      B = 0;    
        Control = A/B; 
        
                    ok = (Res == Control) ? 1 : 0 ;#100; 
                    
        A = 2262;     B = 2262; 
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ;#100;
                    
        A = 200;    B = 40; 
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ;#100;
                            
        A = 90;     B = 9;  
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ;#100;
                    
        A = 70;     B = 10;
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ; #100;
                    
        A = 16;     B = 3;  
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ;#100;
                    
        A = 255;    B = 5;  
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ;#100;
                    
        A = 2;      B = 5;  
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ;#100;
                    
        A = 10;     B = 0; 
        Control = A/B; 
                    ok = (Res == Control) ? 1 : 0 ; #100;
                    
                     $finish;
    end
  
      
endmodule
