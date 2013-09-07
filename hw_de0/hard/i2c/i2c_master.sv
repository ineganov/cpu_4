module i2c_master  ( input        CLK,
                     input        RESET,
                     output [7:0] DATA_OUT,
                     output       DATA_EN,
                     output       DATA_ST,
                     inout        SDA,
                     inout        SCL );

logic [7:0] data_in;
logic [5:0] addr;

logic       s_reset, s_config, s_set_addr, s_update, rd_adv, 
            reset_done, update, start_rst, start_upd, start,
            busy;


counter_ll_set #(6) addr_cnt(  .CLK     ( CLK        ),
                               .RESET   ( RESET      ),
                               .SET     ( s_set_addr ),
                               .SET_VAL ( 6'd29      ),
                               .ADV     ( rd_adv     ),
                               .OUT     ( addr       ) );

i2c_rom #(6, 8) rom(CLK, addr, data_in);

logic [17:0] mpu_cnt;
assign start_rst  = ((mpu_cnt == 18'd0)  & s_reset );
assign start_upd  = ((mpu_cnt == 18'd10) & s_update);
assign reset_done = (mpu_cnt == 18'd250000); // 5ms reset period
assign update     = (mpu_cnt == 18'd62500);  // 800 Hz update cycle
counter #(18) mpu_reset_counter( CLK, RESET | s_config | (update & s_update), 1'b1, mpu_cnt);

assign start = start_rst | start_upd | reset_done;
assign DATA_ST = start & s_update;

i2c_master_fsm  i2c_fsm( .CLK         ( CLK        ),
                         .RESET       ( RESET      ),
                         .RESET_DONE  ( reset_done ),
                         .CONFIG_DONE ( ~busy      ),
                         .UPDATE      ( update     ),
                         .S_RESET     ( s_reset    ),   
                         .S_CONFIG    ( s_config   ),  
                         .S_SET_ADDR  ( s_set_addr ),
                         .S_UPDATE    ( s_update   ) );

i2c   i2c( .CLK      ( CLK      ),
           .RESET    ( RESET    ),
           .START    ( start    ),     
           .BUSY     ( busy     ),
           .DATA_IN  ( data_in  ),  
           .DATA_OUT ( DATA_OUT ),  
           .RD_ADV   ( rd_adv   ),
           .WR_ADV   ( DATA_EN  ),
           .SDA      ( SDA      ),
           .SCL      ( SCL      ));

endmodule
//============================================================//
module i2c_master_fsm ( input  CLK,
                        input  RESET,
                        input  RESET_DONE,
                        input  CONFIG_DONE,
                        input  UPDATE,
                        output S_RESET,   
                        output S_CONFIG,  
                        output S_SET_ADDR,
                        output S_UPDATE );
//--------------------------------------------------------//
enum int unsigned { ST_RESET      = 0,
                    ST_CONFIG     = 1,
                    ST_SET_ADDR   = 2,
                    ST_UPDATE     = 3 } state, next;
//--------------------------------------------------------//
always_ff@(posedge CLK)
  if(RESET) state <= ST_RESET;
  else      state <= next;

always_comb
   case(state)
   ST_RESET:    if(RESET_DONE)  next = ST_CONFIG;
                else            next = state;

   ST_CONFIG:   if(CONFIG_DONE) next = ST_UPDATE;
                else            next = state;

   ST_SET_ADDR:                 next = ST_UPDATE;

   ST_UPDATE:   if(UPDATE)      next = ST_SET_ADDR;
                else            next = state;

   default:                     next = ST_RESET;  
   endcase

assign S_RESET    = (state == ST_RESET   );   
assign S_CONFIG   = (state == ST_CONFIG  );  
assign S_SET_ADDR = (state == ST_SET_ADDR);
assign S_UPDATE   = (state == ST_UPDATE  );

endmodule
//============================================================//
module i2c_rom #( parameter          DEPTH = 9,
                  parameter          WIDTH = 24 )

                ( input              CLK,
                  input  [DEPTH-1:0] ADDR_IN,
                  output [WIDTH-1:0] DATA );


logic [WIDTH-1:0] ROM[0:2**DEPTH-1];
logic [WIDTH-1:0] rd_reg;

initial
   $readmemh ("i2c.txt", ROM);

always_ff@(posedge CLK)
   rd_reg <= ROM[ADDR_IN];

assign DATA = rd_reg;

endmodule
//============================================================//





//====================================================================//
module inv_ld_counter #(  parameter SIZE = 8 ) 
                       (  input             CLK,
                          input             SET,
                          input  [SIZE-1:0] IN,
                          input             EN,
                          output            ZERO );

logic [SIZE-1:0] cnt;
                                        
always_ff@ (posedge CLK)
  if(SET)      cnt <= IN;
  else if(EN)  cnt <= cnt - 1'b1;
    
assign ZERO = (cnt == '0); //'
                                        
endmodule

module counter_ll_set #(parameter SIZE = 8) (  input             CLK,
                                               input             RESET,
                                               input             SET,
                                               input  [SIZE-1:0] SET_VAL,
                                               input             ADV,
                                               output [SIZE-1:0] OUT );

logic [SIZE-1:0] cnt, cnt_plus_one;

assign cnt_plus_one = cnt + 1'b1;                                        
always_ff@ (posedge CLK)
  if(RESET)     cnt <= '0; //'
  else if (SET) cnt <= SET_VAL;
  else if (ADV) cnt <= cnt_plus_one;
    
assign OUT = ADV ? cnt_plus_one : cnt;
                                        
endmodule

module shift_in_reg_left   #( parameter     D = 8)
                            ( input          CLK,
                              input          RESET,
                              input          SHIFT,
                              input          IN,
                              output [D-1:0] DATA );
//                              output         FULL );

//`include "log2.inc"

//parameter C = log2(D-1); 

logic [D-1:0] sreg;
//logic [C-1:0] cnt;

always_ff@(posedge CLK)
  if     (RESET)
    begin
    sreg <= '0; //'
//    cnt  <= (D-1);
    end
  else if(SHIFT)
    begin
    sreg <= {sreg[D-2:0], IN};
//    cnt <= cnt - 1'b1;
    end

assign DATA = sreg;
//assign FULL = (cnt == '0); //'

endmodule
//====================================================================//
module shift_out_reg_left #( parameter     D = 8)
                            ( input         CLK,
                              input         UPDATE,
                              input         SHIFT,
                              input [D-1:0] DATA,
                              output        OUT,
                              output        EMPTY );

`include "log2.inc"

localparam C = log2(D-1); 

logic [D-1:0] sreg;
logic [C-1:0] cnt;

always_ff@(posedge CLK)
  if     (UPDATE) 
    begin
    sreg <= DATA;
    cnt  <= (D-1);
    end
  else if(SHIFT)
    begin
    sreg <= {sreg[D-2:0], 1'b0};
    cnt <= cnt - 1'b1;
    end

assign OUT   = sreg[D-1];
assign EMPTY = (cnt == '0); //'

endmodule