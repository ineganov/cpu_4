module alu( input   [7:0] ctrl,
            input  [31:0] A, 
            input  [31:0] B,
            input   [4:0] SH,
            output        OV,
            output [31:0] Y );

// ctrl  [7]: Signed operation (e.g. SLT/SLTU)
// ctrl  [6]: SHIFT SRC (1 - reg, 0 - shamt)
// ctrl[5:4]: SHIFT OP
// ctrl  [3]: NEGATE B
// ctrl[2:0]: ALU OP


//sign or zero-extension bits:
wire AE_bit = ctrl[7] ? A[31] : 1'b0;
wire BE_bit = ctrl[7] ? B[31] : 1'b0;

wire [32:0] op_A = {AE_bit, A};
wire [32:0] op_B = {BE_bit, B};

wire Cin = ctrl[3]; //carry in. Equals 1 when B = NEGATE(B)
wire [32:0] op_BN = Cin ? ~op_B : op_B; //inverted or not B

wire [32:0] Sum = op_A + op_BN + Cin;

ov_detect ov_detect(ctrl[7], ctrl[2:0], op_A[31], op_BN[31], Sum[31], OV);

wire [4:0] shamt; 
mux2 #(5) shift_in_mux( .S (ctrl[6]),
                        .D0(SH),
                        .D1(A[4:0]),
                        .Y (shamt));

wire[31:0] sh_out;
shifter shifter_unit( .S(ctrl[5:4]),
                      .N(  shamt  ),
                      .A(    B    ),
                      .Y(  sh_out ) );

wire [31:0] Zero_extend = {31'b0, Sum[32]};

//wire [31:0] MUL = A * B;

mux8 out_mux( .S (  ctrl[2:0]      ),
              .D0(  A & B          ),
              .D1(  A | B          ),
              .D2(  A ^ B          ),
              .D3(~(A | B)         ),
              .D4(  Sum[31:0]      ),
              .D5(  A + 3'd4       ),
              .D6(  sh_out         ), 
              .D7(  Zero_extend    ),
              .Y (  Y              ) );

endmodule

//-------------------------------------------------------------------------//
module shifter( input         [1:0] S,
                input         [4:0] N,
                input signed [31:0] A,
                output       [31:0] Y );
            
//sel[1]: 0 -- logical, 1 -- arithmetic
//sel[0]: 0 -- left,    1 --right

assign Y = S[1] ? (S[0] ? A >>> N : A <<< N) :
                  (S[0] ?  A >> N : A << N);
          
endmodule
//-------------------------------------------------------------------------//
module ov_detect( input        En,
                  input  [2:0] Optype,
                  input        A_sign,
                  input        B_sign,
                  input        Y_sign,
                  output       Ov );

// Overflow detection for addition
// Overflow occurs only when signs of the operands match,
// but the resulting sign differs.

logic op_ov;

always_comb
  if(A_sign == B_sign)  op_ov = A_sign ^ Y_sign;
  else                  op_ov = 1'b0;

//This ensures that overflow occurs for signed adds and subs only
assign Ov = op_ov & En & (Optype == 3'b100);

endmodule


/*
//-------------------------------------------------------------------------//
module logic_op( input   [1:0] OP,
                 input  [31:0] A,
                 input  [31:0] B,
                 output [31:0] Y );

mux4( .S (     OP ), 
      .D0(  A & B ),
      .D1(  A | B ),
      .D2(  A ^ B ),
      .D3(~(A | B)),
      .Y (      Y ) );

endmodule

*/
