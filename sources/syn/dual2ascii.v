`timescale 1us/10ns


module dual2ascii(
    input wire      clock,
    input wire      reset,
    input wire[6:0] max_speed,
    input wire[6:0] speed,
    input wire[13:0]distance,
    input wire[9:0] avg_speed,
    input wire[6:0] hours,
    input wire[5:0] minutes,
    input wire[5:0] seconds,
    input wire      AVS,
    input wire      DAY,
    input wire      MAX,
    input wire      TIM,
    input wire      start,
   
    
    output wire [7:0] lower0001,
    output wire [7:0] lower0010,
    output wire [7:0] lower0100,
    output wire [7:0] lower1000,
    output wire [7:0] upper01,
    output wire [7:0] upper10,
    
    output reg valid_out
    );
    
    wire[6:0] time_big;
    wire[6:0] time_small;
    
    reg upper_ascii_valid;
    reg lower_ascii_valid;
    
    wire finish_s2bcd;
    wire[7:0] speed_bcd;
    wire start_s2bcd;
    
    reg[13:0] lower_dual;
    wire finish_L2bcd;
    wire[15:0] lower_bcd;
    reg start_L2bcd;
    
    wire[3:0] bcd_U01;
    wire[3:0] bcd_U10;
    wire[3:0] bcd_L0001;
    wire[3:0] bcd_L0010;
    wire[3:0] bcd_L0100;
    wire[3:0] bcd_L1000;

    reg[7:0] time_bcd_small;
    reg[7:0] time_bcd_big;
    assign start_s2bcd = start;
    assign bcd_U01 = speed_bcd[3:0];
    assign bcd_U10 = speed_bcd[7:4];
    
    assign time_big = (hours > 0) ? hours: minutes;
    assign time_small = (hours > 0) ? minutes: seconds; 
    
    assign bcd_L0001 = (TIM == 0)? lower_bcd[3:0] : time_bcd_small[3:0];
    assign bcd_L0010 = (TIM == 0)? lower_bcd[7:4] : time_bcd_small[7:4];
    assign bcd_L0100 = (TIM == 0)? lower_bcd[11:8]: time_bcd_big[3:0];
    assign bcd_L1000 = (TIM == 0)? lower_bcd[15:12]:time_bcd_big[7:4];
    reg TIM_phase1;
    always @(posedge clock)
    begin
        start_L2bcd <= 0;
        if (start) begin
            if(TIM) begin
                lower_dual <= time_big;
                start_L2bcd <= 1;
                TIM_phase1 <= 1;
            end
            else if(AVS == 1) begin
                lower_dual <= avg_speed;
                start_L2bcd <= 1;
                end
            else if(DAY == 1) begin
                lower_dual <= distance;
                start_L2bcd <= 1;
                end 
            else if(MAX == 1) begin
                lower_dual <= max_speed;
                start_L2bcd <= 1;
                end
        end  
        
        if(finish_s2bcd) begin
            upper_ascii_valid <= 1;
        end
        
        if(finish_L2bcd) begin
            if(TIM_phase1) begin
                time_bcd_big <= lower_bcd;
                TIM_phase1 <= 0;
                lower_dual <= time_small;
                start_L2bcd <= 1;
            end else
                lower_ascii_valid <= 1;
                time_bcd_small <= lower_bcd;
        end
        
        if(start) begin
            valid_out <= 0;
            upper_ascii_valid <= 0;
            lower_ascii_valid <= 0;
        end
        else if(upper_ascii_valid && lower_ascii_valid) begin
            valid_out <= 1;
        end
    end
    
    dual2bcd #(.dualwidth(7), .bcdwidth(8)) speed2bcd(
        .clock          (clock),
        .reset          (reset),
        .start          (start_s2bcd),
        .dual           (speed),
        .finish         (finish_s2bcd),
        .bcd            (speed_bcd)
    );
    
    dual2bcd #(.dualwidth(14), .bcdwidth(16)) lower2bcd(
        .clock          (clock),
        .reset          (reset),
        .start          (start_L2bcd),
        .dual           (lower_dual),
        .finish         (finish_L2bcd),
        .bcd            (lower_bcd)
    );
    
    bcd2ascii b2a_upper01(
        .bcd        (bcd_U01),
        .displ      (upper01)
    );
    
    bcd2ascii b2a_upper10(
        .bcd        (bcd_U10),
        .displ      (upper10)
    );
    
    bcd2ascii b2a_lower0001(
        .bcd        (bcd_L0001),
        .displ      (lower0001)
    );
    
    bcd2ascii b2a_lower0010(
        .bcd        (bcd_L0010),
        .displ      (lower0010)
    );
    
    bcd2ascii b2a_lower0100(
        .bcd        (bcd_L0100),
        .displ      (lower0100)
    );
    
    bcd2ascii b2a_lower1000(
        .bcd        (bcd_L1000),
        .displ      (lower1000)
    );    
endmodule
