module datapath ( input              CLK,

                 //Controller iface
                  output def::c_inst INST_O,
                  input  def::ctrl   CI, //control input

                 //Hazard unit iface
                  if_hazard.dpath    HZRD,

                 //Coprocessor 0 interface
                  if_cp0.dpath       CP0,

                 //Exception unit interface
                  if_except.dpath    EXC, 

                 //External inst and data memory iface
                  if_memory.dpath    MEM,

                 //Debug interface
                  if_debug.dpath     DEBUG  );


//------------------------WIRE DEFINITIONS-----------------------------------//
//FETCH:
logic [31:0] next_pc, pc_f, pc_plus_4_f, inst_f, inst_subs_f, inst_stll_f;
logic  [4:0] rs_f, rt_f;
logic        ien_f, exc_f, enable_inst_f;


//DECODE:
logic [31:0] inst_d, pc_plus_4_d, pc_d, regfile_wdata_w, immed_extend_d, rd1_d, rd2_d, branch_extend_d;
logic        write_cp0_d, ien_d, RI, CP_UNUSBL, e_IBE_d;

//EXECUTE:
logic [31:0] branch_target_e, jump_target_e, jb_target_e, br_target_e, return_target_e, pc_plus_4_e,   
             src_a_fwd_e, src_b_fwd_e, immed_extend_e, branch_extend_e, aluout_e, pc_e, src_a_e, src_b_e,
             rd1_e, rd2_e, dmem_wd_e;

logic [25:0] inst_e;
logic  [4:0] reg_dst_addr_e, rs_e, rt_e, rd_e, shamt_e, alu_op_e;
logic  [3:0] dmem_be_e;
logic  [2:0] br_type_e;
logic  [1:0] reg_dst_e, mfcop_sel_e, mem_optype_e;
logic        write_reg_e, write_mem_e, aluormem_e, multiply_e, 
             link_e, mem_partial_e, alu_a_sel_e, alu_b_sel_e,
             write_cp0_e, ien_e, jump_e, br_inst_e, br_take_e, jump_r_e;

logic        e_OV_e, e_SYSCALL_e, e_BREAK_e, e_RI_e, e_CpU_e, e_IBE_e, eret_e;


//MEMORY: 
logic [31:0] mem_reordered_m, aluout_m, pc_m, src_b_m, BAD_VA_m, hi_m, lo_m, aluout_mux_m;
logic  [4:0] reg_dst_addr_m, rd_m;
logic  [1:0] mem_optype_m, mfcop_sel_m;
logic        br_inst_m, write_reg_m, write_mem_m, aluormem_m, mem_partial_m,
             ien_m, multiply_m, madd_m, signed_op_m, write_cp0_m;
logic        e_OV_m, e_SYSCALL_m, e_BREAK_m, e_RI_m, e_CpU_m, e_IBE_m, 
             eret_m, mem_inhibit_m;

//WRITEBACK:
logic [31:0] aluout_w, dmem_data_w, mem_reordered_w, pc_w, BAD_VA_w;
logic  [4:0] reg_dst_addr_w;
logic  [1:0] mem_optype_w;
logic        mem_partial_w, br_inst_w, write_reg_w, aluormem_w, delay_slot_w, eret_w, ien_w;

logic        e_OV_w, e_SYSCALL_w, e_BREAK_w, e_RI_w, e_CpU_w, e_IBE_w, e_DBE_w;

//------------------------FETCH STAGE----------------------------------------//
assign pc_plus_4_f = pc_f + 32'd4;

wire [1:0] next_pc_select =  HZRD.STALL    ? 2'b11 :
                             EXC.E_USE_VEC ? 2'b10 : 
                             br_take_e     ? 2'b01 :
                                             2'b00 ;

mux4  pc_src_mux( next_pc_select,
                  pc_plus_4_f,     // 00: pc = pc + 4
                  branch_target_e, // 01: conditional branch
                  EXC.VECTOR,      // 10: Exception unit addr: eret, deret, enter, reset
                  pc_f,            // 11: previous pc for stalls
                  next_pc );

ffd #(32) pc_reg(CLK, 1'b0, 1'b1, next_pc, pc_f );


assign MEM.iADDR = next_pc[31:2];
//     MEM.iDATA --> pipe_reg_D & regfile
//------------------------------//

assign ien_f = ~br_take_e;

