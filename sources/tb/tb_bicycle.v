`timescale 1us/10ns
`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000

module tb_bicycle;

reg         CLK, RESET, MODE, REED;

  wire       ref_day;
  wire       dut_day;
  wire       ref_avs;
  wire       dut_avs;
  wire       ref_tim;
  wire       dut_tim;
  wire       ref_max;
  wire       dut_max;
  wire       ref_col;
  wire       dut_col;
  wire       ref_point;
  wire       dut_point;
  wire [7:0] ref_upper10;
  wire [7:0] dut_upper10;
  wire [7:0] ref_upper01;
  wire [7:0] dut_upper01;
  wire [7:0] ref_lower1000;
  wire [7:0] dut_lower1000;
  wire [7:0] ref_lower0100;
  wire [7:0] dut_lower0100;
  wire [7:0] ref_lower0010;
  wire [7:0] dut_lower0010;
  wire [7:0] ref_lower0001;
  wire [7:0] dut_lower0001;

reg [7:0]   CIRC;




//-------------------------student device under test------

 TOP_OF_YOUR_BICYCLE student_dut (
   .clock(CLK),
   .mode(MODE),
   .reed(REED),
   .reset(RESET),
   .circ(CIRC),
   .DAY(dut_day),
   .AVS(dut_avs),
   .TIM(dut_tim),
   .MAX(dut_max),
   .col(dut_col),
   .point(dut_point),
   .lower0001(dut_lower0001),
   .lower0010(dut_lower0010),
   .lower0100(dut_lower0100),
   .lower1000(dut_lower1000),
   .upper01(dut_upper01),
   .upper10(dut_upper10)
 );
 
//-----------------------------------------------------




  parameter real  frq         = 2048;         //Hz
  parameter     f_clk       = 2048;         //Hz
  real            ClkPeriod   = 1000000/frq;  //us

integer                     file, r, c;
reg [8*`MAX_LINE_LENGTH:0]  comment; // Space for the comments after each input

integer     clkcounter = 0, scounter = 0;

real        input_time;
integer     speed_input;
reg [1:0]   keys;

integer     periodreed = 1000000000, periodreedcount = 0;

initial                 // Initial values
begin
                CLK     <= 1;
                CIRC    <= 255;
                RESET   <= 0;
                MODE    <= 0;
                REED    <= 0;
end

always                  // Clock generation
    #(ClkPeriod/2)     CLK <= ~CLK;

always @(posedge CLK)   // Counters for clocks and seconds.
begin
    clkcounter <= clkcounter + 1;
    scounter <= clkcounter/frq;
end

initial                 // Input file reading for stimuli generation
begin   : file_block
    file = $fopen("../../../../../sources/tb/input.txt", "r");
    if (file == `NULL)
	begin
		file = $fopen("../../../../../../sources/tb/input.txt", "r");
		if (file == `NULL) begin
			$stop; //disable file_block;
		end
	end
    
    c = $fgetc(file);
    while (c != `EOF)
    begin
        if (c == "/") // Check the first character for comment
            r = $fgetc(file);
        else
            begin // Push the character back to the file then read the next timestep
                r = $ungetc(c, file);
                r = $fscanf(file, "%f\n", input_time);
                
                if ($realtime > input_time*1000) // See if the times are in order
                    $display("Error - absolute time in file is out of order - %f", input_time);
                else // Wait until the absolute time in the file, then create stimuli for that time
                    begin
                        #(input_time*1000 - $realtime)
                            r = $fscanf(file,"%d %b", speed_input, keys);
                            r = $fgets(comment, file);
                            RESET   <= keys[0];
                            MODE    <= keys[1];
                    end
                    
                if (speed_input == 0)
                    periodreed <= 1000000000;
                else
                    periodreed <= ((frq * CIRC / speed_input * 36 / 100 + 5) / 10);
                    
                #ClkPeriod // Reset signals to low after one clock period
                    keys    <= 0;
                    RESET   <= 0;
                    MODE    <= 0;
            end
            
            c = $fgetc(file);
    end
    
    $fclose(file);
end

always @(posedge CLK)   // Reed contact generation
begin
    if (periodreedcount < periodreed)
        begin
            periodreedcount <= periodreedcount + 1;
            REED <= 0;
        end
    else
        begin
            periodreedcount <= 0;
            REED <= 1;
        end
end


// Reference



  integer distance; // in cm
  wire [19:0] distance_in_100meter;
  integer speed;
  integer clocksbetweenreed;



// Statemachine for mode
  reg [1:0] modestate; 

  parameter mode_DAY = 2'd0;
  parameter mode_AVS = 2'd1;
  parameter mode_TIM = 2'd2;
  parameter mode_MAX = 2'd3; 
  always@(posedge CLK) 
  begin 
     if (RESET) begin
       modestate <= mode_DAY;
     end else if (MODE) begin
       case (modestate)
	     mode_DAY: modestate <= mode_AVS;
	     mode_AVS: modestate <= mode_TIM;
 	     mode_TIM: modestate <= mode_MAX;
	     mode_MAX: modestate <= mode_DAY;
	     default : modestate <= mode_DAY;
       endcase 
    end else begin
      modestate <= modestate;
    end
  end //Mode Statemachine
  
