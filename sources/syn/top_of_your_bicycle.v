`timescale 1us/10ns
`default_nettype none

module TOP_OF_YOUR_BICYCLE (
  input wire clock,
  input wire mode,
  input wire reed,
  input wire reset_in,
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

parameter MAX_SPEED_WIDTH = 7; //only 7bits are effectively used instead of 12
parameter SPEED_IN_WIDTH = 16;
parameter SPEED_OUT_WIDTH = 7; //only 7bits are effectively used instead of 12
parameter AVG_SPEED_IN_WIDTH = 16;
parameter AVG_SPEED_OUT_WIDTH = 10; //10bits are required for 99.9 range 
parameter DIV_WIDTH = 26;

wire half_sec_pulse;
wire sec_pulse;
wire [MAX_SPEED_WIDTH - 1:0] max_speed;
wire [SPEED_OUT_WIDTH - 1:0] speed;
wire [AVG_SPEED_OUT_WIDTH-1:0] avg_speed;
wire [13:0] distance;
wire [15:0] trip_dist;
assign trip_dist = {2'b0, distance};
wire [18:0] HMS_time;
wire[12:0] sec_accum;
wire[12:0] min_accum;

wire speed_enable, speed_valid, speed_start;
wire avg_speed_enable, avg_speed_valid, avg_speed_start;
wire[13:0] centimeters;
wire div_select;

wire dist_enable, tim_enable, max_enable;

wire reset;
reg reset_thing = 1;
always @(posedge clock) begin
    if(reset_thing == 1) reset_thing <= 0;
end
assign reset = reset_in || reset_thing;

control#(
    .SPEED_WIDTH            (SPEED_OUT_WIDTH),
    .MAX_SPEED_WIDTH        (MAX_SPEED_WIDTH),
    .AVG_SPEED_WIDTH    (AVG_SPEED_OUT_WIDTH))
    control_inst(
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
    .speed_valid     (speed_valid),
    .avg_speed_valid (avg_speed_valid),
    
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
    .upper10         (upper10),
    
    .speed_start     (speed_start),
    .avg_speed_start (avg_speed_start),
    .div_select      (div_select),
    
    .en_speed        (speed_enable),
    .en_avg          (avg_speed_enable), 
    .en_dist         (dist_enable),
    .en_tim          (tim_enable),
    .en_max          (max_enable),
    .en_div          (div_enable)
);


distance distance_inst(
    .clock          (clock),
    .reset          (reset),
    .reed           (reed),
    .circ           (circ),
    .enable         (dist_enable),
    .distance       (distance),
    .centimeters    (centimeters)
);

timing timing_inst(
    .clock          (clock),
    .reset          (reset),
    .enable         (tim_enable),
    .HMS_time       (HMS_time),
    .sec_accum      (sec_accum),
    .min_accum      (min_accum),
    .sec_pulse      (sec_pulse),
    .half_sec_pulse (half_sec_pulse)
);

Max_speed #(MAX_SPEED_WIDTH) max_speed_inst(
    .speed          (speed),
    .clk            (clock), 
    .enable         (max_enable),
    .r              (reset),
    .out            (max_speed)
);


wire[DIV_WIDTH-1:0] divisor1;
wire[DIV_WIDTH-1:0] dividend1;

Speed #(
    .WIDTH          (SPEED_IN_WIDTH), 
    .WIDTH_speed    (SPEED_OUT_WIDTH)) 
    speed_inst(
    .clk            (clock),
    .rst            (reset),
    .en             (speed_enable),
    .reed           (reed),
    .circ           (circ),
    .speed          (speed),
    .dividend       (dividend1),
    .divisor        (divisor1),
    .Busy           (div_busy),
    .Ready          (div_ready),
    .dividerres     (div_res),
    .start          (speed_start),
    .valid          (speed_valid)
);

wire[DIV_WIDTH-1:0] divisor2;
wire[DIV_WIDTH-1:0] dividend2;

Average_speed #(
    .WIDTH_div      (AVG_SPEED_IN_WIDTH), 
    .WIDTH_out      (AVG_SPEED_OUT_WIDTH)) 
    avg_speed_inst(
    .clk            (clock),
    .rst            (reset),
    .en             (avg_speed_enable),
    .start          (avg_speed_start),
    .avg_speed      (avg_speed),
    .trip_time_sec  (sec_accum),
    .trip_time_min  (min_accum),
    .trip_distance  (trip_dist),
    .trip_cents     (centimeters),
    .dividend       (dividend2),
    .divisor        (divisor2),
    .Busy           (div_busy),
    .Ready          (div_ready),
    .dividerres     (div_res),
    .valid          (avg_speed_valid)
);

wire div_busy, div_ready, div_enable;
wire[DIV_WIDTH-1: 0] div_res;

divider #(
    .WIDTH          (DIV_WIDTH))
    div_inst(
    .clk            (clock),
    .en             (div_enable),
    .reset          (reset),
    .Select         (div_select),
    .Dividend1      (dividend1),
    .Dividend2      (dividend2),
    .Divisor1       (divisor1),
    .Divisor2       (divisor2),
    .Res            (div_res),
    .Busy           (div_busy),
    .Ready          (div_ready)
    );

endmodule
