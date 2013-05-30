//=============================================================//
module ffd #( parameter WIDTH = 32)
            ( input                    CLK, 
              input                    RESET,
              input                    EN,
              input        [WIDTH-1:0] D,
              output logic [WIDTH-1:0] Q );
                 
always_ff @(posedge CLK)
  if (RESET)  Q <= 0;
  else if(EN) Q <= D;

endmodule
//=============================================================//
module ffds #( parameter WIDTH = 32)
             ( input                    CLK, 
               input        [WIDTH-1:0] D,
               output logic [WIDTH-1:0] Q );

always_ff @(posedge CLK) Q <= D;

endmodule
//=============================================================//
module rsd (  input        CLK,
              input        RESET,
              input        SET,
              output logic Q );

always_ff@(posedge CLK)
  if      (RESET) Q <= 1'b0;
  else if (SET)   Q <= 1'b1;
  else            Q <= Q;

endmodule
//=============================================================//
module autoreset #(parameter SIZE = 8) (input  CLK,
                                        input  EXT_RESET,
                                        output OUT );

logic [SIZE-1:0] cnt = 0;
logic            done;

assign done = (cnt == '1); //'

always_ff@(posedge CLK)
  if(EXT_RESET)   cnt <= '0; //'
  else if (!done) cnt <= cnt + 1'b1;

assign OUT = !done;

endmodule
//=============================================================//
module mux2 #(parameter WIDTH = 32)
             ( input             S,
               input [WIDTH-1:0] D0,
               input [WIDTH-1:0] D1,
               output[WIDTH-1:0] Y);

assign Y = S ? D1 : D0;

endmodule
//=============================================================//
module mux4 #(parameter WIDTH = 32)
             ( input [1:0] S,
               input [WIDTH-1:0] D0, D1, D2, D3,
               output[WIDTH-1:0] Y);

assign Y = S[1] ? (S[0] ? D3 : D2)
                : (S[0] ? D1 : D0);
                
endmodule
//=============================================================//
module mux8 #(parameter WIDTH = 32)
             ( input [2:0]       S,
               input [WIDTH-1:0] D0, D1, D2, D3, D4, D5, D6, D7,
               output[WIDTH-1:0] Y);

assign Y = S[2] ? (S[1] ? (S[0] ? D7 : D6) :
                          (S[0] ? D5 : D4)):
                  (S[1] ? (S[0] ? D3 : D2) :
                          (S[0] ? D1 : D0));

endmodule
//=============================================================//
module mux16 #(parameter WIDTH = 32) 
             (  input        [3:0] SEL,
                input  [WIDTH-1:0] D0,
                input  [WIDTH-1:0] D1,
                input  [WIDTH-1:0] D2,
                input  [WIDTH-1:0] D3,
                input  [WIDTH-1:0] D4,
                input  [WIDTH-1:0] D5,
                input  [WIDTH-1:0] D6,
                input  [WIDTH-1:0] D7,
                input  [WIDTH-1:0] D8,
                input  [WIDTH-1:0] D9,
                input  [WIDTH-1:0] D10,
                input  [WIDTH-1:0] D11,
                input  [WIDTH-1:0] D12,
                input  [WIDTH-1:0] D13,
                input  [WIDTH-1:0] D14,
                input  [WIDTH-1:0] D15,
                output [WIDTH-1:0] Y );

logic [WIDTH-1:0] out;

always_comb
   case(SEL)
   4'd0:  out = D0;
   4'd1:  out = D1;
   4'd2:  out = D2;
   4'd3:  out = D3;
   4'd4:  out = D4;
   4'd5:  out = D5;
   4'd6:  out = D6;
   4'd7:  out = D7;
   4'd8:  out = D8;
   4'd9:  out = D9;
   4'd10: out = D10;
   4'd11: out = D11;
   4'd12: out = D12;
   4'd13: out = D13;
   4'd14: out = D14;
   4'd15: out = D15;
   endcase
   
assign Y = out;

endmodule
//=============================================================//
module mux32 #(parameter WIDTH = 32) 
             (  input        [4:0] SEL,
                input  [WIDTH-1:0] D0,
                input  [WIDTH-1:0] D1,
                input  [WIDTH-1:0] D2,
                input  [WIDTH-1:0] D3,
                input  [WIDTH-1:0] D4,
                input  [WIDTH-1:0] D5,
                input  [WIDTH-1:0] D6,
                input  [WIDTH-1:0] D7,
                input  [WIDTH-1:0] D8,
                input  [WIDTH-1:0] D9,
                input  [WIDTH-1:0] D10,
                input  [WIDTH-1:0] D11,
                input  [WIDTH-1:0] D12,
                input  [WIDTH-1:0] D13,
                input  [WIDTH-1:0] D14,
                input  [WIDTH-1:0] D15,
                input  [WIDTH-1:0] D16,
                input  [WIDTH-1:0] D17,
                input  [WIDTH-1:0] D18,
                input  [WIDTH-1:0] D19,
                input  [WIDTH-1:0] D20,
                input  [WIDTH-1:0] D21,
                input  [WIDTH-1:0] D22,
                input  [WIDTH-1:0] D23,
                input  [WIDTH-1:0] D24,
                input  [WIDTH-1:0] D25,
                input  [WIDTH-1:0] D26,
                input  [WIDTH-1:0] D27,
                input  [WIDTH-1:0] D28,
                input  [WIDTH-1:0] D29,
                input  [WIDTH-1:0] D30,
                input  [WIDTH-1:0] D31,
                output [WIDTH-1:0] Y );

logic [WIDTH-1:0] out;

always_comb
   case(SEL)
   5'd0:  out = D0;
   5'd1:  out = D1;
   5'd2:  out = D2;
   5'd3:  out = D3;
   5'd4:  out = D4;
   5'd5:  out = D5;
   5'd6:  out = D6;
   5'd7:  out = D7;
   5'd8:  out = D8;
   5'd9:  out = D9;
   5'd10: out = D10;
   5'd11: out = D11;
   5'd12: out = D12;
   5'd13: out = D13;
   5'd14: out = D14;
   5'd15: out = D15;
   5'd16: out = D16;
   5'd17: out = D17;
   5'd18: out = D18;
   5'd19: out = D19;
   5'd20: out = D20;
   5'd21: out = D21;
   5'd22: out = D22;
   5'd23: out = D23;
   5'd24: out = D24;
   5'd25: out = D25;
   5'd26: out = D26;
   5'd27: out = D27;
   5'd28: out = D28;
   5'd29: out = D29;
   5'd30: out = D30;
   5'd31: out = D31;
   endcase
   
assign Y = out;

endmodule
//=============================================================//
module signext( input  [15:0] a,
                output [31:0] y );
                
assign y = {{16{a[15]}}, a};

endmodule
//=============================================================//
module immed_extend( input         [2:0] sel,
                     input        [15:0] immed,
                     output logic [31:0] immed_extend );

logic [31:0] sign_ext;

assign sign_ext = {{16{immed[15]}}, immed};
         
always_comb
  case(sel)
  3'b000:   immed_extend = sign_ext;       //sign-extension
  3'b001:   immed_extend = {16'd0, immed}; //zero-extension
  3'b010:   immed_extend = {immed, 16'd0}; //swap for lui          
  3'b011:   immed_extend = 32'd4;          //literal for ret addr calculation
  3'b100:   immed_extend = 32'd0;          //literal for mult/mt passthrough
  default:  immed_extend = 32'hXXXXXXXX;
  endcase
                     
