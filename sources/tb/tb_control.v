`timescale 1us/10ns
/*
control module handles
*/

module tb_control(
    );
    
    reg clock;
    reg reset;
    reg mode;
    reg half_sec_pulse;
    
    reg[6:0]  max_speed;
    reg[6:0]  speed;
    reg[13:0] distance;
    reg[9:0]  avg_speed;
    
    wire AVS;               
    wire DAY;               
    wire MAX;               
    wire TIM;               
    wire col;               
    wire point;             
    wire [7:0] lower0001;   
    wire [7:0] lower0010;   
    wire [7:0] lower0100;   
    wire [7:0] lower1000;   
    wire [7:0] upper01;     
    wire [7:0] upper10;      
    
    parameter CLOCKPERIOD = 2;
    
    control DUT(
    .clock          (clock),
    .reset          (reset)
    );
    
          
    always #(CLOCKPERIOD/2) clock =  ~clock;
    
    initial begin
      clock = 0;
      reset = 1;
      #100
      reset = 0;
    end
    
    initial begin
        #1000000 $finish;
    end
  
    
endmodule