mux2 stll_mux(HZRD.STALL, MEM.iDATA, inst_d, inst_stll_f);
mux2 subs_mux(DEBUG.INST_SUBST, inst_stll_f, DEBUG.iDATA, inst_subs_f);
mux2 null_mux(enable_inst_f, 32'h00000000, inst_subs_f, inst_f );

assign enable_inst_f = DEBUG.INST_SUBST ? DEBUG.RUN : (ien_f & ~MEM.IBE);

assign rs_f = inst_f[25:21];
assign rt_f = inst_f[20:16];

ffd #(66) pipe_reg_D(CLK, EXC.RESET, ~HZRD.STALL, 
                              { ien_f,        // 1/
                                inst_f,       //32/
                                MEM.IBE,      // 1/
                                pc_f  },      //32/ 
                              { ien_d,        // 1/
                                inst_d,       //32/
                                e_IBE_d,      // 1/
                                pc_d });      //32/
//---------------------------------------------------------------------------//


//------------------------DECODE STAGE---------------------------------------//
//-----------IO BLOCK-----------//
assign INST_O.OPCODE = inst_d[31:26];  
assign INST_O.FCODE  = inst_d[5:0];
assign INST_O.RS     = inst_d[25:21]; 
assign INST_O.RT     = inst_d[20:16];

assign HZRD.RS_D = inst_d[25:21]; //rs_d;
assign HZRD.RT_D = inst_d[20:16]; //rt_d;

assign RI = CI.NOT_IMPLTD;
assign CP_UNUSBL = (CI.PRIVILEGED & ~CP0.KERNEL_MODE);
//  <-- CI
//------------------------------//

regfile rf_unit(.CLK        (CLK              ),
                .WE         (write_reg_w      ), 
                .RD_ADDR_1  (rs_f             ),  //in_rd_addr
                .RD_ADDR_2  (rt_f             ),  //in_rd_addr
                .WR_ADDR_3  (reg_dst_addr_w   ),  //in_wr_addr
                .W_DATA     (regfile_wdata_w  ),  //in
                .R_DATA_1   (rd1_d            ),  //out
                .R_DATA_2   (rd2_d            )); //out

//------IMMEDIATE EXTENSION--------                
immed_extend   immed_ext_unit(CI.IMMED_EXT, inst_d[15:0], immed_extend_d);
branch_extend               branch_ext_unit(inst_d[15:0], branch_extend_d);

assign write_cp0_d = CI.WRITE_CP0 & ~CP_UNUSBL;

assign pc_plus_4_d = pc_d + 3'd4;


ffd #(248) pipe_reg_E(CLK, EXC.RESET | HZRD.STALL, 1'b1,
                  {  ien_d,             // 1/ instruction enable
                     write_cp0_d,       // 1/ write coprocessor0
                     CI.WRITE_REG,      // 1/ write to register file
                     CI.WRITE_MEM,      // 1/ write data memory
                     CI.MEM_PARTIAL,    // 1/ memory byte- or halfword access
                     CI.MEM_OPTYPE,     // 2/ mem op: 00-ubyte, 01-uhalf, 10-sb, 11-sh
                     CI.ALUORMEM_WR,    // 1/ write regfile from alu or from memory
                     CI.MULTIPLY,       // 1/ do multiplication and write hi&lo
                     CI.BRANCH_TYPE,    // 3/ branch type
                     CI.JUMP_R,         // 1/ jr-type jump
                     CI.ALU_OP,         // 5/ ALU Operation select
                     CI.REG_DST,        // 2/ write destination in regfile (0 - rt, 1 - rd)
                     CI.MFCOP_SEL,      // 2/ mfrom coprocessor selector
                     CI.ALU_SRC_A,      // 1/ alu src a
                     CI.ALU_SRC_B,      // 1/ alu src b
                     rd1_d,             //32/ regfile operand A
                     rd2_d,             //32/ regfile operand B
                     inst_d[25:0],      //26/ RS, RT, RD, SHAMT / Jump addr
                     immed_extend_d,    //32/ extended immediate
                     branch_extend_d,   //32/ brach immediate extension
                     pc_plus_4_d,       //32/ pc plus 4
                     CI.JUMP_ERET,      // 1/ eret instruction
                     e_IBE_d,           // 1/ exception bit
                     CI.SYSCALL,        // 1/ exception bit
                     CI.BREAK,          // 1/ exception bit
                     RI,                // 1/ exception bit
                     CP_UNUSBL,         // 1/ exception bit
                     pc_d  },           //32/ pc 

                  {  ien_e,             // 1/ instruction enable
                     write_cp0_e,       // 1/ write coprocessor0
                     write_reg_e,       // 1/ write to register file
                     write_mem_e,       // 1/ write data memory
                     mem_partial_e,     // 1/ memory byte- or halfword access
                     mem_optype_e,      // 2/ mem op: 00-ubyte, 01-uhalf, 10-sb, 11-sh
                     aluormem_e,        // 1/ write regfile from alu or from memory
                     multiply_e,        // 1/ do multiplication and write hi&lo
                     br_type_e,         // 3/ branch type
                     jump_r_e,          // 1/ jr-type jump
                     alu_op_e,          // 8/ ALU Operation select
                     reg_dst_e,         // 2/ write destination in regfile (0 - rt, 1 - rd)
                     mfcop_sel_e,       // 2/ mfrom coprocessor selector
                     alu_a_sel_e,       // 1/ alu src a 
                     alu_b_sel_e,       // 1/ alu src b 
                     rd1_e,             //32/ alu operand A
                     rd2_e,             //32/ alu operand B
                     inst_e,            //26/ rs,rt,rd, shamt, j target
                     immed_extend_e,    //32/ extended immediate
                     branch_extend_e,   //32/ brach immediate extension
                     pc_plus_4_e,       //32/ pc plus 4
                     eret_e,            // 1/ eret instruction
                     e_IBE_e,           // 1/ exception bit
                     e_SYSCALL_e,       // 1/ exception bit
                     e_BREAK_e,         // 1/ exception bit
                     e_RI_e,            // 1/ exception bit
                     e_CpU_e,           // 1/ exception bit
                     pc_e  });          //32/ pc  
                
