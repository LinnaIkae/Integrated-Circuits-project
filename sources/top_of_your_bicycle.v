`timescale 1us/10ns


module TOP_OF_YOUR_BICYCLE (
  input wire clock,
  input wire mode,
  input wire reed,
  input wire reset,
  input wire [7:0] circ,
  output wire AVS,
  output wire DAY,
  output wire MAX,
  output wire TIM,
  output wire col,
  output wire point,
  output wire [7:0] lower0001,
  output wire [7:0] lower0010,
  output wire [7:0] lower0100,
  output wire [7:0] lower1000,
  output wire [7:0] upper01,
  output wire [7:0] upper10
);


distance distance_inst(
    .clock          (clock),
    .reset          (reset),
    .reed           (reed),
    .circ           (circ),
    .distance       (distance)
);

timing timing_inst(
    .clock          (clock),
    .reset          (reset),
    .HMS_time       (HMS_time),
    .sec_accum      (sec_accum),
    .sec_pulse      (sec_pulse),
    .half_sec_pulse (half_sec_pulse)
);


endmodule
