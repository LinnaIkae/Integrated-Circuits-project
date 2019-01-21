`timescale 1us/10ns


module control(
    input wire clock,
    input wire reset,
    input wire mode,
    input wire half_sec_pulse,
    input wire sec_pulse,

    input wire[6:0]  max_speed,
    input wire[6:0]  speed,
    input wire[13:0] distance,
    input wire[9:0]  avg_speed,
    input wire[18:0] HMS_time,

    output reg AVS,
    output reg DAY,
    output reg MAX,
    output reg TIM,
    output reg col,
    output reg point,
    output reg [7:0] lower0001,
    output reg [7:0] lower0010,
    output reg [7:0] lower0100,
    output reg [7:0] lower1000,
    output reg [7:0] upper01,
    output reg [7:0] upper10
    );
    
    wire[6:0] hours = HMS_time[18:12];
    wire[5:0] minutes = HMS_time[11:6];
    wire[5:0] seconds = HMS_time[5:0];
    
    parameter s_RESET = 5'b00001;
    parameter s_DAY = 5'b00010;
    parameter s_AVS = 5'b00100;
    parameter s_TIM = 5'b01000;
    parameter s_MAX = 5'b10000;
    
    reg d2a_start;
    reg mode_r;
    wire d2a_valid;
    
    wire[7:0] lower0001_b; 
    wire[7:0] lower0010_b; 
    wire[7:0] lower0100_b; 
    wire[7:0] lower1000_b; 
    wire[7:0] upper01_b;   
    wire[7:0] upper10_b;   
    
    
    reg [4:0] state_r = s_RESET;
    
    wire high_speed;
    
    assign high_speed = (speed > 65);
    
    reg half_sec_toggle;
    
    always @(posedge clock)
    begin: FSM
      AVS <= 0;
      DAY <= 0;
      MAX <= 0;
      TIM <= 0;
    
      if (reset)
         state_r <= s_RESET;
      else
         case (state_r)
            s_RESET : begin
               state_r <= s_DAY;
            end
            s_DAY : begin
               if (mode) begin
                  state_r <= s_AVS;
                  end
               DAY <= 1;
               if(high_speed && half_sec_toggle) begin
                  AVS <= 1;
                  MAX <= 1;
                  TIM <= 1;
               end
            end
            s_AVS : begin
                if (mode) begin
                    state_r <= s_TIM;
                    end
                AVS <= 1;
                if(high_speed && half_sec_toggle) begin
                    TIM <= 1;
                    MAX <= 1;
                    DAY <= 1;
                end
            end
            s_TIM : begin
               if (mode) begin
                  state_r <= s_MAX;
                  end
               TIM <= 1;
               if(high_speed && half_sec_toggle) begin
                   AVS <= 1;
                   MAX <= 1;
                   DAY <= 1;
               end
            end
            s_MAX : begin
               if (mode) begin
                  state_r <= s_DAY;
                  end
               MAX <= 1;
               if(high_speed && half_sec_toggle) begin
                   AVS <= 1;
                   TIM <= 1;
                   DAY <= 1;
               end
            end
         endcase
    end: FSM
    
    always @(posedge clock) begin
        if(reset) begin
            half_sec_toggle <= 0;
        end
        if(half_sec_pulse) begin
            half_sec_toggle = ~half_sec_toggle;
        end
    end
    
    always @(posedge clock)
    begin: display_update
    
        if(reset) begin
            lower0001 <= 0;
            lower0010 <= 0;
            lower0100 <= 0;
            lower1000 <= 0;
            upper01   <= 0;
            upper10   <= 0;
        end
        
        d2a_start <= 0;
        mode_r <= mode;
        
        if(sec_pulse || mode_r) begin
            point <= 0;
            col <= 0;
            d2a_start <= 1;
            case(state_r)
                s_DAY:begin
                    point <= 1;
                end
                s_AVS:begin
                    point <= 1;         
                end
                s_TIM:begin
                    col <= ~col;                                     
                end
                s_MAX:begin                                       
                end
            endcase
        end
        else if(d2a_valid) begin
        //clocking encoding data in
            lower0001 <= lower0001_b; 
            lower0010 <= lower0010_b; 
            lower0100 <= lower0100_b; 
            lower1000 <= lower1000_b; 
            upper01   <= upper01_b;   
            upper10   <= upper10_b;
        end
    end: display_update
    
    dual2ascii d2a_inst(
        .clock      (clock),     
        .reset      (reset),     
        .max_speed  (max_speed), 
        .speed      (speed),     
        .distance   (distance),  
        .avg_speed  (avg_speed), 
        .hours      (hours),     
        .minutes    (minutes),   
        .seconds    (seconds),   
        .AVS        (AVS),       
        .DAY        (DAY),       
        .MAX        (MAX),       
        .TIM        (TIM),       
        .start      (d2a_start),
        .lower0001  (lower0001_b),  
        .lower0010  (lower0010_b),  
        .lower0100  (lower0100_b),  
        .lower1000  (lower1000_b),  
        .upper01    (upper01_b),    
        .upper10    (upper10_b),
        .valid_out  (d2a_valid)
    );                        
                                
                                
endmodule