//---------------------------------------------------------------------------//

//------------------------EXECUTE STAGE--------------------------------------//
//-----------IO BLOCK-----------//
assign HZRD.RS_E = rs_e;
assign HZRD.RT_E = rt_e;
assign HZRD.REGDST_E = reg_dst_addr_e;
assign HZRD.WRITEREG_E = write_reg_e;
assign HZRD.ALUORMEM_E = aluormem_e;

assign MEM.WE    = write_mem_e;
assign MEM.RE    = aluormem_e;
assign MEM.dADDR = aluout_e[31:2];
assign MEM.BE    = dmem_be_e;
assign MEM.WD    = dmem_wd_e;
//------------------------------//

assign rs_e    = inst_e[25:21];
assign rt_e    = inst_e[20:16];
assign rd_e    = inst_e[15:11];
assign shamt_e = inst_e[10:06];

mux4 #(5) regfile_wr_addr_mux( reg_dst_e, 
                               rt_e, 
                               rd_e,
                               5'd31, //ret_address
                               5'd31, //ret_address
                               reg_dst_addr_e);

mux4 fwd_src_a(HZRD.ALU_FWD_A, rd1_e,           //00 -- no forwarding
                               aluout_m,        //01 -- forward from MEM
                               regfile_wdata_w, //10 -- forward from WB
                               32'hXXXXXXXX,    //11 -- not used
                               src_a_fwd_e );

mux4 fwd_src_b(HZRD.ALU_FWD_B, rd2_e,           //00 -- no forwarding
                               aluout_m,        //01 -- forward from MEM
                               regfile_wdata_w, //10 -- forward from WB
                               32'hXXXXXXXX,    //11 -- not used
                               src_b_fwd_e );

mux2 alu_src_a_mux( alu_a_sel_e,
                    src_a_fwd_e,    //0: register file
                    pc_plus_4_e,    //1: pc+4 for return addr calculation
                    src_a_e );

mux2 alu_src_b_mux( alu_b_sel_e, 
                    src_b_fwd_e,    //0: register file 
                    immed_extend_e, //1: immediate
                    src_b_e );

