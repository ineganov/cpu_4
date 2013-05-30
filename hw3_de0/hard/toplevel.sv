module toplevel( input        CLK,
                 input  [1:0] BTNS,
                 
                 input  [3:0] DIP_SW,
                 output [7:0] LEDS,
                
                 output       UART_TX,
                 input        UART_RX,

                 inout        SDA,
                 inout        SCL );

logic  [3:0] dip_sw_sync;
logic        btn_s, reset, CLK_CPU, CLK_IO;
if_io        IO();

pll pll(CLK, CLK_CPU, CLK_IO);

sync reset_sync(CLK_CPU, ~BTNS[0], btn_s);

autoreset #(8) autoreset(CLK_CPU, btn_s, reset);


mcpu mcpu(CLK_CPU, reset, IO );

ffd  #(8) led_reg(CLK_CPU, reset, IO.LEDS_WE, IO.LEDS_WD, LEDS);
ffd  #(4) dip_fd1(CLK_IO,  reset, 1'b1, DIP_SW,      dip_sw_sync);
ffd  #(4) dip_fd2(CLK_IO,  reset, 1'b1, dip_sw_sync, IO.LEDS_RD );

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



logic [7:0] i2c_data, gyro_z_hi_q, gyro_z_lo_q, gyro_y_hi_q, 
            gyro_y_lo_q, gyro_x_hi_q, gyro_x_lo_q;

logic       i2c_en, i2c_st;

ffd #(8) gyro_zl_fd(CLK, i2c_st, i2c_en, i2c_data,    gyro_z_lo_q );
ffd #(8) gyro_zh_fd(CLK, i2c_st, i2c_en, gyro_z_lo_q, gyro_z_hi_q );
ffd #(8) gyro_yl_fd(CLK, i2c_st, i2c_en, gyro_z_hi_q, gyro_y_lo_q );
ffd #(8) gyro_yh_fd(CLK, i2c_st, i2c_en, gyro_y_lo_q, gyro_y_hi_q );
ffd #(8) gyro_xl_fd(CLK, i2c_st, i2c_en, gyro_y_hi_q, gyro_x_lo_q );
ffd #(8) gyro_xh_fd(CLK, i2c_st, i2c_en, gyro_x_lo_q, gyro_x_hi_q );

ffd #(16) gyro_x_fd(CLK, reset, i2c_st, {gyro_x_hi_q, gyro_x_lo_q}, IO.GYRO_X);
ffd #(16) gyro_y_fd(CLK, reset, i2c_st, {gyro_y_hi_q, gyro_y_lo_q}, IO.GYRO_Y);
ffd #(16) gyro_z_fd(CLK, reset, i2c_st, {gyro_z_hi_q, gyro_z_lo_q}, IO.GYRO_Z);

i2c_master  i2c_master ( .CLK      ( CLK_CPU  ),
                         .RESET    ( reset    ),
                         .DATA_OUT ( i2c_data ),
                         .DATA_EN  ( i2c_en   ),
                         .DATA_ST  ( i2c_st   ),
                         .SDA      ( SDA      ),
                         .SCL      ( SCL      ) );


endmodule
