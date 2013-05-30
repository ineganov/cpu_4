module toplevel( input         CLK,
                 input         BTN,
                 
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

                 output        DM9K_CLK,       
                 output        DM9K_RESET,
                 input         DM9K_INT,
                 output        DM9K_CMD,
                 output        DM9K_CS,
                 output        DM9K_RD,
                 output        DM9K_WR,
                 inout  [15:0] DM9K_DATA,
 
                 output        MCLK,
                 output        BCLK,
                 output        DACLRC,
                 output        DACDAT,
                 output        BCLK_2,
                 output        DACLRC_2,
                 output        DACDAT_2,
                 inout         SDA,
                 inout         SCL );


logic [17:0] dip_sw_sync;
logic        btn_s, reset, CLK_CPU, CLK_IO, CLK_AUDIO;
if_io        IO();

pll pll(CLK, CLK_CPU, CLK_IO, CLK_AUDIO);

sync reset_sync(CLK_CPU, ~BTN, btn_s);

autoreset #(8) autoreset(CLK_CPU, btn_s, reset);

seven_seg seven_seg( .CLK   ( CLK_CPU    ), 
                     .RESET ( reset      ),
                     .EN    ( IO.SEGS_WE ),
                     .VALUE ( IO.SEGS_WD ), .*);

mcpu mcpu(CLK_CPU, reset, IO );

ffd #(26) led_reg(CLK_CPU, reset, IO.LEDS_WE, IO.LEDS_WD, LEDS);
ffd #(18) dip_fd1(CLK_IO, reset, 1'b1, DIP_SW,      dip_sw_sync);
ffd #(18) dip_fd2(CLK_IO, reset, 1'b1, dip_sw_sync, IO.LEDS_RD );

buffered_rx #(5, 434) buffered_rx ( .CLK     ( CLK_CPU       ),
                                    .RESET   ( reset         ),
                                    .RE      ( IO.UART_RX_RE ),
                                    .WE      ( IO.UART_RX_WE ),
                                    .A       ( IO.UART_RX_A  ),
                                    .RD      ( IO.UART_RX_RD ),
                                    .UART_RX ( UART_RX       ) );


buffered_tx #(5, 434) buffered_tx ( .CLK     ( CLK_CPU       ),
                                    .RESET   ( reset         ),
                                    .WE      ( IO.UART_TX_WE ),
                                    .A       ( IO.UART_TX_A  ),
                                    .WD      ( IO.UART_TX_WD ),
                                    .RD      ( IO.UART_TX_RD ),
                                    .UART_TX ( UART_TX       ) );

dm9k_io dm9k_io( .CLK   ( CLK_CPU    ),
                 .RESET ( reset      ),
                 .WE    ( IO.DM9K_WE ),
                 .WD    ( IO.DM9K_WD ),
                 .RD    ( IO.DM9K_RD ),   .*);

audio_sink_cpu audio_sink_cpu(  .CLK       ( CLK_CPU   ),
                                .CLK_AUDIO ( CLK_AUDIO ),
                                .RESET     ( reset     ),
                                .RD        ( IO.AUD_RD ),
                                .WD        ( IO.AUD_WD ),
                                .WE        ( IO.AUD_WE ),
                                .A         ( IO.AUD_A  ), .*);

i2c_master  i2c_master( .CLK   ( CLK_CPU ),
                        .RESET ( reset   ),
                        .SDA   ( SDA     ),
                        .SCL   ( SCL     ) );

assign BCLK_2   = BCLK;
assign DACLRC_2 = DACLRC;
assign DACDAT_2 = DACDAT;

endmodule