// count distance

  always@(posedge CLK)
  begin
    if (RESET) begin
      distance = 0;
    end else begin
      if (REED) begin
        distance <= distance + CIRC;
      end else begin
        distance <= distance;
      end
    end
  end //count distance
  assign distance_in_100meter = distance/10000;
  
  
  
// count Triptime
  integer triptime; // in clockperiods  
  wire [5:0] triptime_sec;
  wire [5:0] triptime_min;
  wire [6:0] triptime_hours; 
  always@(posedge CLK)
  begin
    if (RESET) begin
      triptime = 0;
    end else begin
      if (speed > 0) begin
        triptime <= triptime + 1;
      end else begin
        triptime <= triptime;
      end
    end
  end //count triptime
  
  assign triptime_sec = (triptime/2048)%60;
  assign triptime_min = ((triptime/2048)/60)%60;
  assign triptime_hours = ((triptime/2048)/60)/60;


// calculate speed
  parameter minspeed = 3; //km/h
  reg bikeismoving;
  always@ (posedge CLK) 
  begin
    if (RESET) begin
      bikeismoving <= 0;
	  clocksbetweenreed <= 0;
	  speed <= 0;
	end else begin
	  if (bikeismoving) begin
	    if (REED) begin
	      speed <= $rtoi($itor(CIRC)/$itor(clocksbetweenreed) * ($itor(3600)*$itor(2048)/$itor(100000)));
	      clocksbetweenreed <= 0;
	      bikeismoving <= bikeismoving;
	    end else begin
	      if (clocksbetweenreed > (CIRC*f_clk*3600/(minspeed*100000))) begin  // speed smaller then 3 km/h
	        clocksbetweenreed <= 0;
	        speed <= 0;
	        bikeismoving = 0;
	      end else begin
	        speed <= speed;
	        clocksbetweenreed <= clocksbetweenreed + 1;
	        bikeismoving <= bikeismoving;
	      end
	    end
	  end else begin
	    if (REED)  begin
	      bikeismoving <= 1;
	      clocksbetweenreed <= 0;
	      speed <= speed;
	    end else begin
	       bikeismoving <= bikeismoving;
	       clocksbetweenreed <= clocksbetweenreed;
	       speed <= speed;
	    end
	  end
	end
  end //calulate speed
  
  
// calulate average speed
  integer averagespeed;
  reg  [10:0] seccounter;
  always @(posedge CLK)
  begin
    if (RESET) begin
      seccounter <= 0;
      averagespeed <= 0;
    end else begin
      if (seccounter == 0) begin
        if (triptime > 0) begin
          averagespeed <= $rtoi($itor(distance)/$itor(triptime)*($itor(3600)*$itor(2048)/$itor(10000)));  
        end else begin
          averagespeed <= 0;
        end
      end else begin
        averagespeed <= averagespeed;
      end
      seccounter <= seccounter+1;
    end
  end //calculate average speed
  
  
// calculate maximumspeed
  integer maximumspeed;
  always@(posedge CLK)
  begin
    if (RESET) begin
      maximumspeed <= 0;
    end else begin
      if (maximumspeed < speed) begin
        maximumspeed <= speed;
      end else begin
        maximumspeed <= maximumspeed;
      end
    end
  end // calculate maximumspeed

  
  //Display
  integer value;
  
  always @ (posedge CLK) 
  begin
    case (modestate)
	  mode_DAY: value <= distance_in_100meter;
	  mode_AVS: value <= averagespeed; 
 	  mode_TIM:
	  	begin
	      if (triptime > ((f_clk*3600)-1)) begin
	        value <= ((triptime / (f_clk * 60)) / 60) * 100 + //hours
	                 ((triptime / (f_clk * 60)) % 60);        //minutes
	      end else begin 
	        value <= ((triptime / (f_clk )) / 60) * 100 +    //minutes
	                 ((triptime / (f_clk )) % 60);           //seconds
	      end
	    end 
      mode_MAX: value <= maximumspeed;
	  default : value <= 9999;
    endcase 
  end
  
  
  //Display Speed
  assign ref_upper10 = 48 + ((speed / 10**(1))%10);
  assign ref_upper01 = 48 + ((speed / 10**(0))%10);
  
  //Display others 
  assign ref_lower1000 = 48 + ((value / 10**(3))%10);
  assign ref_lower0100 = 48 + ((value / 10**(2))%10);
  assign ref_lower0010 = 48 + ((value / 10**(1))%10);
  assign ref_lower0001 = 48 + ((value / 10**(0))%10);

  //Status LEDs
  assign ref_day = (modestate == mode_DAY) ? 1:0;
  assign ref_avs = (modestate == mode_AVS) ? 1:0;
  assign ref_tim = (modestate == mode_TIM) ? 1:0;
  assign ref_max = (modestate == mode_MAX) ? 1:0;
  
  //Point
  assign ref_point = ((modestate == mode_DAY) || 
                      (modestate == mode_AVS)) ? 1 : 0;
  assign ref_col = (modestate == mode_TIM) ? 1:0;
  

// stop after 200 s
initial #(200*1000000) $finish;

endmodule
