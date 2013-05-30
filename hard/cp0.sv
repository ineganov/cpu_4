module coprocessor0 #( parameter     RAM_DEPTH = 14)
                     ( input         CLK,
                       input         RESET,
 
                       //cp0 <--> Datapath interface
                       if_cp0.cp0    CP0,
 
                       //cp0 <--> Exception unit interface
                       if_except.cp0 EXC,
 
                       //cp0  --> JTAG unit interface
                       if_debug.cp0  DEBUG );


logic [31:0] select, index_q, entry_lo1_q, context_q,
             badvaddr_q, entry_hi_q, epc_q,
             elo_wr, ehi_wr, count_q, compare_q, debug_q;
logic [7:0]  int_mask;
logic [4:0]  cause_q;
logic [3:0]  random_q, wired_q;
logic        exc_level, counter_int, int_enable, bd;

// Exception_Level register
   rsd exl_rsd( CLK, EXC.E_ENTER, EXC.ERET, exc_level );

// Counter interrupt register
// Set when count == compare, reset with a write to Compare
   rsd cnt_int( CLK, (count_q == compare_q), (CP0.WE & select[11]), counter_int);

// Counter interrupt
// Mind the last part: IEN_WB. It is needed to block interrupts at pipeline bubbles
   assign EXC.INT_COUNTER = counter_int & int_mask[7] & int_enable & ~exc_level & CP0.IEN_WB;

// Interrupt mask & master enable
   ffd #(9) imask(CLK, RESET, CP0.WE & select[12], {CP0.WD[15:8], CP0.WD[0]}, {int_mask, int_enable});


// register selector
   onehot #(5) regsel( CP0.IDX, select );

// Index into the TLB array
//   ffd #(32) r0_index     (CLK, RESET, CP0.WE & select[0], CP0.WD, index_q); 

// Randomly generated index into the TLB array
//   rand_cnt #(4) r1_random(CLK, RESET | (CP0.WE & select[1]), wired_q[3:0], random_q );

// Low-order portion of the TLB entry for even-numbered virtual pages
// {PFN[31:10], UNUSED[9:3], D[2], V[1], G[0]}
//   ffd #(32) r2_entry_lo1 (CLK, RESET, 
//                                CP0.TLB_RD | (CP0.WE & select[2]), 
//                                CP0.TLB_RD ? elo_wr : CP0.WD, 
//                                entry_lo1_q); 

// Low-order portion of the TLB entry for odd-numbered virtual pages
// ffd #(32) r3_entry_lo2 (CLK, RESET, <we>, CP0.WD, <out> ); 

// Pointer to page table entry in memory
//   ffd #(32) r4_context   (CLK, RESET, CP0.WE & select[4], CP0.WD, context_q); 

// Control for variable page size in TLB entries
// ffd #(32) r5_pagemask  (CLK, RESET, <we>, CP0.WD, <out> ); 

// Controls the number of fixed ("wired") TLB entries
//   ffd #(4) r6_wired     (CLK, RESET, CP0.WE & select[6], CP0.WD[3:0], wired_q ); 

// Enables access via the RDHWR instruction to selected hardware registers
// ffd #(32) r7_hwrena    (CLK, RESET, <we>, CP0.WD, <out> ); 

// Reports the address for the most recent address-related exception
   ffd #(32) r8_badvaddr  (CLK, RESET, EXC.E_ENTER, EXC.BAD_VA, badvaddr_q); 

// Processor cycle count
   counter #(32) r9_count (CLK, RESET | (CP0.WE & select[9]), 1'b1, count_q);


// High-order portion of the TLB entry
// {VPN[31:10], UNUSED[9:8], ASID[7:0]}
//   ffd #(32) r10_entry_hi (CLK, RESET, 
//                                CP0.TLB_RD | (CP0.WE & select[10]),
//                                CP0.TLB_RD ? ehi_wr : CP0.WD, 
//                                entry_hi_q); 

// Timer interrupt control
   ffd #(32) r11_compare  (CLK, RESET, CP0.WE & select[11], CP0.WD, compare_q); 

// Processor status and control
// ffd #(32) r12_status   (CLK, RESET, <we>, CP0.WD, <out>); 

// Cause of last general exception
   ffd  #(6) r13_cause    (CLK, RESET, EXC.E_ENTER, {EXC.DELAY_SLOT, EXC.CAUSE}, {bd, cause_q} ); 

