`timescale 1us / 10ns


module tb_dual2ascii(
    );
    reg clock;              
    reg reset;              
    reg [6:0]  max_speed;    
    reg [6:0]  speed;        
    reg [13:0] distance;     
    reg [9:0]  avg_speed;    
    reg[6:0] hours;         
    reg[5:0] minutes;       
    reg[5:0] seconds;       
    reg AVS;                
    reg DAY;                
    reg MAX;                
    reg TIM;                
    reg start;                      
                        
    wire [7:0] lower0001;    
    wire [7:0] lower0010;    
    wire [7:0] lower0100;    
    wire [7:0] lower1000;    
    wire [7:0] upper01;      
    wire [7:0] upper10;      
                        
    wire valid_out;
    

    parameter CLOCKPERIOD = 2;
    parameter CYCLES = 30;
    
    always #(CLOCKPERIOD/2) clock =  ~clock;
    
    initial begin
        clock = 0;
        reset = 1;   
        max_speed = 50;
        speed = 69;    
        distance = 1920;
        avg_speed = 33;
        hours = 0;
        minutes = 28;  
        seconds = 22;  
        AVS = 0;
        DAY = 0;  
        MAX = 0;  
        TIM = 0;  
        start = 0;
          
        repeat(CYCLES) @(posedge clock);
        DAY = 1;
        reset = 0;
        
        @(posedge clock);
        
        start = 1;
        @(posedge clock);
        start = 0;
        repeat(CYCLES) @(posedge clock);
        
        start = 1;
        DAY = 0;
        AVS = 1;
        @(posedge clock);
        start = 0;
        repeat(CYCLES) @(posedge clock);
        
        start = 1;
        AVS = 0;
        DAY = 1;
        @(posedge clock);
        start = 0;
        repeat(CYCLES) @(posedge clock);
        
        start = 1;
        DAY = 0;
        MAX = 1;
        @(posedge clock);
        start = 0;
        repeat(CYCLES) @(posedge clock);
        
        start = 1;
        MAX = 0;
        TIM = 1;
        @(posedge clock);
        start = 0;
        repeat(5*CYCLES) @(posedge clock);
        $finish;
    end
    
    initial begin
        #1000000 $finish;
    end
    
    
    
    
    
    dual2ascii DUT(
        .clock          (clock),
        .reset          (reset),
        .max_speed      (max_speed),
        .speed          (speed),
        .distance       (distance),
        .avg_speed      (avg_speed),
        .hours          (hours),
        .minutes        (minutes),
        .seconds        (seconds),
        .AVS            (AVS),
        .valid_out      (valid_out),
        .DAY            (DAY),
        .MAX            (MAX),
        .TIM            (TIM),
        .start          (start),
        .lower0001      (lower0001),
        .lower0010      (lower0010),  
        .lower0100      (lower0100),
        .lower1000      (lower1000),
        .upper01        (upper01),
        .upper10        (upper10)
    );
endmodule
