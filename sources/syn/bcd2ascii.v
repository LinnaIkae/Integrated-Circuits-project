`timescale 1us/10ns


module bcd2ascii (
  input wire [3:0] bcd,
  output reg [7:0] displ
);


// start of module description

always @ (bcd)
begin
  case (bcd)
    0:displ=8'b00110000;
    1:displ=8'b00110001;
    2:displ=8'b00110010;
    3:displ=8'b00110011;
    4:displ=8'b00110100;
    5:displ=8'b00110101;
    6:displ=8'b00110110;
    7:displ=8'b00110111;
    8:displ=8'b00111000;
    9:displ=8'b00111001;
	default:displ = 8'b0;
  endcase
end

endmodule
