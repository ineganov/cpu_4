module buffered_rx #(  parameter D = 5, T = 40)
                    (  input         CLK,
                       input         RESET,
                       input  [15:0] BIT_TIME,
                       input         PARITY_EN,
                       input         PARITY_ODD,
                       input         RE,
                       input         WE,
                       input         A,
                       output [31:0] RD,
                       input         UART_RX );

logic  [31:0] status_word, data_word;
logic   [7:0] rx_data, fifo_word, full_fill;
logic [D-1:0] fill;
logic         n_empty, ovflow, ov_q, rx_err, err_q, rx_en;

simple_fifo #(D, 8) simple_fifo( .CLK       ( CLK             ),
                                 .RESET     ( RESET | (WE & A)),
                                 .RE        ( RE & ~A         ),
                                 .WE        ( rx_en           ),
                                 .R_DATA    ( fifo_word       ),
                                 .W_DATA    ( rx_data         ),
                                 .NOT_EMPTY ( n_empty         ),
                                 .FILL      ( fill            ),
                                 .OVFLOW    ( ovflow          ) );


uart_rx uart_rx ( .CLK        ( CLK        ),
                  .RESET      ( RESET      ),
                  .BIT_TIME   ( BIT_TIME   ),
                  .PARITY_EN  ( PARITY_EN  ),
                  .PARITY_ODD ( PARITY_ODD ),                
                  .DATA       ( rx_data    ),
                  .EN         ( rx_en      ),
                  .PARITY_ERR ( rx_err     ),
                  .IDLE       (            ),
                  .RX         ( UART_RX    ) );

rsd ovflow_rsd(CLK, RESET | (WE & A), ovflow,  ov_q);
rsd  error_rsd(CLK, RESET | (WE & A), rx_err, err_q);

assign full_fill = fill;
assign status_word = { n_empty, ov_q, err_q, 1'b0, 20'd0, full_fill};
assign data_word   = { 24'd0, fifo_word };

assign RD = A ? status_word : data_word;

endmodule
