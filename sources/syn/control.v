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
    
    reg [4:0] state_r = s_RESET;
    
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
            end
            s_AVS : begin
               if (mode) begin
                  state_r <= s_TIM;
                  end
               AVS <= 1;
            end
            s_TIM : begin
               if (mode) begin
                  state_r <= s_MAX;
                  end
               TIM <= 1;
            end
            s_MAX : begin
               if (mode) begin
                  state_r <= s_DAY;
                  end
               MAX <= 1;
            end
         endcase
    end: FSM
    
    always @(posedge clock)
    begin: display_update
        if(sec_pulse || mode) begin
                        //start_conversion <= 1;
            case(state_r)
                s_DAY:begin
                end
                s_AVS:begin
                                        
                end
                s_TIM:begin
                                                        
                end
                s_MAX:begin
                                                                        
                end
            endcase
        end
    
    end: display_update
    
                            
                                
                                
endmodule
