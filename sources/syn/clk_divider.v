`timescale 1us/10ns

//	The following line is needed for correct timing contraints, DO NOT REMOVE!
(* keep_hierarchy = "yes" *)
module CLK_DIVIDER_BIKE (
   input wire clk_i,
   input wire reset,
   output wire clk_o
);

// Signal Definitions
reg [14:0] count = 0;
reg [14:0] end_val = 125000000/(2*2048);
reg internal_slow_clock = 0;
reg reseted = 0;

// Output Clock Buffer
BUFG BUFG_2048 (
	.O(clk_o),
	.I(internal_slow_clock)
);

// Functional Part
always @ (posedge clk_i)
begin:counter
	if(reset && !reseted) begin
		count <= 0;
		internal_slow_clock <= 0;
		reseted <= 1;
	end
	else begin
		if (count == end_val) begin
			count <= 0;
			internal_slow_clock <= ~internal_slow_clock;
		end else begin
			count <= count + 1;
		end
		if(!reset) begin
		    reseted <= 0;
		end
	end
end

endmodule