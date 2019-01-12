`timescale 1us/10ns


module tb_timing(
    );
    
    
    reg clock;
    reg reset;
    wire[18:0] hms_time; //hours, minutes, seconds
    wire[12:0] sec_accum;
    wire[12:0] min_accum;
    wire half_sec_pulse;
    wire sec_pulse;
    
    parameter CLOCKPERIOD = 2;
    
    timing DUT(
        .clock          (clock),
        .reset          (reset),
        .HMS_time       (hms_time),
        .sec_accum      (sec_accum),
        .min_accum      (min_accum),
        .half_sec_pulse (half_sec_pulse),
        .sec_pulse      (sec_pulse)
        );
        
    always #(CLOCKPERIOD/2) clock =  ~clock;
    
    initial begin
        clock = 0;
        reset = 1;
        #100
        reset = 0;
    end
    
    
    initial begin
        #2000000 $finish;
    end
endmodule
