module board_io ( input         CLK,
                  output        SRESET,

                  input         WE,
                  input   [3:0] A,
                  input  [31:0] WD,
                  output [31:0] RD,
                  output        INT_BTN,

                  input   [1:0] BTNS,
                  input  [17:0] DIP_SW,
                  output [25:0] LEDS,
                 
                  output  [7:0] HEX_0,
                  output  [7:0] HEX_1,
                  output  [7:0] HEX_2,
                  output  [7:0] HEX_3,
                  output  [7:0] HEX_4,
                  output  [7:0] HEX_5,
                  output  [7:0] HEX_6,
                  output  [7:0] HEX_7  );

logic  [17:0] dip_sw_s0, dip_sw_s1;
logic   [1:0] btn_s0, btn_s1;
logic         reset;

ffd #(26) led_reg(CLK, reset,   WE & (A == 4'd0),   WD[25:0],  LEDS);
rsd       int_reg(CLK, reset | (WE & (A == 4'd15)), btn_s1[1], INT_BTN);

seven_seg hex_reg( .CLK   ( CLK              ), 
                   .RESET ( reset            ),   
                   .EN    ( WE & (A == 4'd1) ),
                   .VALUE ( WD               ), .*);


always_ff@(posedge CLK)
   begin
   dip_sw_s0 <= DIP_SW;
   dip_sw_s1 <= dip_sw_s0;
   end

always_ff@(posedge CLK)
   begin
   btn_s0 <= ~BTNS;
   btn_s1 <= btn_s0;
   end

autoreset #(8) autoreset(CLK, btn_s1[0], reset);

assign RD     = {6'd0, dip_sw_s1 };
assign SRESET = reset;

endmodule

