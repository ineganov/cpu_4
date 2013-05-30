module phy_mem #( parameter RAM_DEPTH = 14 ) //num_words = 2^D; bytes = 2^(D+2)
                ( input         CLK,
                  input         RESET,
                  if_memory.mem MEM,
                  if_io.io      IO );

logic [RAM_DEPTH-1:0] imem_addr, dmem_addr, io_addr;
logic          [31:0] imem_data, dmem_data, dmem_data_m, io_data, wdata;
logic           [3:0] dmem_be;
logic                 do_we, ibe, dbe, dmem_we, io_request, io_request_q;

assign imem_addr = MEM.iADDR[RAM_DEPTH-1:0];
assign dmem_addr = MEM.dADDR[RAM_DEPTH-1:0];
assign   io_addr = MEM.dADDR[RAM_DEPTH-1:0];

//Inhibit writes during DBE or after exception occurs
assign do_we   = MEM.WE & ~MEM.INHIBIT; //MEM.WE & ~(MEM.INHIBIT | dbe);

assign dmem_be = MEM.BE;
assign dmem_we = do_we & ~io_request;
assign wdata   = MEM.WD;

assign io_request = MEM.dADDR[RAM_DEPTH];

//Raise Instruction Bus Error on any tick we try to fetch instruction not from memory
assign ibe = (MEM.iADDR[29:RAM_DEPTH+1] != '0); //'

//Memory works with 1 cycle latency, bus errors should too
ffd #(1) ibe_reg(CLK,  RESET,  1'b1, ibe, MEM.IBE);

//Raise Data Bus Error on read/write requests to reserved regions 
assign dbe = (MEM.RE  | MEM.WE) & (MEM.dADDR[29:RAM_DEPTH+1] != '0); //'
assign MEM.DBEa = dbe; //Not clean, but it is needed for a proper inhibit operation

//Memory works with 1 cycle latency, bus errors should too
ffd #(1) dbe_reg(CLK,  RESET,  1'b1, dbe, MEM.DBE);

ffd #(1) iorq_reg(CLK, RESET, 1'b1, io_request, io_request_q);

onchip_ram #(RAM_DEPTH) 
           onchip_ram ( .CLK    ( CLK       ),  //input          
                        .I_ADDR ( imem_addr ),  //input  [D-1:0] 
                        .I_RD   ( imem_data ),  //output  [31:0]  
                        .D_ADDR ( dmem_addr ),  //input  [D-1:0] 
                        .D_WE   ( dmem_we   ),  //input          
                        .D_BE   ( dmem_be   ),  //input    [3:0] 
                        .D_WD   ( wdata     ),  //input   [31:0] 
                        .D_RD   ( dmem_data )); //output  [31:0] 

io_space #(RAM_DEPTH)
         io_space( .CLK     ( CLK        ),
                   .RESET   ( RESET      ),
                   .DBE     ( dbe        ),
                   .IO_REQ  ( io_request ),
                   .IO_WE   ( MEM.WE     ),
                   .IO_RE   ( MEM.RE     ),
                   .IO_ADDR ( io_addr    ), //same addresses for io and mem
                   .IO_WD   ( MEM.WD     ),
                   .IO_RD   ( io_data    ),
                   .IO      ( IO         ) );


mux2 io_or_mem(io_request_q, dmem_data, io_data, dmem_data_m );

assign MEM.iDATA = imem_data;
assign MEM.dDATA = dmem_data_m;

always@(posedge CLK)
  if(do_we)
   $display("[%8tps] MEMORY WR: %08X --> @%08x", $time, 
                                                   MEM.WD, 
                                                   {MEM.dADDR, 2'b00});
endmodule
