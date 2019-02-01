`timescale 1us / 10ns
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: CTU in Prague @ Uni Ulm
// Engineer: Martin Kostal
// 
// Create Date: 12/11/2018 02:33:14 AM
// Design Name: 
// Module Name: Average_speed
// Project Name: Bike computer
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


module Average_speed( clk, en, rst, start, trip_time_sec, trip_time_min, trip_distance, trip_cents, avg_speed, dividend, divisor, Busy, Ready, dividerres, valid
    );
    //    .clk            (clock),
    //    .rst            (reset),
    //    .en             (avg_speed_enable),
    //    .start          (avg_speed_start),
    //    .avg_speed      (avg_speed),
    //    .trip_time_sec  (sec_accum),
    //    .trip_time_min  (min_accum),
    //    .trip_distance  (distance),
    //    .dividend       (dividend2),
    //    .divisor        (divisor2),
    //    .busy           (div_busy),
    //    .ready          (div_ready),
    //    .dividerres     (div_res),
    //    .valid          (avg_speed_valid),
    //    .select         (div_select)
    
    //parameters of the module
    parameter WIDTH_div = 16;
    parameter WIDTH_out = 10;
    parameter CONST_SEC = 3600;
    parameter CONST_MIN = 60;
    
    
    //IO
    input wire clk, en, rst, start;
    input [12:0] trip_time_sec;
    input [12:0] trip_time_min;
    input [WIDTH_div-1:0] trip_distance;
    input [13:0] trip_cents;
    output wire [WIDTH_out-1:0] avg_speed; //out
    output reg valid = 0;
    output reg[WIDTH_div-1:0] dividend, divisor;
    input [WIDTH_div-1:0] dividerres;
    input wire Busy, Ready;
    
    //internal variables
    reg [1:0]waiting = 0;
    reg [WIDTH_div-1:0]A = 0;
    reg [WIDTH_div-1:0]B = 0;
    reg [WIDTH_div-1:0] avg_speed_tmp = 0;
    
    
    always @(posedge clk)
    begin

        if (rst == 1) begin
            avg_speed_tmp <= 0;            
            valid <= 0;
            waiting <= 0;
            dividend <= 0;
            divisor <= 0;
            A <= 0;
            B <= 0;
        end
        else if (en == 1) begin
            if (trip_time_sec<4094 && trip_distance < 6) begin //limit time not being over 15bits and ditance too not over 16bits
                A <= trip_cents + (trip_distance * 10000);
                B <= (trip_time_sec * 4'b1011) >> 2; //multiply by 2.75 - conversion from cm/ to km/h
            end else begin
                A <= (trip_time_sec<6000) ? trip_distance * CONST_SEC : trip_distance * CONST_MIN;
                B <=(trip_time_sec<6000) ? trip_time_sec : trip_time_min; 
            end
           
            
            //topmodule asks for average  speed
            if (start == 1) begin
                valid  <= 0;
            //sends to divider
                if (waiting == 0)begin
                    waiting <= 1;
                end 
            end
            if (waiting == 1 && Busy == 0 )begin
                dividend <= A;
                divisor <= B;
                waiting <= 2;
            end
                    
            if (waiting == 2 && Busy == 1)begin
                waiting <= 3;
            end        
            
            if (waiting == 3 && Ready == 1)begin
                avg_speed_tmp[WIDTH_div-1:0] <= (dividerres[WIDTH_div-1:0]> 999) ? 999 : dividerres[WIDTH_div-1:0];                   
                
                valid <= 1;
                waiting <= 0; 
            end
        end 
        else  begin
            valid <= 0;
        end
    end
    assign avg_speed = avg_speed_tmp[WIDTH_out-1: 0];
    
endmodule
