`timescale 1us/10ns


module global_toplevel (
	input  wire       CLK125M,     // 125 MHz
	input  wire       RESET_KEY,   // Right, red button
	input  wire       MODE_KEY,    // Left, black button
	input  wire       REED_PIN,    // Jumper, connect for pulse
	input  wire [3:0] TEST_SW,     // SW3...0 to set KMH test values
	output wire       RES_N,       // DISPLAY: Reset, active low
	output wire       SCL,         // DISPLAY: Clock
	output wire       SI,          // DISPLAY: Serial data out
	output wire       CS1_N,       // DISPLAY: Read data when low
	output wire       A0,          // DISPLAY: Data/Command flag
	output wire       C86,         // DISPLAY: Controller mode
	output wire       LED_A        // DISPLAY: Background light
);


// Signal Definitions
wire [7:0] CIRC;
wire MODE, REED, REED_TEST, REED2BIKE;
wire CLK2048;

wire avs, day, max, tim, point, col;
wire [7:0] lower1_ascii, lower10_ascii, lower100_ascii, lower1000_ascii, upper1_ascii, upper10_ascii;

// equivalent to: reg [7:0] CIRC = 8'b11010000;
(* dont_touch = "yes" *) FDRE #(.INIT(1'b0)) FDRE_CIRC0 (.Q(CIRC[0]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(0));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b0)) FDRE_CIRC1 (.Q(CIRC[1]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(0));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b0)) FDRE_CIRC2 (.Q(CIRC[2]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(0));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b0)) FDRE_CIRC3 (.Q(CIRC[3]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(0));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b1)) FDRE_CIRC4 (.Q(CIRC[4]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(1));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b0)) FDRE_CIRC5 (.Q(CIRC[5]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(0));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b1)) FDRE_CIRC6 (.Q(CIRC[6]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(1));
(* dont_touch = "yes" *) FDRE #(.INIT(1'b1)) FDRE_CIRC7 (.Q(CIRC[7]),.C(CLK2048),.CE(1),.R(RESET_KEY),.D(1));


// Instantiations
// ToDo: RESET_KEY is not shaped, not guaranted to be at least

PULSE_SHAPE PULSE_SHAPE_REED (
	.clock(CLK2048),
	.reset(RESET_KEY),
	.inkey(REED_PIN),
	.outkey(REED)
);

PULSE_SHAPE PULSE_SHAPE_MODE (
	.clock(CLK2048),
	.reset(RESET_KEY),
	.inkey(MODE_KEY),
	.outkey(MODE)
);

CLK_DIVIDER_BIKE INST_CLK_DIVIDER_BIKE (
	.clk_i(CLK125M),
	.reset(RESET_KEY),
	.clk_o(CLK2048)
);

KMH_TEST KMH_TEST_BIKE (
  .CLK2048(CLK2048),
  .reset(RESET_KEY),
  .TEST_SW(TEST_SW),
  .REED_TEST(REED_TEST)
);
assign REED2BIKE = REED_TEST || REED;

LCD_CONTROLLER LCD_CONTROLLER_INST (
	.CLK_I(CLK125M),
	.RST_I(RESET_KEY),
	.AVS(avs),
	.DAY(day),
	.MAX(max),
	.TIM(tim),
	.POINT(point),
	.COLON(col),
	.KMH(1),
	.LOWER1_ASCII(lower1_ascii),
	.LOWER10_ASCII(lower10_ascii),
	.LOWER100_ASCII(lower100_ascii),
	.LOWER1000_ASCII(lower1000_ascii),
	.UPPER1_ASCII(upper1_ascii),
	.UPPER10_ASCII(upper10_ascii),
	.RES_N_O(RES_N),
	.SCL_O(SCL),
	.SI_O(SI),
	.CS1_N_O(CS1_N),
	.A0_O(A0),
	.C86_O(C86),
	.LED_A_O(LED_A)
);

(* keep_hierarchy = "yes" *)
TOP_OF_YOUR_BICYCLE STUDENTS_DESIGN (
	.clock(CLK2048),
	.mode(MODE),
	.circ(CIRC),
	.reed(REED2BIKE),
	.reset_in(RESET_KEY),
	.AVS(avs),
	.DAY(day),
	.MAX(max),
	.point(point),
	.TIM(tim),
	.col(col),
	.lower0001(lower1_ascii),
	.lower0010(lower10_ascii),
	.lower0100(lower100_ascii),
	.lower1000(lower1000_ascii),
	.upper01(upper1_ascii),
	.upper10(upper10_ascii)
);


endmodule