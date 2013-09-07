//--------------------------------------------------------------------------//
module quad_control (input         CLK,
                     input         RESET,

                     input         WE,
                     input   [3:0] A,
                     input  [31:0] WD,
                     output [31:0] RD,

                     input   [5:0] RADIO,
                     output  [3:0] ENGINE ); 

logic [31:0] rtc_val;
logic [11:0] pw_ch1, pw_ch2, pw_ch3, pw_ch4, pw_ch5, pw_ch6;
logic  [9:0] e1_q, e2_q, e3_q, e4_q;
logic  [5:0] online;
logic        stb_1m, rtc_reset;

logic [5:0] cnt_div = 0;
assign stb_1m = (cnt_div == 6'd49);
always_ff@(posedge CLK)
  if(stb_1m) cnt_div <= 6'd0;
  else       cnt_div <= cnt_div + 1'b1;


ffd #(10) eng_1_fd(CLK, RESET, WE & (A == 4'd0), WD[9:0], e1_q);
ffd #(10) eng_2_fd(CLK, RESET, WE & (A == 4'd1), WD[9:0], e2_q);
ffd #(10) eng_3_fd(CLK, RESET, WE & (A == 4'd2), WD[9:0], e3_q);
ffd #(10) eng_4_fd(CLK, RESET, WE & (A == 4'd3), WD[9:0], e4_q);

ppm_out eng_1_ppm (CLK, stb_1m, e1_q, ENGINE[0]);
ppm_out eng_2_ppm (CLK, stb_1m, e2_q, ENGINE[1]);
ppm_out eng_3_ppm (CLK, stb_1m, e3_q, ENGINE[2]);
ppm_out eng_4_ppm (CLK, stb_1m, e4_q, ENGINE[3]);

radio_rx rx_ch1(CLK, RESET, stb_1m, RADIO[0], online[0], pw_ch1);
radio_rx rx_ch2(CLK, RESET, stb_1m, RADIO[1], online[1], pw_ch2);
radio_rx rx_ch3(CLK, RESET, stb_1m, RADIO[2], online[2], pw_ch3);
radio_rx rx_ch4(CLK, RESET, stb_1m, RADIO[3], online[3], pw_ch4);
radio_rx rx_ch5(CLK, RESET, stb_1m, RADIO[4], online[4], pw_ch5);
radio_rx rx_ch6(CLK, RESET, stb_1m, RADIO[5], online[5], pw_ch6);

assign rtc_reset = WE & (A == 4'd7);
counter #(32) rtc(CLK, RESET | rtc_reset, stb_1m, rtc_val);

mux16 #(32) out_mux(   A,
                     { 22'd0, e1_q },
                     { 22'd0, e2_q },
                     { 22'd0, e3_q },
                     { 22'd0, e4_q },
                       32'd0,
                       32'd0,
                       32'd0,
                       rtc_val,
                     { 20'd0, pw_ch1 },
                     { 20'd0, pw_ch2 },
                     { 20'd0, pw_ch3 },
                     { 20'd0, pw_ch4 },
                     { 20'd0, pw_ch5 },
                     { 20'd0, pw_ch6 },
                       32'd0,
                     { 26'd0, online },
                       RD               );

endmodule
//--------------------------------------------------------------------------//
module ppm_out( input        CLK,
                input        STB_1M,
                input  [9:0] VAL,
                output logic PPM );

logic [11:0] cnt_all = 0;
logic [11:0] cnt_var;

logic        var_part_done, cycle_done, out; 

assign var_part_done = (cnt_all == cnt_var );
assign cycle_done    = (cnt_all == 12'd2250);

always_ff@(posedge CLK)
   if(cycle_done)
      begin
      cnt_all <= 12'd0;
      cnt_var <= VAL + 12'd1000;
      end
   else  cnt_all <= cnt_all + STB_1M;

always_ff@(posedge CLK)
   if(cycle_done)          PPM <= 1'b1;
   else if (var_part_done) PPM <= 1'b0;

endmodule
//--------------------------------------------------------------------------//

