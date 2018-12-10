`timescale 1us/10ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2018 07:12:30 PM
// Design Name: 
// Module Name: timing
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


module timing(
    input wire clock,
    input wire reset,
    
    output wire[19:0] HMS_time, //hours, minutes, seconds
    output wire[18:0] half_sec_cum,
    output wire half_sec_pulse,
    output wire sec_pulse
    );
    
    reg[9:0] cycles_r;
    reg[6:0] half_sec_r;
    reg[18:0] half_sec_cum_r;
    reg[5:0] min_r;
    reg[6:0] hrs_r;
    reg half_sec_pulse_r;
    reg sec_pulse_r;
    reg sec_pulse_done_r;
    
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
        
        if (reset == 1) begin
            half_sec_r <= 0;
            half_sec_cum_r <= 0;
            min_r <= 0;
            hrs_r <= 0;
            sec_pulse_done_r <= 0;
        end
        if (cycles_at_lim ) begin
            half_sec_r <= half_sec_r + 1;
            half_sec_cum_r <= half_sec_cum_r + 1;
            half_sec_pulse_r <= 1;
            if (sec_pulse_done_r) begin
                sec_pulse_r <= 1;
            end
            sec_pulse_done_r <= ~sec_pulse_done_r;
        end
        if (half_sec_r == 119) begin
            min_r <= min_r + 1;
            half_sec_r <= 0;
        end
        if (min_r == 59) begin
            hrs_r <= hrs_r + 1;
            min_r  <= 0;
        end
        
    end: count

    assign half_sec_pulse = half_sec_pulse_r;
    assign half_sec_cum = half_sec_cum_r;
    assign HMS_time = {hrs_r, min_r, (half_sec_r >> 1)};
    assign sec_pulse = sec_pulse_r;
endmodule
