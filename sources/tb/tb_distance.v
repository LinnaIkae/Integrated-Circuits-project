`timescale 1us/10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2018 11:54:32 AM
// Design Name: 
// Module Name: tb_distance
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


module tb_distance(
    );
    
    reg clock;
    reg reset;
    reg reed;
    reg[7:0] circ;
    
    wire[13:0] distance;
    
    parameter CLOCKPERIOD = 10;
    parameter REED_PERIOD = 2;
    
    distance DUT (
        .clock      (clock),
        .reset      (reset),
        .reed       (reed),
        .circ       (circ),
        .distance   (distance)
        );
        
    initial begin
        clock = 0;
        reset = 0;
        reed = 0;
        circ = 255;
    end
    
    always #(CLOCKPERIOD/2) clock =  ~clock;
    
    initial begin
        reset = 1;
        repeat(5) @(posedge clock);
        reset = 0;
        #10000 $finish;
    end
   
   always begin
       repeat(REED_PERIOD) @(posedge clock);
       reed = 1;
       @(posedge clock);
       reed = 0;
   end
endmodule
