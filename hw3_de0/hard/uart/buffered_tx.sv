module buffered_tx #(  parameter D = 5, T = 40)
                    (  input         CLK,
                       input         RESET,
                       input         WE,
                       input         A,
                       input  [31:0] WD,
                       output [31:0] RD,
                       output        UART_TX );

logic  [31:0] status_word, data_word;
logic   [7:0] fifo_word, full_fill;
logic [D-1:0] fill;
logic         ready, n_empty, ovflow, ov_q, fifo_reset;

simple_fifo #(D, 8) simple_fifo( .CLK       ( CLK                ),
                                 .RESET     ( RESET | fifo_reset ),
                                 .RE        ( n_empty & ready    ),
                                 .WE        ( WE & ~A            ),
                                 .R_DATA    ( fifo_word          ),
                                 .W_DATA    ( WD[7:0]            ),
                                 .NOT_EMPTY ( n_empty            ),
                                 .FILL      ( fill               ),
                                 .OVFLOW    ( ovflow             ) );

uart_tx  #(T) uart_tx( .CLK        ( CLK       ),
                       .RESET      ( RESET     ),
                       .DATA       ( fifo_word ),
                       .EN         ( n_empty   ),
                       .PARITY_EN  ( 1'b1      ),
                       .PARITY_ODD ( 1'b1      ),
                       .READY      ( ready     ),
                       .TX         ( UART_TX   ));


rsd ovflow_rsd(CLK, RESET | fifo_reset, ovflow, ov_q);

assign fifo_reset = WE & A;
assign full_fill = fill;

assign status_word = { n_empty, ov_q, 2'd0, 20'd0, full_fill};
assign data_word   = { 32'd0 };

assign RD = A ? status_word : data_word;


endmodule
