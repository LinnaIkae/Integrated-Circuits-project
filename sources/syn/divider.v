`timescale 1us / 10ns
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2019 02:26:26 AM
// Design Name: 
// Module Name: divider
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


 module divider(en, clk,Dividend1, Dividend2, Divisor1, Divisor2,Res,Busy,Ready, Select);

    //bit width of the divider, design uses 12
    parameter WIDTH = 12;
    //input and output ports.
    input en, clk;
    input Select;
    input [WIDTH-1:0] Dividend1, Dividend2;
    input [WIDTH-1:0] Divisor1, Divisor2;
    output [WIDTH-1:0] Res;
    output reg Busy, Ready;
    
    //internal variables    
    reg [WIDTH-1:0] Res = 0;
    reg [WIDTH-1:0] a1,b1;
    reg [WIDTH:0] p1;   
    integer i, fsm;
    reg waiting = 0;

    always@ (posedge clk)
        begin
        if (en == 1) begin
        if (waiting == 0) begin 
        
        //initialize the variables.
            if(Busy == 0) begin
            Busy <= 1;
            a1 <= (Select == 1) ? Dividend1 : Dividend2;
            b1 <= (Select == 1) ? Divisor1 : Divisor2;
            p1 <= 0;
            Ready <= 0;
            i <= 0;
            fsm <= 0;
            end
            else begin
         //check division by 0
            if (b1 == 0) begin
                Res <= 0;
                Ready <= 1;
                Busy <= 0;
            end
            else begin
        
        //restoring division
            if (i < WIDTH) begin
                case (fsm)
                    0: begin
                        p1 <= {p1[WIDTH-2:0],a1[WIDTH-1]};
                        a1[WIDTH-1:1] <= a1[WIDTH-2:0];
                        fsm <= fsm +1; 
                    end
                    
                    1: begin
                        p1 = p1-b1;
                        fsm <= fsm +1;
                    end
                    
                    2: begin
                        if(p1[WIDTH] == 1)    begin
                            a1[0] <= 0;
                            p1 <= p1 + b1;
                        end
                        else begin
                            a1[0] <= 1;
                        end
                        fsm <= fsm +1;
                                            
                    end
                    
                    3: begin
                        i <= i+1;
                        fsm <= 0;
                        
                    end
                    
                 default: b1 <= 0;
                 endcase
                
                
            
            end 
            else begin
                Res <= a1;
                Ready <= 1;
                Busy <= 0;
                waiting <= 1;      //ready needs more cycles to be recognised             
            end
        ///////////
            
            end
            end
            end else begin
                    waiting <= 0;
                 end
        end
        else begin
            Busy <= 0;
        
         end
     
     end 

endmodule

