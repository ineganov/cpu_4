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
logic leds_select, uart_select, qcon_select, hp_select;

ffd #(4)         ctrl_fd(CLK, RESET, 1'b1, {IO_REQ, DBE, IO_WE, IO_RE}, {ioreq_q, dbe_q, iowe_q, iore_q});
ffd #(RAM_DEPTH) addr_fd(CLK, RESET, 1'b1, IO_ADDR, addr_q);
ffd #(32)        data_fd(CLK, RESET, 1'b1, IO_WD,     wd_q);

assign req_valid = ioreq_q & ~dbe_q;
assign leds_select = (addr_q[7:4] == 4'd0);
assign uart_select = (addr_q[7:4] == 4'd1);
assign qcon_select = (addr_q[7:4] == 4'd3);
assign hp_select   = (addr_q[7:4] == 4'd4);

assign IO.LEDS_WE = leds_select & iowe_q & req_valid;
assign IO.LEDS_WD = wd_q[7:0];
assign IO.LEDS_A  = addr_q[3:0];

assign IO.UART_WE = uart_select & iowe_q & req_valid;
assign IO.UART_RE = uart_select & iore_q & req_valid;
assign IO.UART_WD = wd_q;
assign IO.UART_A  = addr_q[1:0];

assign IO.I2C_A  = addr_q[3:0];

assign IO.QCON_WE = qcon_select & iowe_q & req_valid;
assign IO.QCON_WD = wd_q;
assign IO.QCON_A  = addr_q[3:0]; 

assign IO.HP_WE = hp_select & iowe_q & req_valid;
assign IO.HP_WD = wd_q;
assign IO.HP_A  = addr_q[3:0]; 

mux8  #(32) read_mux( addr_q[6:4],
                     IO.LEDS_RD,   // 0 
                     IO.UART_RD,   // 1
                     IO.I2C_RD,    // 2
                     IO.QCON_RD,   // 3
                     IO.HP_RD,     // 4
                     32'd0,        // 5
                     32'd0,        // 6
                     32'd0,        // 7
                     IO_RD );

    
endmodule