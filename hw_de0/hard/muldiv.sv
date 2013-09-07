//============================================================================//
module muldiv  ( input                CLK,
                 input                RESET,
                 input                EN,
                 input          [2:0] OP, // op[2] = sel mthi/mtlo; op[1:0]: 0=mul, 1=mad, 2=mt, 3=div
                 input  signed [31:0] A,
                 input  signed [31:0] B,
                 output        [31:0] HI,
                 output        [31:0] LO,
                 output               BUSY );

logic               busy_mul, busy_div, div_wr;
logic         [2:0] op_q;
logic signed [63:0] mt_hilo, hilo, hilo_q;
logic signed [63:0] s_mult, s_mult_q, s_mad_q;
logic        [31:0] quot, rem, a_q;

assign s_mult  = A*B;
assign s_mad_q = s_mult_q + hilo_q;

ffd #(  3)    op_reg(CLK, RESET, EN, OP, op_q);

ffd #( 32) mt_reg   ( CLK, RESET, EN,   A,                  a_q      );
ffd #( 64) mul_reg  ( CLK, RESET, EN,   s_mult,             s_mult_q );
ffd #(  1) busym_reg( CLK, RESET, 1'b1, EN & (OP != 2'b11), busy_mul );

// mthi / mtlo select
assign mt_hilo = op_q[2] ? {a_q, hilo_q[31:0]} : {hilo_q[63:32], a_q};

mc_div #(32) mc_div ( .CLK      ( CLK               ),
                      .RESET    ( RESET             ),
                      .GO       ( EN & (OP == 2'b11)),
                      .BUSY     ( busy_div          ),
                      .W_RESULT ( div_wr            ),
                      .A        ( A                 ),
                      .B        ( B                 ),
                      .QUOT     ( quot              ),
                      .REM      ( rem               ) );

mux4 #(64) hilo_wr_mux ( .S  ( op_q[1:0]   ),
                         .D0 ( s_mult_q    ),
                         .D1 ( s_mad_q     ),
                         .D2 ( mt_hilo     ),
                         .D3 ( {rem, quot} ),
                         .Y  ( hilo        ) );

ffd #( 64) hi_lo_reg(CLK, RESET, busy_mul | div_wr, hilo, hilo_q);


assign HI = hilo_q[63:32];
assign LO = hilo_q[31:0];
assign BUSY = busy_mul | busy_div;

endmodule
//============================================================================//
module mc_div #( parameter W = 4 ) 
               ( input          CLK,
                 input          RESET,

                 input          GO,
                 output         BUSY,
                 output         W_RESULT,

                 input  [W-1:0] A,
                 input  [W-1:0] B,

                 output [W-1:0] QUOT,
                 output [W-1:0] REM );

`include "log2.inc"

localparam C = log2(W); 

logic    [2*W-1:0] nextval, Q;
logic      [W-1:0] dvsr, hiword;
logic signed [W:0] diff;
logic      [C-1:0] cnt;
logic              busy;

assign hiword = Q[2*W-2:W-1];

assign diff = hiword - dvsr; //2r0 - D, MSB part

assign nextval =         GO ? { {W{1'b0}}, A}               :
                    diff[W] ? Q << 1                        : 
                              {diff[W-1:0], Q[W-2:0], 1'b1} ;

ffd   #(W) dvsr_reg(CLK, RESET, GO, B, dvsr);

ffd #(2*W) result_reg(CLK, RESET, GO | busy, nextval, Q);

rsd  busy_reg(CLK, RESET | W_RESULT, GO, busy );

counter #(C) counter( CLK, GO, busy, cnt );

assign BUSY     = busy;
assign W_RESULT = (cnt == W);

assign REM  = Q[2*W-1:W];
assign QUOT = Q[W-1:0];

endmodule
//============================================================================//
