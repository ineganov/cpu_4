module testbench;

logic        CLK, BTN, UART_TX, UART_RX, DM9K_CLK,  DM9K_RESET, DM9K_INT, 
             DM9K_CMD, DM9K_CS, DM9K_RD, DM9K_WR, MCLK, BCLK, DACLRC, 
             DACDAT, BCLK_2, DACLRC_2, DACDAT_2;

logic [25:0] LEDS;   
logic [17:0] DIP_SW;
logic  [7:0] HEX_0, HEX_1, HEX_2, HEX_3,
             HEX_4, HEX_5, HEX_6, HEX_7;

wire  [15:0] DM9K_DATA;
wire         SDA, SCL; 

toplevel toplevel(.*);                  

endmodule
