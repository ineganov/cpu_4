module io_space( input            CLK,
                 input            RESET,
                 output           IS_IO,
   
                 input     [29:0] D_ADDR,
                 input            D_WE,
//               input            D_RE,
                 input     [31:0] D_WD,
                 output    [31:0] D_RD,

                 input  def::io_r IO_R,
                 output def::io_w IO_W );

// This module dispatches IO requests (both reads and writes)
// and signales to the upper level that it was an io request
// which is happened.
// Note that IO request can override a valid memory request


assign IS_IO = ({D_ADDR, 2'b00} == 32'h00010000);

assign IO_W.WD = D_WD;




assign IO_W.DIP_SW_WE = D_WE;
assign D_RD = IO_R.DIP_SW_RD;

endmodule