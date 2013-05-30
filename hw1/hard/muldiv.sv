module muldiv  ( input         CLK,
                 input         MUL,
                 input         MAD,
                 input         SIGN,
                 input  [31:0] A,
                 input  [31:0] B,
                 output [31:0] HI,
                 output [31:0] LO );

logic [63:0] Q;
logic unsigned [63:0] U_MULT;

assign U_MULT = A*B;

ffd #( 64) hi_lo_reg(CLK, 1'b0, MUL, U_MULT, Q);

assign HI = Q[63:32];
assign LO = Q[31:0];

endmodule
