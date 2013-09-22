//=========================================================================//
module uart_rx ( input        CLK,
                 input        RESET,
                 
                 input [15:0] BIT_TIME,
                 input        PARITY_EN,
                 input        PARITY_ODD,                

                 output [7:0] DATA,
                 output       EN,
                 output       PARITY_ERR,
                 output       IDLE,
                
                 input        RX );

logic any_edge, neg_edge, count_en, half_period, full_period,
      byte_done, data_bit, dp_bit, start_bit, cnt_reset, resync,
      par_fd_in, par_fd_q, shift_bit, shift_bit_p, rx_s;

logic [15:0] bit_cnt_q;
logic  [2:0] byte_cnt_q;

sync_edetect sd(CLK, RX, rx_s, any_edge, neg_edge);

assign resync      = (half_period & start_bit);
assign shift_bit   = (full_period & data_bit);
assign shift_bit_p = (full_period & dp_bit);

assign half_period = (bit_cnt_q == {1'b0, BIT_TIME[15:1]}); //BIT_TIME/2
assign full_period = (bit_cnt_q == BIT_TIME);
assign cnt_reset = ~count_en | resync | shift_bit_p;

counter #(16) bit_time_cnt(CLK, cnt_reset, count_en, bit_cnt_q );

assign byte_done = (byte_cnt_q == 3'd7);
counter #(3) byte_cnt(CLK, resync, shift_bit, byte_cnt_q );

shift_in_reg_right #(8) sr( CLK, resync, shift_bit, rx_s, DATA );

assign par_fd_in = resync ? PARITY_ODD : (par_fd_q ^ rx_s);
ffd #(1) parity_fd(CLK, RESET, resync | shift_bit_p, par_fd_in, par_fd_q);

uart_rx_fsm fsm( .CLK         ( CLK         ),
                 .RESET       ( RESET       ),
                 .NEG_EDGE    ( neg_edge    ),
                 .ANY_EDGE    ( any_edge    ),
                 .HALF_PERIOD ( half_period ),
                 .FULL_PERIOD ( full_period ),
                 .BYTE_DONE   ( byte_done   ),
                 .PARITY_EN   ( PARITY_EN   ),
                 .COUNT_EN    ( count_en    ),
                 .START_BIT   ( start_bit   ),
                 .DATA_BIT    ( data_bit    ),
                 .DP_BIT      ( dp_bit      ),
                 .DONE        ( EN          ),
                 .READY       ( IDLE        ) );

assign PARITY_ERR = par_fd_q & EN;

endmodule
//=========================================================================//
module uart_rx_fsm( input  CLK,
                    input  RESET,
                    input  NEG_EDGE,
                    input  ANY_EDGE,
                    input  HALF_PERIOD,
                    input  FULL_PERIOD,
                    input  BYTE_DONE,
                    input  PARITY_EN,
                    output COUNT_EN,
                    output START_BIT,
                    output DATA_BIT,
                    output DP_BIT,
                    output DONE,
                    output READY );
//--------------------------------------------------------//
enum int unsigned { ST_READY      = 0, 
                    ST_START_BIT  = 1, 
                    ST_DATA_BIT   = 2,
                    ST_PARITY_BIT = 3, 
                    ST_DONE       = 4 } state, next;
//--------------------------------------------------------//
always_ff@(posedge CLK)
  if(RESET) state <= ST_READY;
  else      state <= next;
//--------------------------------------------------------//
always_comb begin
  next = ST_READY;
  case(state)
  ST_READY:      if(NEG_EDGE)          next = ST_START_BIT;
                 else                  next = state;
                
  ST_START_BIT:  if(ANY_EDGE)          next = ST_READY;
                 else if(HALF_PERIOD)  next = ST_DATA_BIT;
                 else                  next = state;
                
  ST_DATA_BIT:   if(FULL_PERIOD & 
                    BYTE_DONE)
                    begin
                     if(PARITY_EN)     next = ST_PARITY_BIT;
                     else              next = ST_DONE;
                    end       
                 else                  next = state;

  ST_PARITY_BIT: if(FULL_PERIOD)       next = ST_DONE;
                 else                  next = state;
                
  ST_DONE:                             next = ST_READY;
  
  default:                             next = ST_READY;
  endcase
end
//--------------------------------------------------------//
assign START_BIT = (state == ST_START_BIT);

assign DATA_BIT  = (state == ST_DATA_BIT);

assign DP_BIT    = DATA_BIT | (state == ST_PARITY_BIT);

assign COUNT_EN  = DP_BIT   | (state == ST_START_BIT);

assign DONE      = (state == ST_DONE);

assign READY     = (state == ST_READY);

endmodule
//=========================================================================//

