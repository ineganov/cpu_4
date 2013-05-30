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
logic leds_select;

ffd #(4)         ctrl_fd(CLK, RESET, 1'b1, {IO_REQ, DBE, IO_WE, IO_RE}, {ioreq_q, dbe_q, iowe_q, iore_q});
ffd #(RAM_DEPTH) addr_fd(CLK, RESET, 1'b1, IO_ADDR, addr_q);
ffd #(32)        data_fd(CLK, RESET, 1'b1, IO_WD,     wd_q);

assign req_valid = ioreq_q & ~dbe_q;
assign leds_select = (addr_q == 0) & req_valid;

assign IO.LEDS_WE = leds_select & iowe_q;
assign IO.LEDS_WD = wd_q[7:0];

endmodule