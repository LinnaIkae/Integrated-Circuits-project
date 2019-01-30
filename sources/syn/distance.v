`timescale 1us/10ns
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2018 11:18:48 AM
// Design Name: 
// Module Name: distance
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


module distance(
    input wire clock,
    input wire reset,
    input wire reed,
    input wire[7:0] circ,
    input wire enable,
    
    output wire[13:0] distance,
    output wire[13:0] centimeters
    );
    
    reg[13:0] circ_cnt_r;
    reg[13:0] distance_r;
    wire compare;
    
    assign compare = (circ_cnt_r >= 10000)? 1: 0;
    
    always @(posedge clock)
    begin: circ_increment
        if (reset == 1 || compare == 1) begin
            circ_cnt_r <= 0;
        end
        else if(reed == 1 && enable == 1) begin
            circ_cnt_r <= circ_cnt_r + circ;
        end
        
    end //circ_increment
    
    always @(posedge clock)
    begin: dist_increment
        if(reset == 1) begin
            distance_r <= 0;
        end
        else if(distance > 9999) begin
            distance_r <= 0;
        end
        else if(compare == 1) begin
           distance_r <= distance_r + 1;     
        end
    end //dist_increment
    
    assign distance = distance_r;
    assign centimeters = circ_cnt_r;
    
endmodule
