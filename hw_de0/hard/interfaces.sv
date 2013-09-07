//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_except;

  logic        ERET;
  logic        SYSCALL;  
  logic        BREAK;    
  logic        RI;       
  logic        CpU;
  logic        OV;  
  logic        IBE;
  logic        DBE;    
  logic        INTERRUPT;

  logic [31:0] PC_WB;
  logic        DELAY_SLOT;

  logic        RESET;

  logic        E_ENTER;
  logic        E_USE_VEC;
  logic  [4:0] CAUSE;
  logic [31:0] EPC, EPC_Q;
  logic [31:0] BAD_VA;
  logic [31:0] VECTOR;

modport dpath ( input  E_USE_VEC, RESET, VECTOR,
                output ERET, SYSCALL, BREAK, RI, CpU, OV,
                       IBE, DBE, BAD_VA, PC_WB, DELAY_SLOT );

modport cp0   ( input  E_ENTER, DELAY_SLOT, CAUSE, EPC, BAD_VA, ERET,
                output INTERRUPT, EPC_Q );

modport excp  ( input  ERET, EPC_Q,
                       INTERRUPT, SYSCALL, BREAK, RI,
                       CpU, OV, IBE, DBE, PC_WB, DELAY_SLOT,
                output E_ENTER, E_USE_VEC, RESET, VECTOR, EPC,  CAUSE );


endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_hazard;

  logic [4:0] RS_E;
  logic [4:0] RT_E;

  logic [4:0] REGDST_M;
  logic [1:0] MFCOP_SEL_M;
  logic       ALUORMEM_M;
  logic       WRITEREG_M;
  logic       MDIV_BUSY_M;

  logic [4:0] REGDST_W;
  logic       WRITEREG_W; 

  logic       STALL_FDE, STALL_M;
  logic       RESET_M, RESET_W;
  logic [1:0] ALU_FWD_A;
  logic [1:0] ALU_FWD_B;


modport dpath ( input  STALL_FDE, STALL_M, RESET_M, RESET_W, ALU_FWD_A, ALU_FWD_B,
               output  RS_E, RT_E, 
                       REGDST_M, MFCOP_SEL_M, ALUORMEM_M, WRITEREG_M, MDIV_BUSY_M,
                       REGDST_W, WRITEREG_W );


modport hzrd ( output  STALL_FDE, STALL_M, RESET_M, RESET_W, ALU_FWD_A, ALU_FWD_B,
                input  RS_E, RT_E, 
                       REGDST_M, MFCOP_SEL_M, ALUORMEM_M, WRITEREG_M, MDIV_BUSY_M,
                       REGDST_W, WRITEREG_W );

endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_memory;

  logic [29:0] iADDR;
  logic [31:0] iDATA; 
  logic        IBE;

  logic [29:0] dADDR;
  logic [31:0] dDATA;
  logic [31:0] WD;
  logic        RE, WE;
  logic [ 3:0] BE;
  logic        DBE, DBEa;
  logic        INHIBIT;

modport  mem (  input  iADDR, dADDR, RE, WE, BE, WD, INHIBIT,
                output iDATA, dDATA, IBE, DBE, DBEa );

modport dpath ( output iADDR, dADDR, RE, WE, BE, WD, INHIBIT,
                input  iDATA, dDATA, IBE, DBE, DBEa );

endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_cp0;

  logic         IEN_WB; //Valid/architectural instruction @WB
  logic         WE;
  logic  [4:0]  IDX;
  logic  [31:0] WD, RD; 
  logic         KERNEL_MODE;

modport dpath ( input  KERNEL_MODE, RD,
                output IEN_WB, WE, IDX, WD );

modport cp0   ( output KERNEL_MODE, RD,
                input  IEN_WB, WE, IDX, WD );

endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_debug;

logic [31:0] STATUS_DATA, iDATA;  
logic        INST_SUBST, RUN;

modport jtag  ( input  STATUS_DATA,
                output INST_SUBST, RUN, iDATA );

modport  cp0  (  output STATUS_DATA );

modport dpath ( input  INST_SUBST, RUN, iDATA );

modport excp  ( input  INST_SUBST );

endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_mmu;

  logic [31:0] INST_VA;
  logic [31:0] DATA_VA;
  logic        DATA_RD; // was DATA_EN; 
  logic        DATA_WR; // was WRITE_REQ;

  logic [31:0] INST_PA;
  logic [31:0] DATA_PA;
  logic        iTLBL;   // no translation for ifetch
  logic        iADEL;   // out-of-userspace/unaligned for ifetch
  logic        dTLBMOD; // write to clean page
  logic        dTLBL;   // no translation for data load
  logic        dTLBS;   // no translation for data store
  logic        dADEL;   // out-of-userspace/unaligned for data load
  logic        dADES;   // out-of-userspace/unaligned for data store

  logic  [7:0] ASID;
  logic  [3:0] INDEX;
  logic        KERNEL_MODE;
  logic        TLB_WE; //TLB Write strobe

  logic [54:0] TLB_ENTRY, CP0_ENTRY;

modport mmu   ( input  INST_VA, DATA_VA, DATA_RD, DATA_WR,
                       CP0_ENTRY, ASID, INDEX, KERNEL_MODE, TLB_WE,
                output INST_PA, DATA_PA, iTLBL, iADEL, TLB_ENTRY,
                       dTLBMOD, dTLBL, dTLBS, dADEL, dADES );

modport dpath ( input  INST_PA, DATA_PA, iTLBL, iADEL,
                       dTLBMOD, dTLBL, dTLBS, dADEL, dADES,
                output INST_VA, DATA_VA, DATA_RD, DATA_WR, TLB_WE );

modport cp0   ( input  TLB_ENTRY,
                output CP0_ENTRY, ASID, INDEX, KERNEL_MODE );

endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//
interface if_io;

logic [31:0] LEDS_WD;
logic [31:0] LEDS_RD;
logic  [3:0] LEDS_A;
logic        LEDS_WE;
logic        INT_BTN;

logic [31:0] UART_WD, UART_RD;
logic  [1:0] UART_A; 
logic        UART_WE, UART_RE;

logic  [3:0] I2C_A;
logic [31:0] I2C_RD;

logic [31:0] QCON_WD, QCON_RD;
logic  [3:0] QCON_A;
logic        QCON_WE;

logic [31:0] HP_WD, HP_RD;
logic  [3:0] HP_A;
logic        HP_WE;

modport io    (output LEDS_WE, LEDS_WD, LEDS_A, I2C_A,
                      UART_WE, UART_WD, UART_RE, UART_A,
                      QCON_WE, QCON_WD, QCON_A,
                      HP_WE,   HP_WD,   HP_A,
               input  LEDS_RD, UART_RD, I2C_RD, QCON_RD, HP_RD); 

modport cp0   (input  INT_BTN);

modport leds  (input  LEDS_WE, LEDS_WD, LEDS_A,
               output LEDS_RD, INT_BTN );

modport uart  (input  UART_WE, UART_WD, UART_RE, UART_A,
               output UART_RD );

modport i2c   (input  I2C_A,
               output I2C_RD );

modport qcon  (input  QCON_WE, QCON_WD, QCON_A,
               output QCON_RD );

modport hp    (input  HP_WE, HP_WD, HP_A,
               output HP_RD );
endinterface
//===========================================================================//
//                                                                           //
//===========================================================================//