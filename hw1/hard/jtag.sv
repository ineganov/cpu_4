// Virtual JTAG module
// 
// The module consists of 3 register chains + bypass (ergo 2 bit jtag instructions)

// chain 1: control, L=2bit 
// Used to setup debug facilities, such as reset, run/stop and instruction source
// {DEBUG_MODE, RESET}
// RESET is active-1. Set DEBUG_MODE to 0 to use mem instructions(normal mode), 
// or 1 to use JTAG instructions (debug mode). Program counter is set to zero in
// debug mode, so jumps and branches are futile.

// chain 2: JTAG DEBUG, L=32bit
// Used to feed CPU with instructions from JTAG port 
// Receives instruction as input and runs it through the pipeline.
// Program counter is not affected, but regfile and memory are.

// chain 3: DATA READ, L=32bit
// Used to asynchronously read coprocessor0 register 23.
// Read-only, 32-bit chain.


module jtag    (  input         CPU_CLK,
                  input         EXT_RESET,
                  output        RESET,  

                  if_debug.jtag DEBUG );



logic [1:0] INST, inst_q;

// This data is read during scan chain select.
// If you don't see value '1', something is
// seriously wrong with JTAG setup.
wire  [1:0] INST_READOUT = 2'b01;

logic TCK, TDI, TDO;
logic TDO_ctrl, TDO_inst, TDO_stat, TDO_bypass; 
logic EN_ctrl, EN_inst, EN_stat;
logic ST_CAPTURE_DATA, ST_SHIFT_DATA, ST_UPDATE_DATA, ST_UPDATE_INST; 
logic sync_update;

logic [1:0] controls;

vji   virtual_jtag (  .tck    ( TCK                ),
                      .tdo    ( TDO                ),
                      .tdi    ( TDI                ),
                      .ir_out ( INST_READOUT       ),
                      .ir_in  ( INST               ),

                      .virtual_state_cdr  ( ST_CAPTURE_DATA  ),
                      .virtual_state_sdr  ( ST_SHIFT_DATA    ),
                      .virtual_state_udr  ( ST_UPDATE_DATA   ),
                      .virtual_state_uir  ( ST_UPDATE_INST   ));

ffd #(2) inst_reg(TCK, EXT_RESET, ST_UPDATE_INST, INST, inst_q);
assign EN_ctrl = (inst_q == 2'd1);
assign EN_inst = (inst_q == 2'd2);
assign EN_stat = (inst_q == 2'd3);

                  
bypass_chain bypass (TCK, TDI, TDO_bypass);

scan_chain #(2)  ctrl_chain(  .TCK     ( TCK                ),
                              .TDI     ( TDI                ),
                              .TDO     ( TDO_ctrl           ),
                              .EN      ( EN_ctrl            ),
                              .CAPTURE ( ST_CAPTURE_DATA    ),
                              .SHIFT   ( ST_SHIFT_DATA      ),
                              .UPDATE  ( ST_UPDATE_DATA     ),
                              .IN      ( controls           ), 
                              .OUT     ( controls           ));

scan_chain #(32) inst_chain(  .TCK     ( TCK                ),
                              .TDI     ( TDI                ),
                              .TDO     ( TDO_inst           ),
                              .EN      ( EN_inst            ),
                              .CAPTURE ( ST_CAPTURE_DATA    ),
                              .SHIFT   ( ST_SHIFT_DATA      ),
                              .UPDATE  ( ST_UPDATE_DATA     ),
                              .IN      ( DEBUG.iDATA        ), 
                              .OUT     ( DEBUG.iDATA        ));

read_chain #(32) stat_chain(  .TCK     ( TCK                ),
                              .TDI     ( TDI                ),
                              .TDO     ( TDO_stat           ),
                              .EN      ( EN_stat            ),
                              .CAPTURE ( ST_CAPTURE_DATA    ),
                              .SHIFT   ( ST_SHIFT_DATA      ),
                              .IN      ( DEBUG.STATUS_DATA  ));

sync  sync_resetm(CPU_CLK, controls[0], RESET ); 
sync  sync_instsm(CPU_CLK, controls[1], DEBUG.INST_SUBST );
sync sync_updatem(CPU_CLK, ST_UPDATE_DATA, sync_update ); 

edetect pulsem(CPU_CLK, sync_update, DEBUG.RUN );      // detect update posedge

mux4 #(1) tdo_mux(inst_q, TDO_bypass,
                          TDO_ctrl,
                          TDO_inst,
                          TDO_stat,
                          TDO );

endmodule

//=========================================================================//
module bypass_chain ( input      TCK,
                      input      TDI,
                      output reg TDO );

always_ff @(posedge TCK)
   TDO <= TDI;
endmodule
//=========================================================================//
module scan_chain #(parameter SIZE = 8) ( input TCK,
                                          input TDI,
                                          output TDO,
                           
                                          input EN,
                                          input CAPTURE,
                                          input SHIFT,
                                          input UPDATE,
                           
                                          input  [SIZE-1:0] IN,
                                          output [SIZE-1:0] OUT );

logic [SIZE-1:0] sreg, oreg;

always_ff @(posedge TCK)
   if(EN)
      begin
      if(CAPTURE)    sreg <= IN;
      else if(SHIFT) sreg <= { TDI, sreg[SIZE-1:1]};
      end

always_ff @(posedge UPDATE)
   if(EN) oreg <= sreg;

assign OUT = oreg;
assign TDO = sreg[0];

endmodule
//=========================================================================//
module read_chain #(parameter SIZE = 8) ( input            TCK,
                                          input            TDI,
                                          output           TDO,
                                       
                                          input            EN,
                                          input            CAPTURE,
                                          input            SHIFT,
                                       
                                          input [SIZE-1:0] IN );

logic [SIZE-1:0] sreg;

always_ff @(posedge TCK)
   if(EN)
      begin
      if(CAPTURE)    sreg <= IN;
      else if(SHIFT) sreg <= {TDI, sreg[SIZE-1:1]};
      end

assign TDO = sreg[0];

endmodule
//=========================================================================//
module jtag_stub (  input         CPU_CLK,
                    input         EXT_RESET,
                    //primary CPU CONTROLS
                    output        RESET,  


                    if_debug.jtag DEBUG );

assign RESET = 1'b0;
assign DEBUG.INST_SUBST = 1'b0;
assign DEBUG.iDATA = 32'h34048001;


logic [4:0] clk_cnt;
logic       clk_done;

counter #(5) cnt(CPU_CLK, EXT_RESET, 1'b1, clk_cnt );
assign DEBUG.RUN = (clk_cnt == '0); //'

logic [31:0] status_register;

assign status_register = DEBUG.STATUS_DATA;

endmodule
//=========================================================================//