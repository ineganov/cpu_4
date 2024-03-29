module uart_tx ( input        CLK,
                 input        RESET,
                
                 input  [7:0] DATA,
                 input        EN,
                 output       READY,

                 input [15:0] BIT_TIME,
                 input        PARITY_EN,
                 input        PARITY_ODD,
                
                 output       TX );
                
logic        ready, par_ovr, fsm_ovr, fsm_val, sr_q, tx_logic,
             bit_done, byte_done, bit_inc, par_fd_in, par_fd_q;
logic [15:0] bit_cnt;
logic  [2:0] byte_cnt;

assign bit_done  = (bit_cnt  == BIT_TIME);
assign byte_done = (byte_cnt == 3'd7);
assign bit_inc   = bit_done & ~fsm_ovr;

shift_out_reg_right #(8) sr(CLK, EN & ready, bit_inc, DATA, sr_q);

counter #(16) bit_counter (CLK, ready | bit_done, 1'b1, bit_cnt  );

counter #(3)  byte_counter(CLK, ready,         bit_inc, byte_cnt );

assign par_fd_in = (EN & ready) ? PARITY_ODD : (par_fd_q ^ sr_q);

ffd #(1) parity_fd(CLK, RESET, (EN & ready) | bit_inc, par_fd_in, par_fd_q);
ffd #(1) output_fd(CLK, RESET, 1'b1, tx_logic, TX );

uart_tx_fsm fsm( .CLK       ( CLK       ),
                 .RESET     ( RESET     ),
                 .EN        ( EN        ),
                 .BIT_DONE  ( bit_done  ),
                 .BYTE_DONE ( byte_done ),
                 .PARITY_EN ( PARITY_EN ),
                 .READY     ( ready     ),
                 .PAR_OVR   ( par_ovr   ),
                 .FSM_OVR   ( fsm_ovr   ),
                 .FSM_VAL   ( fsm_val   ) );

assign READY = ready;
assign tx_logic = par_ovr ? par_fd_q :
                  fsm_ovr ? fsm_val  : 
                                sr_q ;
                
endmodule
//=========================================================================//
module uart_tx_fsm( input  CLK,
                    input  RESET,
                    input  EN,
                    input  BIT_DONE,
                    input  BYTE_DONE,
                    input  PARITY_EN,
                    output READY,
                    output PAR_OVR,
                    output FSM_OVR,
                    output FSM_VAL );
//--------------------------------------------------------//
enum int unsigned { ST_READY      = 0, 
                    ST_START_BIT  = 1, 
                    ST_DATA_BIT   = 2,
                    ST_PARITY_BIT = 3, 
                    ST_STOP_BIT   = 4 } state, next;
//--------------------------------------------------------//
always_ff@(posedge CLK)
  if(RESET) state <= ST_READY;
  else      state <= next;
//--------------------------------------------------------//
always_comb begin
  next = ST_READY;
  case(state)
  ST_READY:      if(EN)                next = ST_START_BIT;
                 else                  next = state;
                
  ST_START_BIT:  if(BIT_DONE)          next = ST_DATA_BIT;
                 else                  next = state;
                
  ST_DATA_BIT:   if(BIT_DONE & 
                    BYTE_DONE)
                    begin
                     if(PARITY_EN)     next = ST_PARITY_BIT;
                     else              next = ST_STOP_BIT;
                    end       
                 else                  next = state;

  ST_PARITY_BIT: if(BIT_DONE)          next = ST_STOP_BIT;
                 else                  next = state;
                
  ST_STOP_BIT:   if(BIT_DONE)          next = ST_READY;
                 else                  next = state;
  
  default:                             next = ST_READY;
  endcase
end
//--------------------------------------------------------//
assign READY   = (state == ST_READY );

assign PAR_OVR = (state == ST_PARITY_BIT);

assign FSM_OVR = (state != ST_DATA_BIT);

assign FSM_VAL = ((state == ST_READY)  | 
                  (state == ST_STOP_BIT));
//--------------------------------------------------------//
endmodule
//=========================================================================//