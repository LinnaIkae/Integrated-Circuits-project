`timescale 1us/10ns
`default_nettype none

module timing(
    input wire clock,
    input wire reset,
    
    output wire[19:0] HMS_time, //hours, minutes, seconds
    output wire[12:0] sec_accum,
    output wire[12:0] min_accum,
    output wire half_sec_pulse,
    output wire sec_pulse
    );
    
    reg[9:0] cycles_r;
    reg[6:0] half_sec_r;
    reg[12:0] sec_accum_r;
    reg[12:0] min_accum_r;
    reg[5:0] min_r;
    reg[6:0] hrs_r;
    reg half_sec_pulse_r;
    reg sec_pulse_r;
    reg sec_pulse_done_r;
    
    wire[5:0] secs;
    wire cycles_at_lim;
    assign cycles_at_lim = (cycles_r == 1023)? 1: 0;
    
    always @(posedge clock)
    begin: cycles_inc
    
        if (reset == 1) begin
            cycles_r <= 0;
        end
        else if (cycles_at_lim ) begin
            cycles_r <= 0;
        end
        else cycles_r <= cycles_r + 1;
        
    end: cycles_inc
    
    always @(posedge clock)
    begin: count
    
        half_sec_pulse_r <= 0;
        sec_pulse_r <= 0;
        
        if (reset == 1 || (min_r == 59 && hrs_r == 99)) begin
            half_sec_r <= 0;
            sec_accum_r <= 0;
            min_r <= 0;
            min_accum_r <= 0;
            hrs_r <= 0;
            sec_pulse_done_r <= 0;
        end
        if (cycles_at_lim ) begin
            half_sec_r <= half_sec_r + 1;
            half_sec_pulse_r <= 1;
            if (sec_pulse_done_r) begin
                sec_pulse_r <= 1;
                sec_accum_r <= sec_accum_r + 1;
            end
            sec_pulse_done_r <= ~sec_pulse_done_r;
            
            if (half_sec_r == 119) begin
                min_r <= min_r + 1;
                min_accum_r <= min_accum_r + 1;
                half_sec_r <= 0;
                
                if (min_r == 59) begin
                    hrs_r <= hrs_r + 1;
                    min_r  <= 0;
                end
            end
        end
    end: count

    assign half_sec_pulse = half_sec_pulse_r;
    assign sec_accum = sec_accum_r;
    assign min_accum = min_accum_r;
    assign secs = half_sec_r >> 1;
    assign HMS_time = {hrs_r, min_r, secs};
    assign sec_pulse = sec_pulse_r;
endmodule
