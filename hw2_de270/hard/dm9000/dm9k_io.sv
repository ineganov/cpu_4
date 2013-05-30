//===========================================================//
module dm9k_io( input         CLK,
                input         RESET,
                
                input         WE,
                input  [31:0] WD,
                output [31:0] RD,
                
                output        DM9K_CLK,
                output        DM9K_RESET,
                input         DM9K_INT,
                output        DM9K_CMD,
                output        DM9K_CS,
                output        DM9K_RD,
                output        DM9K_WR,
                inout  [15:0] DM9K_DATA );

//typical clock period: 20 ns (MIPS)

//Interface:

//Write word = 0x0awcDDDD
//where:
// a == 4'h1 for read or write cycle, or 4'h0 to just set cmd and reset
// w == 4'h1 for write cycle, 4'h0 for read cycle, ignored if act == 0
// c == 4'h0 for DM9K_CMD = 0 (INDEX PORT), 4'h1 for DM9K_CMD = 1 (DATA PORT), 4'h8 for RESET (positive reset logic)
// DDDD == data to write

//Read word = 0xb00fDDDD
// b == busy flag. 4'h8 if BUSY, else 4'h0
// f == flags {reset, 1'b0, int, cmd}
// DDDD == data read after last cycle

//Endianness:
//high word in high address

enum int unsigned { ST_READY   = 0, 
                    ST_READ    = 1, 
                    ST_WRITE   = 2, 
                    ST_WR_HOLD = 3,
                    ST_RD_HOLD = 4 } state, next;

//31 30 29 28  27 26 25 a     23 22 21 w  r 18 17 c
wire act   = WD[24];
wire write = WD[20];

reg        cmd, reset, ext_clk;

reg [15:0] datain;
reg [15:0] dataout;

wire OE, read, dm9k_int_sync;

sync int_sync(CLK, DM9K_INT, dm9k_int_sync );
//-------------------------------------------------------
always_ff@(posedge CLK)
  ext_clk <= ~ext_clk;

always_ff@(posedge CLK)
  if(RESET)
    begin
    reset   <= 1'b0;
    cmd     <= 1'b0;
    dataout <= 16'h0000;
    state   <= ST_READY;
    end
  else
    begin
    state <= next;
    
    if(read) datain <= DM9K_DATA;
    
    if(WE)
      begin
      reset   <= WD[19];
      cmd     <= WD[16];
      dataout <= WD[15:0];
      end
    end

always_comb
  case(state)
  ST_READY:     if(WE && act)
                  begin
                  if(write) next = ST_WRITE;
                  else      next = ST_READ;
                  end   
                else        next = ST_READY;
                  
  ST_READ:                  next = ST_RD_HOLD;
  ST_RD_HOLD:               next = ST_READY;

  ST_WRITE:                 next = ST_WR_HOLD;
  ST_WR_HOLD:               next = ST_READY;

  default:                  next = ST_READY;    
  endcase

reg [3:0] controls;
assign {OE, read, DM9K_RD, DM9K_WR} = controls;
always_comb
  case(state)               //OrRW
  ST_READY:     controls = 4'b0011;
  ST_READ:      controls = 4'b0101;
  ST_RD_HOLD:   controls = 4'b0011;
  ST_WRITE:     controls = 4'b1010;
  ST_WR_HOLD:   controls = 4'b1011;
  default:      controls = 4'b0011;    
  endcase


assign RD = {(state != ST_READY), 11'd0,   reset, 1'b0, dm9k_int_sync, cmd,   datain};
assign DM9K_CLK   = ext_clk;
assign DM9K_RESET = ~reset;
assign DM9K_CMD   = cmd;
assign DM9K_CS 	  = 1'b0;
assign DM9K_DATA  = OE ? dataout : 16'hZZZZ;

endmodule
//===========================================================//

