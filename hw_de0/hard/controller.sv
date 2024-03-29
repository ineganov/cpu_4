module controller ( input  def::c_inst I,     //instruction word control fields
                    output def::ctrl   C );   //control outputs

parameter OP_RT    = 6'b000000; //regtype
parameter OP_SPCL  = 6'b011100; //special-2
parameter OP_COP0  = 6'b010000; //cop-0

parameter OP_LW    = 6'b100011;
parameter OP_LH    = 6'b100001;
parameter OP_LHU   = 6'b100101;
parameter OP_LB    = 6'b100000;
parameter OP_LBU   = 6'b100100;

parameter OP_SW    = 6'b101011;
parameter OP_SH    = 6'b101001;
parameter OP_SB    = 6'b101000;

parameter OP_ADDI  = 6'b001000;
parameter OP_ADDIU = 6'b001001;
parameter OP_ANDI  = 6'b001100;
parameter OP_ORI   = 6'b001101;
parameter OP_XORI  = 6'b001110;
parameter OP_LUI   = 6'b001111;

parameter OP_BRT   = 6'b000001; //1 branch-type
parameter OP_BEQ   = 6'b000100; //4
parameter OP_BNE   = 6'b000101; //5
parameter OP_BLEZ  = 6'b000110; //6
parameter OP_BGTZ  = 6'b000111; //7

parameter OP_J     = 6'b000010;
parameter OP_JAL   = 6'b000011;
parameter OP_SLTI  = 6'b001010;
parameter OP_SLTIU = 6'b001011;


