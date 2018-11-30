`timescale 1us/10ns


module PULSE_SHAPE (
  input wire clock,
  input wire reset,
  input wire inkey,
  output reg outkey
);


// internal signals
reg [2:0] delay;


// start of module description

always @ (posedge clock)
begin
  if (reset)
    delay <= 0;
  else
    delay <= {delay[1:0],inkey};
end

// always @ (negedge clock)
always @ (posedge clock)
begin
  if (reset)
    outkey <= 0;
  else
    outkey <= delay[1] && !delay[2] ;
end

endmodule