// Program counter at last exception
   ffd #(32) r14_epc      (CLK, RESET, EXC.E_ENTER | (CP0.WE & select[14]),
                                       EXC.E_ENTER ? EXC.EPC : CP0.WD, epc_q ); 

// Processor identification and revision
// ffd #(32) r15_priid    (CLK, RESET, <we>, CP0.WD, <out>); 

// Configuration register
// ffd #(32) r16_config   (CLK, RESET, <we>, CP0.WD, <out>); 

// Load linked address
// ffd #(32) r17_lladdr   (CLK, RESET, <we>, CP0.WD, <out>); 

// Watchpoint address
// ffd #(32) r18_watch_lo (CLK, RESET, <we>, CP0.WD, <out>); 

// Watchpoint control
// ffd #(32) r19_watch_hi (CLK, RESET, <we>, CP0.WD, <out>); 

// XContext in 64-bit implementations
// ffd #(32) r20_xcontext (CLK, RESET, <we>, CP0.WD, <out>); 

// Reserved for future extensions
// ffd #(32) r21_reserved (CLK, RESET, <we>, CP0.WD, <out>); 

// Available for implementation dependent use
// ffd #(32) r22_impdep   (CLK, RESET, <we>, CP0.WD, <out>); 

// EJTAG Debug register
   ffd #(32) r23_debug    (CLK, RESET, CP0.WE & select[23], CP0.WD, debug_q ); 

// Program counter at last EJTAG debug exception
// ffd #(32) r24_depc     (CLK, RESET, <we>, CP0.WD, <out>); 

// Performance counter interface
// ffd #(32) r25_perf_cnt (CLK, RESET, <we>, CP0.WD, <out>); 

// Parity/ECC error control and status
// ffd #(32) r26_err_ctl  (CLK, RESET, <we>, CP0.WD, <out>); 

// Cache parity error control and status
// ffd #(32) r27_cache_err(CLK, RESET, <we>, CP0.WD, <out>); 

// Low-order portion of cache tag interface (taglo/datalo)
// ffd #(32) r28_tlo_dlo  (CLK, RESET, <we>, CP0.WD, <out>); 

// High-order portion of cache tag interface (taghi/datahi)
// ffd #(32) r29_thi_dhi  (CLK, RESET, <we>, CP0.WD, <out>); 

// Program counter at last error
// ffd #(32) r30_error_epc(CLK, RESET, <we>, CP0.WD, <out>); 

// EJTAG debug exception save register
// ffd #(32) r31_desave   (CLK, RESET, <we>, CP0.WD, <out>); 


mux32 #(32) omux (                  CP0.IDX,
                                    32'h00000000,   // r0_index      
                                    32'h00000000,   // r1_random     
                                    32'h00000000,   // r2_entry_lo1  
                                    32'h00000000,   // r3_entry_lo2  
                                    32'h00000000,   // r4_context    
                                    32'h00000000,   // r5_pagemask   
                                    32'h00000000,   // r6_wired      
                                    32'h00000000,   // r7_hwrena     
                                    badvaddr_q,     // r8_badvaddr   
                                    count_q,        // r9_count      
                                    32'h00000000,   // r10_entry_hi  
                                    32'h00000000,   // r11_compare   
    {16'b0, int_mask, 6'b0, exc_level, int_enable}, // r12_status    
     {bd, 15'd0, counter_int, 8'b0, cause_q, 2'b0}, // r13_cause     
                                    epc_q,          // r14_epc       
                                    32'hDEADBEEF,   // r15_priid     
                                2**(RAM_DEPTH+2),   // r16_config // memory size in bytes     
                                    32'h00000000,   // r17_lladdr    
                                    32'h00000000,   // r18_watch_lo  
                                    32'h00000000,   // r19_watch_hi  
                                    32'h00000000,   // r20_xcontext  
                                    32'h00000000,   // r21_reserved  
                                    32'h00000000,   // r22_impdep    
                                    debug_q,        // r23_debug     
                                    32'h00000000,   // r24_depc      
                                    32'h00000000,   // r25_perf_cnt  
                                    32'h00000000,   // r26_err_ctl   
                                    32'h00000000,   // r27_cache_err 
                                    32'h00000000,   // r28_tlo_dlo   
                                    32'h00000000,   // r29_thi_dhi   
                                    32'h00000000,   // r30_error_epc 
                                    32'h00000000,   // r31_desave    
                                    CP0.RD );


assign CP0.KERNEL_MODE = exc_level;
assign EXC.EPC_Q = epc_q;
assign DEBUG.STATUS_DATA = debug_q;


endmodule
