module testbench;

logic       CLK, RESET;
logic [7:0] leds;
if_io       IO();

always
   begin
   #10ns;
   CLK = ~CLK;
   end

initial
   begin
   CLK = 0;
   RESET = 1;
   #100ns;
   RESET = 0;
   end


assign IO.INT_BTN = 0;
assign IO.LEDS_RD = 0;

always@(posedge CLK)
   if(IO.LEDS_WE) leds <= IO.LEDS_WD[7:0];

mcpu the_cpu(CLK, RESET, IO);

endmodule