//-----------Branch logic-------------------//
assign br_inst_e = br_type_e[2] | br_type_e[1] | br_type_e[0]; // br_type != 0
assign jump_e = (br_type_e == 3'd1); 

assign jump_target_e   = {pc_plus_4_e[31:28], inst_e, 2'b00}; // target for unconditional jumps
assign br_target_e     = branch_extend_e + pc_plus_4_e;       // target for simple branches

mux2 branch_target_jb_mux(jump_e, br_target_e, jump_target_e, jb_target_e);

mux2 branch_target_jr_mux(jump_r_e, jb_target_e, src_a_fwd_e, branch_target_e);

wire regs_equal = (src_a_fwd_e == src_b_fwd_e);
wire reg_zero   = (src_a_fwd_e == 32'd0);
wire reg_neg    = src_a_fwd_e[31];

mux8 #(1) br_mux( br_type_e,
                  1'b0,                   //3/ 0 -- NORM 
                  1'b1,                   //   1 -- JR   
                  ( regs_equal),          //   2 -- BEQ  
                  (~regs_equal),          //   3 -- BNE  
                  ( reg_neg |  reg_zero), //   4 -- BLEZ 
                  ( reg_neg ),            //   5 -- BLTZ 
                  (~reg_neg ),            //   6 -- BGEZ
                  (~reg_neg & ~reg_zero), //   7 -- BGTZ
                  br_take_e );


alu alu(alu_op_e, src_a_e, src_b_e, shamt_e, e_OV_e, aluout_e);

////mux2 ret_target_mux (br_inst_e, aluout_e, return_target_e, aluout_final_e);

store_reorder st_reorder_unit( .LO_ADDR ( aluout_e[1:0] ),
                               .DATA_IN ( src_b_fwd_e   ),
                               .PARTIAL ( mem_partial_e ),
                               .OP_TYPE ( mem_optype_e  ),
                               .BYTE_EN ( dmem_be_e     ),
                               .DATA_OUT( dmem_wd_e     ));

ffd #(127) pipe_reg_M ( CLK, EXC.RESET, 1'b1,
                  {  ien_e,             // 1/ instruction enable
                     br_inst_e,         // 1/ branch instruction
                     write_reg_e,       // 1/ write to register file
                     write_mem_e,       // 1/ write data memory
                     write_cp0_e,       // 1/ write coprocessor0
                     multiply_e,        // 1/ multiplication request
                     1'b0,              // 1/ multiply-add request
                     aluormem_e,        // 1/ write regfile from alu or from memory
                     mem_optype_e,      // 2/ mem op: 00-ubyte, 01-uhalf, 10-sb, 11-sh
                     mem_partial_e,     // 1/ memory byte- or halfword access
                     mfcop_sel_e,       // 2/ coprocessor/mulduv/alu selector
                     rd_e,              // 5/ used as cp0 index 
                     aluout_e,          //32/ ALU result
                     src_b_fwd_e,       //32/ regfile data B
                     reg_dst_addr_e,    // 5/ destination reg addr
                     alu_op_e[4],       // 1/ signed operation
                     eret_e,            // 1/ eret instruction
                     e_OV_e,            // 1/ exception bits
                     e_IBE_e,           // 1/ exception bits
                     e_SYSCALL_e,       // 1/ exception bits
                     e_BREAK_e,         // 1/ exception bits 
                     e_RI_e,            // 1/ exception bits
                     e_CpU_e,           // 1/ exception bits
                     pc_e },            //32/ pc

               
                  {  ien_m,
                     br_inst_m,
                     write_reg_m,
                     write_mem_m,
                     write_cp0_m,       // 1/ write coprocessor0
                     multiply_m,
                     madd_m,
                     aluormem_m,
                     mem_optype_m,      // 2/ mem op: 00-ubyte, 01-uhalf, 10-sb, 11-sh
                     mem_partial_m,     // 1/ memory byte- or halfword access
                     mfcop_sel_m,       // 2/ coprocessor/mulduv/alu selector
                     rd_m,              // 5/ used as cp0 index 
                     aluout_m,
                     src_b_m,
                     reg_dst_addr_m,
                     signed_op_m,
                     eret_m,
                     e_OV_m,
                     e_IBE_m,
                     e_SYSCALL_m,
                     e_BREAK_m,  
                     e_RI_m, 
                     e_CpU_m,    
                     pc_m });
//---------------------------------------------------------------------------//

//------------------------MEMORY STAGE---------------------------------------//
//-----------IO BLOCK-----------//
assign HZRD.REGDST_M   = reg_dst_addr_m;
assign HZRD.ALUORMEM_M = aluormem_m;
assign HZRD.WRITEREG_M = write_reg_m;

assign CP0.IDX     = rd_m;
assign CP0.WD      = src_b_m;
assign CP0.WE      = write_cp0_m;

assign MEM.INHIBIT = mem_inhibit_m;
//------------------------------//

assign BAD_VA_m = pc_m; ///dtlb_exception ? aluout_m1 : pc_m1;

// this trigger inhibit memory writes (state changes!) between
// the exceptional event and its handling. During this period,
// instructions could write to memory, which is not desired.
rsd mem_wr_inhibit_fd(CLK, { eret_m | e_OV_m | e_IBE_m | e_SYSCALL_m |
                             e_BREAK_m | e_RI_m | e_CpU_m | MEM.DBEa }, 
                           EXC.RESET, mem_inhibit_m );

load_reorder ld_reorder_unit( .LO_ADDR ( aluout_m[1:0]   ),
                              .DATA_IN ( MEM.dDATA       ),
                              .PARTIAL ( mem_partial_m   ),
                              .OP_TYPE ( mem_optype_m    ),
                              .DATA_OUT( mem_reordered_m )); 

muldiv  muldiv_unit ( .CLK  ( CLK         ),
                      .MUL  ( multiply_m  ),
                      .MAD  ( madd_m      ),
                      .SIGN ( signed_op_m ),
                      .A    ( aluout_m    ),
                      .B    ( src_b_m     ),
                      .HI   ( hi_m        ),
                      .LO   ( lo_m        ));

mux4 aluout_mux(  mfcop_sel_m,
                  aluout_m,
                  hi_m,           //MFHI
                  lo_m,           //MFLO
                  CP0.RD,         //MFC0
                  aluout_mux_m ); 

ffd #(145) pipe_reg_W(CLK, EXC.RESET, 1'b1,
                  {  ien_m,
                     write_reg_m,        // 1/ write to register file
                     aluormem_m,         // 1/ write regfile from alu or from memory
                     aluout_mux_m,       //32/ alu result
                     mem_reordered_m,    //32/ memory data
                     reg_dst_addr_m,     // 5/ destination register
                     br_inst_m,          // 1/ branch instruction
                     eret_m,             // 1/ EXC: eret instruction
                     e_OV_m,             // 1/ Exception bit (Overflow)
                     e_IBE_m,            // 1/ Exception bit (Instr. bus error)
                     MEM.DBE,             // 1/ Exception bit (Data bus error)
                     e_SYSCALL_m,        // 1/ Exception bit (Syscall)
                     e_BREAK_m,          // 1/ Exception bit (Break)
                     e_RI_m,             // 1/ Exception bit (Reserved Instruction)
                     e_CpU_m,            // 1/ Exception bit (COP Unusable)
                     BAD_VA_m,           //32/ Bad virtual address
                     pc_m },             //32/ instruction address
                     
                  {  ien_w,
                     write_reg_w,         // 1/ write to register file
                     aluormem_w,          // 1/ write regfile from alu or from memory
                     aluout_w,            //32/ alu result
                     mem_reordered_w,     //32/ memory data
                     reg_dst_addr_w,      // 5/ destination register
                     br_inst_w,           // 1/
                     eret_w,              // 1/ EXC: eret instruction
                     e_OV_w,              // 1/ Exception bit (Overflow)
                     e_IBE_w,             // 1/ Exception bit (Instr. bus error)
                     e_DBE_w,             // 1/
                     e_SYSCALL_w,         // 1/ Exception bit (Syscall)
                     e_BREAK_w,           // 1/ Exception bit (Break)
                     e_RI_w,              // 1/ Exception bit (Reserved Instruction)
                     e_CpU_w,             // 1/ Exception bit (COP Unusable)
                     BAD_VA_w,            //32/ Bad virtual address
                     pc_w });             //32/ instruction address
                     
