//==============================================================//
module simple_fifo #(parameter D = 11, W = 16)
                    ( input          CLK,
                      input          RESET,
                      input          RE,
                      input          WE,
                      output [W-1:0] R_DATA,
                      input  [W-1:0] W_DATA,
                      output [D-1:0] FILL,
                      output         NOT_EMPTY,
                      output         OVFLOW );

logic unsigned [D-1:0] read_ptr, write_ptr, next_fill, fill;
logic empty;

// have a simplistic 'empty' logic and a race condition for free!
// <either use not-ll counters, or non-comb read_ptr>
// assign empty = (read_ptr == write_ptr);

assign next_fill = write_ptr - read_ptr;
assign empty     = (fill == '0); //'
assign OVFLOW    = ((next_fill == '1) && WE); //'
assign NOT_EMPTY = ~empty;
assign FILL      = fill;

counter_ll #(D) rd_ptr_cnt(CLK, RESET, RE & ~empty,  read_ptr);
counter    #(D) wr_ptr_cnt(CLK, RESET, WE & ~OVFLOW, write_ptr);
ffd        #(D) fill_fd(CLK, RESET, 1'b1, next_fill, fill);

dp_ram  #(D, W) dp_ram ( .CLK    ( CLK       ),
                         .R_ADDR ( read_ptr  ),
                         .R_DATA ( R_DATA    ),
                         .WE     ( WE        ),
                         .W_ADDR ( write_ptr ),
                         .W_DATA ( W_DATA    ));

endmodule
//==============================================================//
module dp_ram  #( parameter          DEPTH = 11,
                  parameter          WIDTH = 16 )

                ( input              CLK,

                  input  [DEPTH-1:0] R_ADDR,
                  output [WIDTH-1:0] R_DATA,

                  input              WE,
                  input  [DEPTH-1:0] W_ADDR,
                  input  [WIDTH-1:0] W_DATA );


logic [WIDTH-1:0] ram[0:2**DEPTH-1];
logic [WIDTH-1:0] rd;

  initial
    begin
    for(int i = 0; i < (2**DEPTH); i = i + 1)
      ram[i] = '0; //'
    end


  always_ff@(posedge CLK)
    begin
    if(WE) ram[W_ADDR] <= W_DATA;
    rd  <= ram[R_ADDR];
    end

assign R_DATA = rd;
    
endmodule
//==============================================================//
