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
    reg sec_pulse;
    
    reg[6:0]  max_speed;
    reg[6:0]  speed;
    reg[13:0] distance;
    reg[9:0]  avg_speed;
    reg[18:0] HMS_time;
    
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
    parameter CYCLES = 200;
    
    reg[6:0] hours;
    reg[5:0] minutes;
    reg[5:0] seconds;
    
    always begin
        @(posedge clock);
        HMS_time[18:12] <= hours;
        HMS_time[11:6] <= minutes;
        HMS_time[5:0] <= seconds;
    end
    
    control DUT(
    .clock          (clock),
    .reset          (reset),
    .half_sec_pulse (half_sec_pulse),       
    .sec_pulse      (sec_pulse),    
    .mode           (mode),        
                          
    .max_speed      (max_speed),      
    .speed          (speed),          
    .distance       (distance),
    .avg_speed      (avg_speed),
    .HMS_time       (HMS_time),
    .lower0001      (lower0001)             
    );
    
          
    always #(CLOCKPERIOD/2) clock =  ~clock;
    
    always @(posedge clock) distance = distance + 1;
    
    always @(posedge clock) begin
    if(sec_pulse) begin
        seconds = seconds + 1;
        if(seconds > 59) begin
            seconds = 0;
            minutes = minutes + 1;
            if(minutes > 59) begin
                minutes = 0;
                hours = hours + 1;
            end
        end
    end
    end
    
    always begin
        sec_pulse <= 1;
        @(posedge clock);
        sec_pulse <= 0;
        repeat(50) @(posedge clock);
    end
    always begin
        half_sec_pulse <= 1;
        @(posedge clock);
        half_sec_pulse <= 0;
        repeat(25) @(posedge clock);
    end
    
    initial begin
        clock = 0;
        reset = 1;   
        max_speed = 50;
        speed = 69;    
        distance = 1920;
        avg_speed = 33;
        mode = 0;
        
        hours = 0;
        minutes = 0;  
        seconds = 0;  
          
        repeat(CYCLES) @(posedge clock);
        reset = 0;
        
        repeat(CYCLES) @(posedge clock);
        
        mode = 1;
        @(posedge clock);
        mode = 0;
        repeat(CYCLES) @(posedge clock);
        
        mode = 1;
        @(posedge clock);
        mode = 0;
        repeat(CYCLES) @(posedge clock);
        mode = 1;
        @(posedge clock);
        mode = 0; 
        repeat(CYCLES) @(posedge clock);
        mode = 1;
        @(posedge clock);
        mode = 0;
        repeat(CYCLES) @(posedge clock);
    end
    
    initial begin
        #10000 $finish;
    end
  
    
endmodule
