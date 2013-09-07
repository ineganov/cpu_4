module alu( input   [4:0] ctrl,
            input  [31:0] A, 
            input  [31:0] B,
            input   [4:0] SH,
            output        OV,
            output [31:0] Y );

// ALU:
// ctrl[0] -- negate
// ctrl[1] -- select SUM(0) or SLT(1)

// LOGIC: 
// ctrl[1:0] == 2'b00 --> AND
// ctrl[1:0] == 2'b01 --> OR
// ctrl[1:0] == 2'b10 --> XOR
// ctrl[1:0] == 2'b11 --> NOR

// SHIFTER:
// ctrl[2] -- select variable (1) or immediate(0) shift
// ctrl[1:0] == 2'b00 --> left  logical
// ctrl[1:0] == 2'b01 --> right logical
// ctrl[1:0] == 2'b10 --> left  arithmetic
// ctrl[1:0] == 2'b11 --> right arithmetic

// ctrl[2] -- select logic (1) or arithmetic(0)
// ctrl[3] -- select shifter (1) or alu (0)

// ctrl[4] -- sign bit or overflow enable

logic [31:0] arith_out;
arith_op    arith_op( .OP   ( ctrl[1:0] ),
                      .SIGN (   ctrl[4] ),
                      .A    (        A  ),
                      .B    (        B  ),
                      .Y    ( arith_out ),
                      .OV   (        OV ) );

logic [31:0] logic_out;
logic_op      logic_op( .OP ( ctrl[1:0] ),
                        .A  (         A ),
                        .B  (         B ),
                        .Y  ( logic_out ));

logic [4:0] shamt; 
mux2 #(5) shift_in_mux( .S  (   ctrl[2] ),
                        .D0 (        SH ),
                        .D1 (    A[4:0] ),
                        .Y  (     shamt ));

logic [31:0] shift_out;
shifter   shifter_unit( .S  ( ctrl[1:0] ),
                        .N  (     shamt ),
                        .A  (         B ),
                        .Y  ( shift_out ));


logic [31:0] alu_out;
mux2 alu_out_mux(ctrl[2], arith_out, logic_out, alu_out );
mux2   final_mux(ctrl[3], alu_out, shift_out, Y);

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
assign Ov = op_ov & En;

endmodule
//-------------------------------------------------------------------------//
module arith_op( input   [1:0] OP,
                 input         SIGN,
                 input  [31:0] A,
                 input  [31:0] B,
                 output [31:0] Y,
                 output        OV );

//sign or zero-extension bits:
wire AE_bit = SIGN ? A[31] : 1'b0;
wire BE_bit = SIGN ? B[31] : 1'b0;

wire [32:0] op_A = {AE_bit, A};
wire [32:0] op_B = {BE_bit, B};

wire          Cin = OP[0]; //carry in. Equals 1 when B = NEGATE(B)
wire [32:0] op_BN = Cin ? ~op_B : op_B; //inverted or not B
wire [32:0] Sum = op_A + op_BN + Cin;

wire [31:0] Zero_extend = {31'b0, Sum[32]};

ov_detect ov_detect(SIGN & ~OP[1], op_A[31], op_BN[31], Sum[31], OV);

assign Y = OP[1] ? Zero_extend : Sum[31:0];

endmodule
//-------------------------------------------------------------------------//
module logic_op( input   [1:0] OP,
                 input  [31:0] A,
                 input  [31:0] B,
                 output [31:0] Y );

mux4 log_op_mux( .S (     OP ), 
                 .D0(  A & B ),
                 .D1(  A | B ),
                 .D2(  A ^ B ),
                 .D3(~(A | B)),
                 .Y (      Y ) );

endmodule
//-------------------------------------------------------------------------//
