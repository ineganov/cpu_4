module io_space #( parameter RAM_DEPTH = 14 )
               ( input                  CLK,
                 input                  RESET,
                 input                  DBE,
                 input                  IO_REQ,
                 input                  IO_WE,
                 input                  IO_RE,
                 input  [RAM_DEPTH-1:0] IO_ADDR,
                 input           [31:0] IO_WD,
                 output          [31:0] IO_RD,
                 if_io.io               IO ); //IO interface

logic [RAM_DEPTH-1:0] addr_q;
logic          [31:0] wd_q;
logic ioreq_q, dbe_q, iowe_q, iore_q, req_valid;
logic leds_select, segs_select, utx_select, urx_select, dm9k_select, aud_select;

ffd #(4)         ctrl_fd(CLK, RESET, 1'b1, {IO_REQ, DBE, IO_WE, IO_RE}, {ioreq_q, dbe_q, iowe_q, iore_q});
ffd #(RAM_DEPTH) addr_fd(CLK, RESET, 1'b1, IO_ADDR, addr_q);
ffd #(32)        data_fd(CLK, RESET, 1'b1, IO_WD,     wd_q);

assign req_valid = ioreq_q & ~dbe_q;
assign leds_select = (addr_q == 1);
assign segs_select = (addr_q == 2);
assign dm9k_select = (addr_q == 3);
assign utx_select  = ((addr_q == 4) || (addr_q == 5));
assign urx_select  = ((addr_q == 6) || (addr_q == 7));
assign aud_select  = ((addr_q == 8) || (addr_q == 9));

assign IO.LEDS_WE = leds_select & iowe_q & req_valid;
assign IO.LEDS_WD = wd_q[25:0];

assign IO.SEGS_WE = segs_select & iowe_q & req_valid;
assign IO.SEGS_WD = wd_q;

assign IO.DM9K_WE = dm9k_select & iowe_q & req_valid;
assign IO.DM9K_WD = wd_q;

assign IO.UART_TX_WE = utx_select & iowe_q & req_valid;
assign IO.UART_TX_WD = wd_q;
assign IO.UART_TX_A  = addr_q[0];

assign IO.UART_RX_WE = urx_select & iowe_q & req_valid;
assign IO.UART_RX_RE = urx_select & iore_q & req_valid;
assign IO.UART_RX_A  = addr_q[0];


assign IO.AUD_WD = wd_q[23:0];
assign IO.AUD_WE = aud_select & iowe_q; 
assign IO.AUD_A  = addr_q[0];

mux16 #(32) read_mux( addr_q[3:0],
                     32'h00000000,           // 0
                     { 14'd0, IO.LEDS_RD },  // 1
                     32'h00000000,           // 2
                     IO.DM9K_RD,             // 3
                     IO.UART_TX_RD,          // 4
                     IO.UART_TX_RD,          // 5
                     IO.UART_RX_RD,          // 6
                     IO.UART_RX_RD,          // 7
                     IO.AUD_RD,              // 8
                     IO.AUD_RD,              // 9
                     32'h00000000,           // 10
                     32'h00000000,           // 11
                     32'h00000000,           // 12
                     32'h00000000,           // 13
                     32'h00000000,           // 14
                     32'h00000000,           // 15
                     IO_RD );
    
endmodule