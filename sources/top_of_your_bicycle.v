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

parameter MAX_SPEED_WIDTH = 12;
parameter SPEED_IN_WIDTH = 16;
parameter SPEED_OUT_WIDTH = 12;
parameter AVG_SPEED_IN_WIDTH = 16;
parameter AVG_SPEED_OUT_WIDTH = 12;

wire half_sec_pulse;
wire sec_pulse;
wire [MAX_SPEED_WIDTH - 1:0] max_speed;
wire [SPEED_OUT_WIDTH - 1:0] speed;
wire [13:0] distance;
wire [AVG_SPEED_OUT_WIDTH-1:0] avg_speed;
wire [18:0] HMS_time;

wire speed_enable, speed_get;

wire avg_speed_enable, avg_speed_get;

control control_inst(
    .clock           (clock),
    .reset           (reset),
    .mode            (mode),
    .half_sec_pulse  (half_sec_pulse),
    .sec_pulse       (sec_pulse),
    .max_speed       (max_speed),
    .speed           (speed),
    .distance        (distance),
    .avg_speed       (avg_speed),
    .HMS_time        (HMS_time),
    .AVS             (AVS),
    .DAY             (DAY),
    .MAX             (MAX),
    .TIM             (TIM),
    .col             (col),
    .point           (point),
    .lower0001       (lower0001),
    .lower0010       (lower0010),
    .lower0100       (lower0100),
    .lower1000       (lower1000),
    .upper01         (upper01),
    .upper10         (upper10)
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
    .min_accum      (min_accum),
    .sec_pulse      (sec_pulse),
    .half_sec_pulse (half_sec_pulse)
);

max_speed #(MAX_SPEED_WIDTH) max_speed_inst(
    .speed          (speed),
    .clk            (clock), 
    .r              (reset),
    .out            (max_speed)
)

speed #(SPEED_IN_WIDTH, SPEED_OUT_WIDTH) speed_inst(
    .clk            (clock),
    .r              (reset),
    .en             (speed_enable),
    .reed           (reed),
    .get            (speed_get),
    .circ           (circ),
    .speed          (speed),
    .dividerbus     (dividerbus),
    .dividerres     (dividerres)
)

Average_speed #(AVG_SPEED_IN_WIDTH, AVG_SPEED_OUT_WIDTH) avg_speed_inst(
    .clk            (clock),
    .r              (reset),
    .en             (avg_speed_enable),
    .get            (avg_speed_get),
    .avg_speed      (avg_speed),
    .trip_time_sec  (sec_accum),
    .trip_time_min  (min_accum)
    .trip_distnance (distance),
    .dividerbus     (dividerbus),
    .dividerres     (dividerres),
)

endmodule
