module muldiv  ( input                CLK,
                 input                MUL,
                 input                MAD,
                 input                SIGN,
                 input  signed [31:0] A,
                 input  signed [31:0] B,
                 output        [31:0] HI,
                 output        [31:0] LO );

logic               mad_q;
logic signed [63:0] Q;
logic signed [63:0] s_mult, s_mult_q, acc_sum;

assign s_mult  = A*B;
assign acc_sum = s_mult_q + Q;

ffd #(  1) mad_reg(CLK, 1'b0, MUL, MAD, mad_q);
ffd #( 64) mul_reg(CLK, 1'b0, MUL, s_mult, s_mult_q);

ffd #( 64) hi_lo_reg(CLK, 1'b0, 1'b1, (mad_q ? acc_sum : s_mult_q), Q);

assign HI = Q[63:32];
assign LO = Q[31:0];

endmodule
