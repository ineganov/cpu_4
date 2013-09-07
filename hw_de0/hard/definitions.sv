package def;

typedef struct packed {
  logic   [5:0] OPCODE;        //6/ instruction opcode
  logic   [5:0] FCODE;         //6/ instruction fcode
  logic   [4:0] RS;            //5/ instruction RS field
  logic   [4:0] RT; } c_inst;  //5/ instruction RT field --> 22

typedef struct packed {
  logic        WRITE_CP0;       //1/ write to coprocessor0
  logic        WRITE_REG;       //1/ write to register file

  logic        WRITE_MEM;       //1/ write data memory
  logic        MEM_PARTIAL;     //1/ memory byte- or halfword access
  logic  [1:0] MEM_OPTYPE;      //2/ mem op: 00-ubyte, 01-uhalf, 10-sb, 11-sh

  logic        ALUORMEM_WR;     //1/ write regfile from alu(0) or from memory(1)
  
  logic        WRITE_HILO;      //1/ write hi&lo
  logic  [2:0] HILO_OP;         //3/ hi&lo op: op[2]=sel mthi/lo; op[1:0]: 0=mul, 1=mad, 2=mt, 3=div

  logic  [1:0] REG_DST;         //2/ write destination in regfile (0 - rt, 1 - rd, 1X - 31)

  logic  [1:0] MFCOP_SEL;       //2/ move from coprocessor sel

  logic  [2:0] BRANCH_TYPE;     //3/ 0 -- NORM -- do not branch
                                //   1 -- JUMP -- br unconditionally (j-type jumps)
                                //   2 -- BEQ  -- br equal
                                //   3 -- BNE  -- br not equal
                                //   4 -- BLEZ -- br less or equal zero
                                //   5 -- BLTZ -- br less than zero
                                //   6 -- BGEZ -- br greater or equal zero
                                //   7 -- BGTZ -- br greater than zero

  logic        JUMP_R;          //1/ jr jump
  logic        JUMP_ERET;       //1/ eret jump

  logic        PRIVILEGED;      //1/ privileged instruction
  logic        NOT_IMPLTD;      //1/ unimplemented instruction 
  logic        SYSCALL;         //1/ syscall instruction
  logic        BREAK;           //1/ break instruction
  
  logic        ALU_SRC_A;       //1/ ALU Operand A 0 - reg_1, 1 - pc+4
  logic        ALU_SRC_B;       //1/ ALU Operand B 0 - reg_2, 1 - immediate    
  
  logic  [2:0] IMMED_EXT;       //2/ Immed-extension type: 000-sign-extension
                                //                         001-zero-extension
                                //                         010-swap for lui
                                //                         011-literal '4' 
                                //                         100-literal '0'
  
  logic  [4:0] ALU_OP;  } ctrl; //5/ ALU Operation select

endpackage

