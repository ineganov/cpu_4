module audio_sink_cpu ( input         CLK,
                        input         CLK_AUDIO,
                        input         RESET,

                        output [31:0] RD,
                        input  [23:0] WD,
                        input         WE,
                        input         A,

                        output        MCLK,
                        output        BCLK,
                        output        DACLRC,
                        output        DACDAT );

logic [23:0] left_q, right_q, rd_left, rd_right;
logic [10:0] used_w;
logic        wr_req, rd_req, aud_reset;

ffd #(24) ffd_left (CLK, RESET, WE & ~A, WD,  left_q);
ffd #(24) ffd_right(CLK, RESET, WE &  A, WD, right_q);

ffds #(1) ffd_wr(CLK, WE & A, wr_req);

fifo  dc_fifo ( .wrclk   ( CLK                   ),
                .data    ( { left_q, right_q }   ),
                .wrreq   ( wr_req                ),
                .wrusedw ( used_w                ),
                .rdclk   ( CLK_AUDIO             ),
                .rdreq   ( rd_req                ),
                .q       ( { rd_left, rd_right } ));

autoreset #(8) aud_autoreset(CLK, 1'b0, aud_reset);

dac_i2s dac_i2s(  .MCLK       ( CLK_AUDIO ),
                  .RESET      ( aud_reset ),
                  .LEFT_DATA  ( rd_left   ),
                  .RIGHT_DATA ( rd_right  ),
                  .ADV        ( rd_req    ),
                  .BCLK       ( BCLK      ),
                  .DACLRC     ( DACLRC    ),
                  .DACDAT     ( DACDAT    ) );

assign RD   = { 21'd0, used_w };
assign MCLK = CLK_AUDIO;

endmodule
