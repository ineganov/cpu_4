module seven_seg( input         CLK,
                  input         RESET,
                  input         EN,
                  input  [31:0] VALUE,

                  output  [7:0] HEX_0,
                  output  [7:0] HEX_1,
                  output  [7:0] HEX_2,
                  output  [7:0] HEX_3,
                  output  [7:0] HEX_4,
                  output  [7:0] HEX_5,
                  output  [7:0] HEX_6,
                  output  [7:0] HEX_7 );

logic [31:0] val_fd;

ffd #(32) value_fd(CLK, RESET, EN, VALUE, val_fd);

segment_logic sl0(val_fd[ 3:0 ], HEX_0);
segment_logic sl1(val_fd[ 7:4 ], HEX_1);
segment_logic sl2(val_fd[11:8 ], HEX_2);
segment_logic sl3(val_fd[15:12], HEX_3);
segment_logic sl4(val_fd[19:16], HEX_4);
segment_logic sl5(val_fd[23:20], HEX_5);
segment_logic sl6(val_fd[27:24], HEX_6);
segment_logic sl7(val_fd[31:28], HEX_7);

endmodule

module segment_logic( input  [3:0] nibble,
                      output [7:0] seg );
//seg = {dp, a, b, c, d, e, f, g}

logic [6:0] s;

always_comb
   case(nibble)
      4'h0: s = ~7'b1111110;
      4'h1: s = ~7'b0110000;
      4'h2: s = ~7'b1101101;
      4'h3: s = ~7'b1111001;
      4'h4: s = ~7'b0110011;
      4'h5: s = ~7'b1011011;
      4'h6: s = ~7'b1011111;
      4'h7: s = ~7'b1110000;
      4'h8: s = ~7'b1111111;
      4'h9: s = ~7'b1111011;
      4'hA: s = ~7'b1110111;
      4'hB: s = ~7'b0011111;
      4'hC: s = ~7'b1001110;
      4'hD: s = ~7'b0111101;
      4'hE: s = ~7'b1001111;
      4'hF: s = ~7'b1000111;
      default: s = ~7'b1111110;
   endcase

assign seg = {1'b1, s};

endmodule