//---------------------------------------------------------------------------//

//-----------------------WRITEBACK STAGE-------------------------------------//
//-----------IO BLOCK-----------//
assign HZRD.REGDST_W = reg_dst_addr_w;
assign HZRD.WRITEREG_W = write_reg_w;

assign EXC.ERET    = eret_w;
assign EXC.SYSCALL = e_SYSCALL_w;
assign EXC.BREAK   = e_BREAK_w;  
assign EXC.RI      = e_RI_w;     
assign EXC.CpU     = e_CpU_w;
assign EXC.OV      = e_OV_w;   
assign EXC.IBE     = e_IBE_w;
assign EXC.DBE     = e_DBE_w;
assign EXC.BAD_VA  = e_DBE_w ? aluout_w : BAD_VA_w;
assign EXC.PC_WB    = pc_w;
assign EXC.DELAY_SLOT = delay_slot_w;

assign CP0.IEN_WB = ien_w;
//------------------------------//

//------------------------------//

mux2 regfile_wr_data_mux( aluormem_w, 
                          aluout_w,        //0: ALU out
                          mem_reordered_w, //1: MEM out
                          regfile_wdata_w);

ffd #(1) delay_slot_fd(CLK, EXC.RESET, 1'b1, br_inst_w, delay_slot_w);
//---------------------------------------------------------------------------//
                
endmodule

