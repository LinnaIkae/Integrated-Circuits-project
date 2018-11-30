`timescale 1us/10ns


module dual2bcd #(
  parameter dualwidth=14,
  parameter bcdwidth=16,
  parameter bcddigit=bcdwidth/4
)(
  input wire clock,
  input wire reset,
  input wire start,
  input wire [dualwidth-1:0] dual,
  output reg finish,
  output reg [bcdwidth-1:0] bcd
);


// start of module description

integer k;
integer l;
reg [dualwidth-1:0] dual_int;
reg [3:0] bcdshift_tmp;
reg [bcdwidth-1:0] bcd_int;
always @ (posedge clock)
begin
  if (reset)
  begin
    bcd <= 0;
    finish <= 0;
    k <= dualwidth;
  end else if (start)
  begin
    bcd_int = 0;
    dual_int = dual;
    finish <= 0;
    k <= 0;
  end else
  begin
    if (k <= dualwidth-1)
    begin
      l=0;
      while (l<bcddigit)
      begin
        bcdshift_tmp = bcd_int[bcdwidth-1:bcdwidth-4];
        if ( bcdshift_tmp >= 5 )
          bcdshift_tmp = bcdshift_tmp + 3;
        bcd_int = {bcd_int[bcdwidth-4:0],bcdshift_tmp};
        l=l+1;
      end

      bcd_int = {bcd_int[bcdwidth-2:0],dual_int[dualwidth-1]};
      dual_int=dual_int << 1;
      k <= k+1;
    end
    if (k == dualwidth-1)
    begin
      finish <= 1;
      bcd <= bcd_int;
    end
    if (finish)
      finish <= 0;
  end
end

endmodule
