module toplevel( input         CLK,
                 input   [1:0] BTNS,
                 
                 input  [17:0] DIP_SW,
                 output [25:0] LEDS,
                 
                 output  [7:0] HEX_0,
                 output  [7:0] HEX_1,
                 output  [7:0] HEX_2,
                 output  [7:0] HEX_3,
                 output  [7:0] HEX_4,
                 output  [7:0] HEX_5,
                 output  [7:0] HEX_6,
                 output  [7:0] HEX_7,
                 
                 output        UART_TX,
                 input         UART_RX,

                 output        SD_CLK,
                 inout         SD_CMD,
                 inout   [3:0] SD_DAT,
                 output  [5:0] DEBUG );


logic  CLK_CPU, reset;
if_io  IO();
assign CLK_CPU = CLK;

mcpu the_processor( CLK_CPU, reset, IO );

board_io board_io( .CLK     ( CLK_CPU    ),
                   .SRESET  ( reset      ),
                   .WE      ( IO.LEDS_WE ),
                   .A       ( IO.LEDS_A  ),
                   .WD      ( IO.LEDS_WD ),
                   .RD      ( IO.LEDS_RD ),
                   .INT_BTN ( IO.INT_BTN ),
                   .BTNS    ( BTNS       ),
                   .DIP_SW  ( DIP_SW     ),
                   .LEDS    ( LEDS       ), .*);

uart_top uart_top( .CLK     ( CLK_CPU    ),
                   .RESET   ( reset      ),
                   .WE      ( IO.UART_WE ),
                   .RE      ( IO.UART_RE ),
                   .A       ( IO.UART_A  ),
                   .WD      ( IO.UART_WD ),
                   .RD      ( IO.UART_RD ),
                   .UART_TX ( UART_TX    ),
                   .UART_RX ( UART_RX    ) );

sdcard_top             sdcard_top ( .CLK     ( CLK_CPU       ),
                                    .RESET   ( reset         ),
                                    .WE      ( IO.SDCARD_WE  ),
                                    .RE      ( IO.SDCARD_RE  ),
                                    .A       ( IO.SDCARD_A   ),
                                    .WD      ( IO.SDCARD_WD  ),
                                    .RD      ( IO.SDCARD_RD  ),
                                    .SD_CLK  ( SD_CLK        ),
                                    .SD_CMD  ( SD_CMD        ),
                                    .SD_DAT  ( SD_DAT        ) );


assign DEBUG[5] = SD_CLK;
assign DEBUG[4] = SD_CMD;
assign DEBUG[3:0] = SD_DAT;

endmodule