endmodule
//=============================================================//
module branch_extend( input      [15:0] immed,
                      output reg [31:0] immed_extend );

logic [29:0] sign_ext;

assign sign_ext = {{14{immed[15]}}, immed};
                     
assign immed_extend = {sign_ext, 2'b00}; //sign-ext for branches
                     
endmodule
//=============================================================//
module sl2 (input  [31:0] a,
            output [31:0] y );

// shift left by 2
assign y = {a[29:00], 2'b00};

endmodule
//=============================================================//
module sync (  input  CLK,
               input  IN,
               output OUT );
 
reg [1:0] v;

always_ff @(posedge CLK)
  v <= {v[0], IN};

assign OUT = v[1];
               
endmodule
//=============================================================//
module edetect (  input  CLK,
                  input  IN,
                  output POS,
                  output NEG );
 
reg [1:0] v;

always@(posedge CLK)
  v <= {v[0], IN};

assign POS = v[0] & (~v[1]); 
assign NEG = v[1] & (~v[0]); 
               
endmodule
//===============================================//
module hystheresis (  input  CLK,
                      input  RESET,
                      input  IN,
                      output OUT );

reg [3:0] sr;
reg       val;

always_ff @(posedge CLK)
  if(RESET)
    begin
    sr <= 4'd0;
    val <= 1'b0;
    end
  else
    begin
    sr <= {sr[2:0], IN};
    if     (sr == '1)       val <= 1'b1;
    else if(sr == '0)       val <= 1'b0;
    else                    val <= val;
    end

assign OUT = val;
          
endmodule
//===============================================//
module counter #(parameter SIZE = 8) (  input             CLK,
                                        input             RESET,
                                        input             EN,
                                        output [SIZE-1:0] OUT );

logic [SIZE-1:0] cnt;
                                        
always_ff@ (posedge CLK)
  if(RESET)
    cnt <= '0;
  else if(EN) cnt <= cnt + 1'b1;
    
assign OUT = cnt;
                                        
endmodule
//===============================================//
module rand_cnt #(parameter SIZE = 6) (  input             CLK,
                                         input             RESET,
                                         input  [SIZE-1:0] LO,
                                         output [SIZE-1:0] OUT );

logic [SIZE-1:0] cnt;
                                        
always_ff@ (posedge CLK)
  if(RESET)
    cnt <= '1; //'
  else
    begin
    if(cnt == LO)     cnt <= '1; //'
    else              cnt <= cnt - 1'b1;
    end
    
assign OUT = cnt;
                                        
endmodule
//===============================================//
module shift_reg_lf #(parameter SIZE = 8) ( input             CLK,
                                            input             RESET,
                                            input             IN,
                                            input             EN,
                                            output [SIZE-1:0] OUT );

//LSB-first shift register

logic [SIZE-1:0] sreg;

always_ff@ (posedge CLK)
  if(RESET)   sreg <= '0; //'
  else if(EN) sreg <= {IN, sreg[SIZE-1:1]}; 

assign OUT = sreg;
endmodule
//===============================================//
module onehot #( parameter D = 5 )

               ( input           [D-1:0] SEL,
                 output logic [2**D-1:0] Y );

logic [D**2-1:0] out;

always_comb
   begin
   Y = '0; //'
   Y[SEL] = 1'b1;
   end

endmodule
//===============================================//
module negate #( parameter W = 32 )
               ( input          EN,
                 input  [W-1:0] IN,
                 output [W-1:0] OUT );

assign OUT = EN ? (~IN + 1'b1) : IN;

endmodule


//=========================================================================//
module sync_edetect (  input  CLK,
                       input  IN,
                       output OUT,
                       output EDGE,
                       output NEDGE );
 
logic [2:0] v;

always_ff @(posedge CLK)
  v <= {v[1:0], IN};

assign OUT   = v[1];
assign EDGE  = v[2] ^  v[1];
assign NEDGE = v[2] & ~v[1];
               
endmodule
//=========================================================================//
module counter_ll #(parameter SIZE = 8) (  input             CLK,
                                           input             RESET,
                                           input             EN,
                                           output [SIZE-1:0] OUT );

// Low latency version
// Outputs incremented value at the same clock with EN

logic [SIZE-1:0] cnt, cnt_plus_one;
                                   
assign cnt_plus_one = cnt + 1'b1;

always_ff@ (posedge CLK)
  if(RESET)   cnt <= '0; //'
  else if(EN) cnt <= cnt_plus_one;
    
assign OUT = EN ? cnt_plus_one : cnt;
                                        
endmodule
//=========================================================================//
module shift_out_reg_right #( parameter     D = 8)
                            ( input         CLK,
                              input         UPDATE,
                              input         SHIFT,
                              input [D-1:0] DATA,
                              output        OUT );

logic [D-1:0] sreg;

always_ff@(posedge CLK)
  if     (UPDATE) sreg <= DATA;
  else if(SHIFT)  sreg <= {1'b0, sreg[D-1:1]};

assign OUT = sreg[0];

endmodule
//=========================================================================//
module shift_in_reg_right #(parameter SIZE = 8) ( input             CLK,
                                                  input             RESET,
                                                  input             SHIFT,
                                                  input             IN,
                                                  output [SIZE-1:0] OUT );

logic [SIZE-1:0] sreg;

always_ff @(posedge CLK)
   if     (RESET) sreg <= '0; //'
   else if(SHIFT) sreg <= {IN, sreg[SIZE-1:1]};

assign OUT = sreg;

endmodule
//=========================================================================//
module shift_out_reg_left  #( parameter     D = 8)
                            ( input         CLK,
                              input         UPDATE,
                              input         SHIFT,
                              input [D-1:0] DATA,
                              output        OUT );

logic [D-1:0] sreg;

always_ff@(posedge CLK)
  if     (UPDATE) sreg <= DATA;
  else if(SHIFT)  sreg <= {sreg[D-2:0], 1'b0};

assign OUT = sreg[D-1];

endmodule
//=========================================================================//
