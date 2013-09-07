module uart_top ( input         CLK,
                  input         RESET,
                  input         WE,
                  input         RE,
                  input   [1:0] A,
                  input  [31:0] WD,
                  output [31:0] RD,
                  output        UART_TX,
                  input         UART_RX  );

logic [31:0] rx_rd, tx_rd;

buffered_rx #(5, 434) buffered_rx ( .CLK     ( CLK        ),
                                    .RESET   ( RESET      ),
                                    .RE      ( RE & A[1]  ),
                                    .WE      ( WE & A[1]  ),
                                    .A       ( A[0]       ),
                                    .RD      ( rx_rd      ),
                                    .UART_RX ( UART_RX    ) );


buffered_tx #(5, 434) buffered_tx ( .CLK     ( CLK        ),
                                    .RESET   ( RESET      ),
                                    .WE      ( WE & ~A[1] ),
                                    .A       ( A[0]       ),
                                    .WD      ( WD         ),
                                    .RD      ( tx_rd      ),
                                    .UART_TX ( UART_TX    ) );

assign RD = A[1] ? rx_rd : tx_rd;

endmodule
