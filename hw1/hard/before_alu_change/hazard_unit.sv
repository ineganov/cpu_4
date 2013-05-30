module hazard_unit ( if_hazard.hzrd HZRD );

//  ALU Forwarding logic:
//  Replace ALU arg by the most recent write to reg file
//  I.e., if we have several instructions writing to regfile, 
//  use the closest one down the pipeline
//  Precedence: M1, M2, WB. 
//  + Don't forward if the argument is $zero since it _must_
//  work as /dev/null. Forwarding can break this logic!

//  + Keep in mind that forwarding works for arithmetic/logic
//  instructions mostly. Forwarding for loads is limited 
//  since the actual word appears in the processor at the 
//  end of M2 stage. Loaded data can be forwarded from WB only.

//  Then again, we need WB forwarding for ALU only, since it 
//  writes regfile at decode & branch state, and WB result is
//  accessible for branches directly from writeback


assign HZRD.ALU_FWD_A = 
   ((HZRD.RS_E != 0) && (HZRD.RS_E == HZRD.REGDST_M ) && HZRD.WRITEREG_M ) ? 2'b01 :
   ((HZRD.RS_E != 0) && (HZRD.RS_E == HZRD.REGDST_W ) && HZRD.WRITEREG_W ) ? 2'b10 :
                                                                             2'b00 ;

assign HZRD.ALU_FWD_B = 
   ((HZRD.RT_E != 0) && (HZRD.RT_E == HZRD.REGDST_M ) && HZRD.WRITEREG_M ) ? 2'b01 :
   ((HZRD.RT_E != 0) && (HZRD.RT_E == HZRD.REGDST_W ) && HZRD.WRITEREG_W ) ? 2'b10 :
                                                                             2'b00 ;



logic LW_STALL, LOAD_AT_E;

assign LOAD_AT_E  = HZRD.ALUORMEM_E  & (( HZRD.RS_D == HZRD.RT_E ) | 
                                        ( HZRD.RT_D == HZRD.RT_E ));

assign LW_STALL = LOAD_AT_E;

assign HZRD.STALL = LW_STALL;

endmodule
