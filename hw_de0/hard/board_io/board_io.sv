module board_io ( input         CLK,
                  output        SRESET,

                  input         WE,
                  input   [3:0] A,
                  input  [31:0] WD,
                  output [31:0] RD,
                  output        INT_BTN,

                  input   [1:0] BTNS,
                  input   [3:0] DIP_SW,
                  output  [7:0] LEDS );

logic  [3:0] dip_sw_s0, dip_sw_s1;
logic  [1:0] btn_s0, btn_s1;
logic        reset;

ffd #(8) led_reg(CLK, reset,   WE & (A == 4'd0),   WD[7:0],   LEDS);
rsd      int_reg(CLK, reset | (WE & (A == 4'd15)), btn_s1[1], INT_BTN);

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


assign RD     = {27'd0, btn_s1[1], dip_sw_s1 };
assign SRESET = reset;

endmodule