always_comb
  case(I.OPCODE)              
    OP_RT:
      case(I.FCODE)    //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP 
      6'b100000: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_10000; // ADD
      6'b100001: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00000; // ADDU
      6'b100010: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_10001; // SUB
      6'b100011: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00001; // SUBU
            
      6'b101010: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_10011; // SLT
      6'b101011: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00011; // SLTU

      6'b100100: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00100; // AND
      6'b100101: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00101; // OR
      6'b100110: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00110; // XOR
      6'b100111: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_00111; // NOR
            
      6'b000000: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_01000; // SLL
      6'b000010: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_01001; // SRL
      6'b000011: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_01011; // SRA
      6'b000100: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_01100; // SLLV
      6'b000110: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_01101; // SRLV
      6'b000111: C = 34'b0_1_0XXX_0_0XXX_01_00_000_00_0000_00_XXX_01111; // SRAV
            
      6'b001000: C = 34'b0_0_0XXX_0_0XXX_01_00_001_10_0000_11_011_00000; // JR
      6'b001001: C = 34'b0_1_0XXX_0_0XXX_01_00_001_10_0000_11_011_00000; // JALR

      6'b010000: C = 34'b0_1_0XXX_0_0XXX_01_01_000_00_0000_0X_XXX_XXXXX; // MFHI
      6'b010010: C = 34'b0_1_0XXX_0_0XXX_01_10_000_00_0000_0X_XXX_XXXXX; // MFLO
      
      6'b011000: C = 34'b0_0_0XXX_0_1100_01_00_000_00_0000_01_100_00000; // MULT
      6'b011001: C = 34'b0_0_0XXX_0_1000_01_00_000_00_0000_01_100_00000; // MULTU
      6'b010001: C = 34'b0_0_0XXX_0_1110_01_00_000_00_0000_01_100_00000; // MTHI
      6'b010011: C = 34'b0_0_0XXX_0_1010_01_00_000_00_0000_01_100_00000; // MTLO
      6'b011010: C = 34'b0_0_0XXX_0_1111_01_00_000_00_0000_01_100_00000; // DIV
      6'b011011: C = 34'b0_0_0XXX_0_1011_01_00_000_00_0000_01_100_00000; // DIVU
      
      6'b001100: C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0010_XX_XXX_XXXXX; // SYSCALL
      6'b001101: C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0001_XX_XXX_XXXXX; // BREAK

      default:   C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0100_XX_XXX_XXXXX; // NOT IMPLEMENTED     
      endcase
                    //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP
    OP_LW:    C = 34'b0_1_00XX_1_0XXX_00_00_000_00_0000_01_000_00000;
    OP_LH:    C = 34'b0_1_0111_1_0XXX_00_00_000_00_0000_01_000_00000; 
    OP_LHU:   C = 34'b0_1_0101_1_0XXX_00_00_000_00_0000_01_000_00000; 
    OP_LB:    C = 34'b0_1_0110_1_0XXX_00_00_000_00_0000_01_000_00000; 
    OP_LBU:   C = 34'b0_1_0100_1_0XXX_00_00_000_00_0000_01_000_00000; 
    
    OP_SW:    C = 34'b0_0_10XX_0_0XXX_00_00_000_00_0000_01_000_00000;
    OP_SH:    C = 34'b0_0_11X1_0_0XXX_00_00_000_00_0000_01_000_00000;
    OP_SB:    C = 34'b0_0_11X0_0_0XXX_00_00_000_00_0000_01_000_00000;
 
    OP_ADDI:  C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_000_10000;
    OP_ADDIU: C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_000_00000;
    OP_ANDI:  C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_001_00100;
    OP_ORI:   C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_001_00101;
    OP_XORI:  C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_001_00110;
    
    OP_SLTI:  C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_000_10011;
    OP_SLTIU: C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_000_00011;

    OP_LUI:   C = 34'b0_1_0XXX_0_0XXX_00_00_000_00_0000_01_010_00000; 

    OP_BEQ:   C = 34'b0_0_0XXX_0_0XXX_00_00_010_00_0000_11_011_00000; 
    OP_BNE:   C = 34'b0_0_0XXX_0_0XXX_00_00_011_00_0000_11_011_00000;
    OP_BLEZ:  C = 34'b0_0_0XXX_0_0XXX_00_00_100_00_0000_11_011_00000;  
    OP_BGTZ:  C = 34'b0_0_0XXX_0_0XXX_00_00_111_00_0000_11_011_00000;
     
    OP_BRT:
      case(I.RT)      //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP
      5'b00000: C = 34'b0_0_0XXX_0_0XXX_11_00_101_00_0000_11_011_00000;// BLTZ
      5'b10000: C = 34'b0_1_0XXX_0_0XXX_11_00_101_00_0000_11_011_00000;// BLTZAL
      5'b00001: C = 34'b0_0_0XXX_0_0XXX_11_00_110_00_0000_11_011_00000;// BGEZ
      5'b10001: C = 34'b0_1_0XXX_0_0XXX_11_00_110_00_0000_11_011_00000;// BGEZAL
      default:  C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0100_XX_XXX_XXXXX;// NOT IMPLEMENTED
      endcase
    
    OP_SPCL:
      case(I.FCODE)   //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP
      5'b00000: C = 34'b0_0_0XXX_0_1101_01_00_000_00_0000_01_100_00000; // MADD
      5'b00001: C = 34'b0_0_0XXX_0_1001_01_00_000_00_0000_01_100_00000; // MADDU
      default:  C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0100_XX_XXX_XXXXX; // NOT IMPLEMENTED
      endcase

    OP_COP0:
      case(I.RS)      //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP
      5'b00000: C = 34'b0_1_0XXX_0_0XXX_00_11_000_00_0000_XX_XXX_XXXXX;// MOVE FROM
      5'b00100: C = 34'b1_0_0XXX_0_0XXX_00_00_000_00_0000_01_100_00000;// MOVE TO //should it be privileged?
      5'b10000:
        case(I.FCODE)    //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP
        6'b011000: C = 34'b0_0_0XXX_0_0XXX_XX_00_000_01_1000_XX_XXX_XXXXX; // ERET
        default:   C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0100_XX_XXX_XXXXX; // NOT IMPLEMENTED
        endcase
      default:  C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0100_XX_XXX_XXXXX;// NOT IMPLEMENTED
      endcase
                    //C_R_MPTT_A_HILO_RD_MC_BRT_JE_PISB_AB_IME_ALUOP
    OP_J:     C = 34'b0_0_0XXX_0_0XXX_11_00_001_00_0000_11_011_00000;
    OP_JAL:   C = 34'b0_1_0XXX_0_0XXX_11_00_001_00_0000_11_011_00000;
    
    default:  C = 34'b0_0_0XXX_0_0XXX_00_00_000_00_0100_XX_XXX_XXXXX; //NOT IMPLEMENTED
  endcase

endmodule
