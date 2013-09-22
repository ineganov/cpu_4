module uart_top ( input         CLK,
                  input         RESET,
                  input         WE,
                  input         RE,
                  input   [2:0] A,
                  input  [31:0] WD,
                  output [31:0] RD,
                  output        UART_TX,
                  input         UART_RX  );

logic [31:0] rx_rd, tx_rd;
logic [15:0] bit_time;
logic        par_en, par_odd;

ffd #(16) speed_fd(CLK, RESET, WE & (A == 3'd4), WD[15:0], bit_time);
ffd  #(2)   par_fd(CLK, RESET, WE & (A == 3'd6),  WD[1:0], {par_odd, par_en});   

buffered_rx #(5, 434) buffered_rx ( .CLK        ( CLK        ),
                                    .RESET      ( RESET      ),
                                    .BIT_TIME   ( bit_time   ),
                                    .PARITY_EN  ( par_en     ),
                                    .PARITY_ODD ( par_odd    ),
                                    .RE         ( RE & ~A[2] & A[1]  ),
                                    .WE         ( WE & ~A[2] & A[1]  ),
                                    .A          ( A[0]       ),
                                    .RD         ( rx_rd      ),
                                    .UART_RX    ( UART_RX    ) );


buffered_tx #(5, 434) buffered_tx ( .CLK        ( CLK        ),
                                    .RESET      ( RESET      ),
                                    .BIT_TIME   ( bit_time   ),
                                    .PARITY_EN  ( par_en     ),
                                    .PARITY_ODD ( par_odd    ),
                                    .WE         ( WE & ~A[2] & ~A[1] ),
                                    .A          ( A[0]       ),
                                    .WD         ( WD         ),
                                    .RD         ( tx_rd      ),
                                    .UART_TX    ( UART_TX    ) );

mux4 #(32) omux( A[2:1],
                 tx_rd,
                 rx_rd,
                 {16'd0, bit_time},
                 {30'd0, par_odd, par_en},
                 RD );

endmodule
