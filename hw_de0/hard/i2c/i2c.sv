module i2c   ( input        CLK,
               input        RESET,

               input        START,     
               output       BUSY,

               input  [7:0] DATA_IN,  
               output [7:0] DATA_OUT,  
               output       RD_ADV,
               output       WR_ADV,

               inout        SDA,
               inout        SCL );

parameter TAU = 63;

logic ld_len, ld_wlen, adv, l_done, byte_done, read_mode, half_period;
logic l_scl, l_sda, scl_q, sda_q, l_data, l_ack, sreg_out, next_byte, adv_wlen;
logic s_idle, s_start, s_stop_lo, s_stop_hi, s_data_lo, s_data_hi, s_ack_lo, s_ack_hi;
logic shift_in, nack_hack;

assign next_byte = ( half_period & s_data_hi & byte_done & ~l_done );
assign adv_wlen = ( half_period & s_ack_hi & byte_done & ~read_mode);
assign RD_ADV = (next_byte & ~read_mode) | ld_len | ld_wlen;

inv_ld_counter #(7)  len_cnt( .CLK  ( CLK          ),  
                              .SET  ( ld_len       ), 
                              .IN   ( DATA_IN[6:0] ), 
                              .EN   ( next_byte    ),    
                              .ZERO ( l_done       ) );

inv_ld_counter #(7) wlen_cnt( .CLK  ( CLK          ), 
                              .SET  ( ld_wlen      ), 
                              .IN   ( DATA_IN[6:0] ), 
                              .EN   ( adv_wlen     ), 
                              .ZERO ( read_mode    ));

ffd #(1) nack_hack_fd(CLK, RESET, ld_wlen, DATA_IN[7], nack_hack);

logic [5:0] time_cnt;
assign half_period = (time_cnt == TAU);
counter #(6) time_count(CLK, s_idle | half_period, 1'b1, time_cnt);

shift_out_reg_left #(8) sr_out(  .CLK    ( CLK                                  ), 
                                 .UPDATE ( half_period & (s_start | s_ack_hi)   ), 
                                 .SHIFT  ( half_period & s_data_hi & ~byte_done ), 
                                 .DATA   ( DATA_IN                              ), 
                                 .OUT    ( sreg_out                             ),  
                                 .EMPTY  ( byte_done                            ));

assign shift_in = read_mode & half_period & s_data_hi;
assign WR_ADV = read_mode & half_period & s_ack_hi & byte_done;
shift_in_reg_left   #(8) sr_in(  .CLK   ( CLK                                ),
                                 .RESET ( half_period & (s_start | s_ack_hi) ),
                                 .SHIFT ( shift_in                           ),
                                 .IN    ( SDA                                ),
                                 .DATA  ( DATA_OUT                           ));

 i2c_fsm  i2c_fsm(  .CLK       ( CLK         ),
                    .RESET     ( RESET       ),
                    .START     ( START       ),
                    .TIME      ( half_period ),
                    .L_DONE    ( l_done      ),
                    .W_DONE    ( byte_done   ),
                    .LD_LEN    ( ld_len      ),
                    .LD_WLEN   ( ld_wlen     ),
                    .S_DATA_LO ( s_data_lo   ),
                    .S_DATA_HI ( s_data_hi   ),
                    .S_ACK_LO  ( s_ack_lo    ),
                    .S_ACK_HI  ( s_ack_hi    ),
                    .S_START   ( s_start     ),
                    .S_STOP_LO ( s_stop_lo   ),
                    .S_STOP_HI ( s_stop_hi   ),
                    .S_IDLE    ( s_idle      ));

assign BUSY = ~s_idle;
assign l_scl = (s_data_lo | s_ack_lo | s_stop_lo) ? 1'b0 : 1'b1;


assign l_data = sreg_out | read_mode;
assign l_ack  = ~read_mode ^ (nack_hack & l_done); //invert the last ack into NACK for MPU6050

assign l_sda = (s_start   | s_stop_lo | s_stop_hi ) ? 1'b0   :
               (s_data_lo | s_data_hi)              ? l_data :
               (s_ack_lo  | s_ack_hi )              ? l_ack  : 
                                                      1'b1;

ffds #(1) scl_fd(CLK, l_scl, scl_q);
ffds #(1) sda_fd(CLK, l_sda, sda_q);

assign SDA = sda_q ? 1'bZ : 1'b0;
assign SCL = scl_q ? 1'bZ : 1'b0;

endmodule

module i2c_fsm (  input CLK,
                  input RESET,

                  input  START,
                  input  TIME,
                  input  L_DONE,
                  input  W_DONE,
                  output LD_LEN,
                  output LD_WLEN,
                  output S_DATA_LO,
                  output S_DATA_HI,
                  output S_ACK_LO,
                  output S_ACK_HI,
                  output S_START,
                  output S_STOP_LO,
                  output S_STOP_HI,
                  output S_IDLE );


//--------------------------------------------------------//
enum int unsigned { ST_IDLE       = 0,
                    ST_RD_LEN     = 1,
                    ST_RD_WLEN    = 2,
                    ST_START      = 3, 
                    ST_DATA_LO    = 4,
                    ST_DATA_HI    = 5,
                    ST_ACK_LO     = 6,
                    ST_ACK_HI     = 7,
                    ST_STOP_LO    = 8,
                    ST_STOP_HI    = 9,
                    ST_WAIT       = 10 } state, next;
//--------------------------------------------------------//
always_ff@(posedge CLK)
  if(RESET) state <= ST_IDLE;
  else      state <= next;
//--------------------------------------------------------//
always_comb
   case(state)
   ST_IDLE:    if(START)     next = ST_RD_LEN;
               else          next = state;

   ST_RD_LEN:                next = ST_RD_WLEN;

   ST_RD_WLEN: if(L_DONE)    next = ST_IDLE;
               else          next = ST_START;

   ST_START:   if(TIME)      next = ST_DATA_LO;
               else          next = state;

   ST_DATA_LO: if(TIME)      next = ST_DATA_HI;
               else          next = state;

   ST_DATA_HI: if(TIME)    
                  begin
                  if(W_DONE) next = ST_ACK_LO;
                  else       next = ST_DATA_LO;
                  end
               else          next = state;

   ST_ACK_LO:  if(TIME)      next = ST_ACK_HI;
               else          next = state;

   ST_ACK_HI:  if(TIME)
                  begin
                  if(L_DONE) next = ST_STOP_LO;
                  else       next = ST_DATA_LO;
                  end
               else          next = state;

   ST_STOP_LO: if(TIME)      next = ST_STOP_HI;
               else          next = state;

   ST_STOP_HI: if(TIME)      next = ST_WAIT;
               else          next = state;


   ST_WAIT:    if(TIME)      next = ST_RD_LEN;
               else          next = state;

   default:                  next = ST_IDLE;

   endcase

assign LD_LEN    = (state == ST_RD_LEN);
assign LD_WLEN   = (state == ST_RD_WLEN); 
assign S_DATA_LO = (state == ST_DATA_LO);
assign S_DATA_HI = (state == ST_DATA_HI);
assign S_ACK_LO  = (state == ST_ACK_LO);
assign S_ACK_HI  = (state == ST_ACK_HI);
assign S_START   = (state == ST_START);
assign S_STOP_LO = (state == ST_STOP_LO);
assign S_STOP_HI = (state == ST_STOP_HI);
assign S_IDLE    = (state == ST_IDLE);

endmodule


