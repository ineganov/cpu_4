module testbench;

logic       CLK, UART_TX, UART_RX;
logic [1:0] BTNS;
logic [3:0] DIP_SW;
logic [7:0] LEDS;

always
   begin
   #10ns;
   CLK = ~CLK;
   end

initial
   begin
   CLK = 0;
   BTNS[1] = 1;
   BTNS[0] = 0;
   #300ns;
   BTNS[0] = 1;
   end

toplevel uut(.*);

endmodule
