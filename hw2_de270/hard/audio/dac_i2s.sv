module dac_i2s(   input        MCLK,
                  input        RESET,
                  input [23:0] LEFT_DATA,
                  input [23:0] RIGHT_DATA,
                  output       ADV,

                  output       BCLK,
                  output       DACLRC,
                  output       DACDAT );


logic [23:0] data;
logic  [4:0] daclrc_cnt;
logic        daclrc_q, daclrc_toggle, load;
logic        bclk_cnt, bclk_l, bclk_q, bclk_toggle;

assign bclk_toggle = (bclk_cnt == '1); //'
counter #(1) bclk_counter(MCLK, RESET, 1'b1, bclk_cnt );
ffd     #(1)     bclk_ffd(MCLK, RESET, bclk_toggle, ~bclk_q, bclk_q );

assign bclk_l = bclk_toggle & bclk_q;

assign daclrc_toggle = (daclrc_cnt == '1) && bclk_l; //'
counter #(5) daclrc_counter(MCLK, RESET, bclk_l, daclrc_cnt );
ffd     #(1)     daclrc_ffd(MCLK, RESET, daclrc_toggle, ~daclrc_q, daclrc_q );

assign load = daclrc_toggle & bclk_l;
assign data = daclrc_q ? RIGHT_DATA : LEFT_DATA;

shift_out_reg_left #(24) sreg(MCLK, load, bclk_l, data, DACDAT);

assign BCLK   = bclk_q;
assign DACLRC = daclrc_q;

assign ADV = load & daclrc_q;
endmodule