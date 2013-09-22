module toplevel( input        CLK,
                 input  [1:0] BTNS,
                 
                 input  [3:0] DIP_SW,
                 output [7:0] LEDS,
                
                 output       UART_TX,
                 input        UART_RX,

                 inout        SDA,
                 inout        SCL,

                 input  [5:0] RADIO,
                 output [3:0] ENGINE,

                 output       HP_CE,
                 output       HP_RS,
                 output       HP_RESET,
                 output       HP_BLANK,
                 output       HP_DO,
                 output       HP_CLK );


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
                   .LEDS    ( LEDS       ) );

uart_top uart_top( .CLK     ( CLK_CPU    ),
                   .RESET   ( reset      ),
                   .WE      ( IO.UART_WE ),
                   .RE      ( IO.UART_RE ),
                   .A       ( IO.UART_A  ),
                   .WD      ( IO.UART_WD ),
                   .RD      ( IO.UART_RD ),
                   .UART_TX ( UART_TX    ),
                   .UART_RX ( UART_RX    ) );

i2c_top   i2c_top( .CLK     ( CLK_CPU    ),
                   .RESET   ( reset      ),
                   .A       ( IO.I2C_A   ),
                   .RD      ( IO.I2C_RD  ),
                   .SDA     ( SDA        ),
                   .SCL     ( SCL        ) );

quad_control qcon( .CLK     ( CLK_CPU    ),
                   .RESET   ( reset      ),
                   .WE      ( IO.QCON_WE ),
                   .A       ( IO.QCON_A  ),
                   .WD      ( IO.QCON_WD ),
                   .RD      ( IO.QCON_RD ),
                   .RADIO   ( RADIO      ),
                   .ENGINE  ( ENGINE     ) ); 

hp_display  hdspl( .CLK       ( CLK       ),
                   .RESET     ( reset     ),
                   .WE        ( IO.HP_WE  ),
                   .A         ( IO.HP_A   ),
                   .WD        ( IO.HP_WD  ),
                   .RD        ( IO.HP_RD  ), .*);
/*                   .HP_CE     ( HP_CE     ),
                   .HP_RS     ( HP_RS     ),
                   .HP_RESET  ( HP_RESET  ),
                   .HP_BLANK  ( HP_BLANK  ),
                   .HP_DO     ( HP_DO     ),
                   .HP_CLK    ( HP_CLK    ) );
*/
endmodule
