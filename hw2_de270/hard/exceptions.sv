module exceptions (  input          CLK,
                     input          RESET,
                     if_except.excp EXC,     //exceptions interface
                     if_debug.excp  DEBUG ); //debug interface


logic  [31:0] epc, ejump_vector;
logic   [7:0] e_vec;
logic   [4:0] cause;
logic         e_enter;

assign e_enter = RESET            | 
                 EXC.SYSCALL      |
                 EXC.BREAK        |
                 EXC.RI           |     
                 EXC.CpU          |
                 EXC.OV           |   
                 EXC.IBE          |
                 EXC.DBE          |
                 EXC.INT_COUNTER ;    


//Exceptions are in the order of significance
assign e_vec = {EXC.IBE, EXC.RI, EXC.CpU, EXC.BREAK, EXC.SYSCALL, 
                EXC.OV, EXC.DBE, EXC.INT_COUNTER};

always_comb
  casex(e_vec)
  8'b1XXXXXXX: cause = 5'd06; //IBE
  8'b01XXXXXX: cause = 5'd10; //RI
  8'b001XXXXX: cause = 5'd11; //CpU
  8'b0001XXXX: cause = 5'd09; //BREAK
  8'b00001XXX: cause = 5'd08; //SYSCALL
  8'b000001XX: cause = 5'd12; //Overflow
  8'b0000001X: cause = 5'd07; //DBE
  8'b00000001: cause = 5'd00; //Counter interrupt
  default:     cause = 5'd31; //default
  endcase

//delay slot compensation
mux2 #(32) epc_sel( EXC.DELAY_SLOT,  EXC.PC_WB, (EXC.PC_WB - 3'd4), epc );

//Exception address vector select
mux2 #(32) vec_sel( RESET | DEBUG.INST_SUBST, 32'h00000100, 32'h00000000, ejump_vector);

assign EXC.RESET     = e_enter | EXC.ERET;
assign EXC.E_ENTER   = e_enter;
assign EXC.E_USE_VEC = e_enter | EXC.ERET | DEBUG.INST_SUBST;

assign EXC.VECTOR    = EXC.ERET ? EXC.EPC_Q : ejump_vector;

assign EXC.CAUSE   = cause;
assign EXC.EPC     = epc;

endmodule
