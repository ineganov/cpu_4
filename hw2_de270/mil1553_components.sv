//=============================================================//
module ffd #( parameter WIDTH = 32)
            ( input                  CLK, 
              input                  RESET,
              input                  EN,
              input      [WIDTH-1:0] D,
              output reg [WIDTH-1:0] Q );
                 
always_ff @(posedge CLK)
  if (RESET)  Q <= 0;
  else if(EN) Q <= D;

endmodule
//=============================================================//
module rsd  ( input        CLK, 
              input        RESET,
              input        SET,
              output logic Q );
                 
always_ff @(posedge CLK)
  if (SET)       Q <= 1'b1;
  else if(RESET) Q <= 1'b0;

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
//=============================================================//
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
//=============================================================//
module sat_counter #(parameter D = 11)
                    (input          CLK,
                     input          RESET,
                     input          EN,
                     output [D-1:0] OUT );

logic [D-1:0] cnt; 
logic ov;

assign ov = (cnt == '1); //'

always_ff@(posedge CLK)
   if(RESET)           cnt <= '0; //'
   else if (EN && !ov) cnt <= cnt + 1'b1;

assign OUT = cnt;
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
module sync (  input  CLK,
               input  IN,
               output OUT );
 
reg [1:0] v;

always_ff @(posedge CLK)
  v <= {v[0], IN};

assign OUT = v[1];
               
endmodule
//=============================================================//
module one_shot #(parameter SIZE = 5, VALUE = 30)
                 ( input  CLK,
                   input  RESET,
                   input  START,
                   output PULSE );

logic [SIZE-1:0] cnt_q;
logic timeout, run;

counter #(SIZE) cnt(CLK, ~run | START, run, cnt_q );

assign timeout = (cnt_q == (VALUE-1));
rsd rsd(CLK, RESET | timeout, START, run);

assign PULSE = timeout;
endmodule
//=============================================================//
module two_shot #(parameter SIZE = 5, VALUE_1 = 5, VALUE_2 = 30)
                 ( input  CLK,
                   input  RESET,
                   input  START,
                   output PULSE_1,
                   output PULSE_2 );

logic [SIZE-1:0] cnt_q;
logic timeout_1, timeout_2, run;

counter #(SIZE) cnt(CLK, ~run | START, run, cnt_q );

assign timeout_1 = (cnt_q == (VALUE_1-1));
assign timeout_2 = (cnt_q == (VALUE_2-1));

rsd rsd(CLK, RESET | timeout_2, START, run);

assign PULSE_1 = timeout_1;
assign PULSE_2 = timeout_2;
endmodule
//=============================================================//
module sync_edetect (  input  CLK,
                       input  IN,
                       output OUT,
                       output EDGE );
 
logic [2:0] v;

always_ff @(posedge CLK)
  v <= {v[1:0], IN};

assign OUT  = v[1];
assign EDGE = v[2] ^ v[1];
               
endmodule
//=============================================================//
module sync_edetect_p (  input  CLK,
                         input  IN,
                         output POSEDGE );
 
logic [2:0] v;

always_ff @(posedge CLK)
  v <= {v[1:0], IN};

assign POSEDGE = ~v[2] & v[1];
               
endmodule
//=============================================================//
module edetect_p (  input  CLK,
                    input  IN,
                    output POS );
 
logic [1:0] v;

always_ff @(posedge CLK)
  v <= {v[0], IN};

assign POS = ~v[1] & v[0];
               
endmodule
//=============================================================//
module shiftin_reg_left #(parameter SIZE = 8) ( input             CLK,
                                                input             RESET,
                                                input             SHIFT,
                                                input             IN,
                                                output [SIZE-1:0] OUT );

logic [SIZE-1:0] sreg;

always_ff @(posedge CLK)
   if     (RESET) sreg <= '0; //'
   else if(SHIFT) sreg <= {sreg[SIZE-2:0], IN};

assign OUT = sreg;

endmodule
//=============================================================//