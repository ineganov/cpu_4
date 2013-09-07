module hp_display ( input         CLK,
                    input         RESET,

                    input         WE,
                    input   [3:0] A,
                    input  [31:0] WD,
                    output [31:0] RD,

                    output        HP_CE,
                    output        HP_RS,
                    output        HP_RESET,
                    output        HP_BLANK,
                    output        HP_OSCSEL,
                    output        HP_DO,
                    output        HP_CLK );

logic [4:0] bits_q;
logic       shift, shifting, done, dot_sel, ctrl_sel;

assign dot_sel  = (A == 4'd0);
assign ctrl_sel = (A == 4'd1); 

ffd #(5) bits_fd(CLK, RESET, WE & ctrl_sel, WD[4:0], bits_q);

rsd en_reg(CLK, RESET | (shift & done), WE & (A == 4'd0), shifting);

so_reg_left #(8) sreg( .CLK    ( CLK          ),
                       .UPDATE ( WE & dot_sel ),
                       .SHIFT  ( shift        ),
                       .DATA   ( WD[7:0]      ),
                       .OUT    ( HP_DO        ),
                       .EMPTY  ( done         ) );

hp_clk_div hp_clk_div( .CLK    ( CLK          ), 
                       .RESET  ( WE & dot_sel ),
                       .EN     ( shifting     ),
                       .SHIFT  ( shift        ),
                       .HP_CLK ( HP_CLK       ) );

assign HP_RESET  = ~bits_q[4]; // 0 for normal operation
assign HP_OSCSEL = ~bits_q[3]; // 0 for internal osc
assign HP_BLANK  =  bits_q[2]; // 0 for no blank
assign HP_RS     =  bits_q[1]; // 0 -- Dot reg, 1 -- Control 
assign HP_CE     = ~bits_q[0]; // 1 to select the chip

assign RD = {31'd0, shifting};

endmodule
//--------------------------------------------------------//
module hp_clk_div( input  CLK, 
                   input  RESET,
                   input  EN,
                   output SHIFT,
                   output HP_CLK );

logic [5:0] clk_div;

always_ff@(posedge CLK)
   if(RESET) clk_div <= '0; // '
   else      clk_div <= clk_div + EN;

assign HP_CLK = clk_div[5];
assign SHIFT  = (clk_div == '1); //'

endmodule
//--------------------------------------------------------//
module so_reg_left #( parameter      D = 8)
                    ( input         CLK,
                      input         UPDATE,
                      input         SHIFT,
                      input [D-1:0] DATA,
                      output        OUT,
                      output        EMPTY );

`include "log2.inc"

localparam C = log2(D-1); 

logic [D-1:0] sreg;
logic [C-1:0] cnt;

always_ff@(posedge CLK)
  if     (UPDATE)  sreg <= DATA;
  else if(SHIFT)   sreg <= {sreg[D-2:0], 1'b0};

always_ff@(posedge CLK)
  if     (UPDATE)  cnt <= (D-1);
  else if(SHIFT)   cnt <= cnt - 1'b1;

assign OUT   = sreg[D-1];
assign EMPTY = (cnt == '0); //'

endmodule
//--------------------------------------------------------//
