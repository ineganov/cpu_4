module radio_rx(  input         CLK,
                  input         RESET,
                  input         EN,
                  input         RADIO_IN,
                  output logic  ONLINE,
                  output [11:0] PULSE_WIDTH );


logic [14:0] timeout_cnt;
logic [11:0] pulse_width;
logic        sync_out, clean_out, edge_p, edge_n, do_count, timeout;

sync         smodule(CLK, RADIO_IN, sync_out);
hystheresis  hmodule(CLK, EN, sync_out, clean_out); 
edetect      emodule(CLK, clean_out, edge_p, edge_n);

assign do_count = EN & clean_out & (pulse_width != '1); //'
counter #(12) pw_counter(CLK, RESET | edge_n, do_count, pulse_width );

ffd #(12) pw_reg(CLK, RESET, edge_n, pulse_width, PULSE_WIDTH);

assign timeout = (timeout_cnt == '1); //'
counter #(15) timeout_counter(CLK, RESET | edge_p, EN, timeout_cnt);

always_ff@(posedge CLK)
  if(edge_p)       ONLINE <= 1'b1;
  else if(timeout) ONLINE <= 1'b0;
                  
endmodule