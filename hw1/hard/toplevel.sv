module toplevel( input        CLK,
                 input        BTN,
                 output [7:0] LEDS );

logic [7:0] reset_count;
logic       btn_s, CLK_CPU, count_max;
if_io       IO();

pll pll(CLK, CLK_CPU);

sync reset_sync(CLK_CPU, ~BTN, btn_s);

assign count_max = (reset_count == '1); //'
counter #(8) reset_cnt(CLK_CPU, btn_s, ~count_max, reset_count);

mcpu mcpu( CLK_CPU, ~count_max, IO );

ffd #(8) led_reg(CLK_CPU, ~count_max, IO.LEDS_WE, IO.LEDS_WD, LEDS);

endmodule
