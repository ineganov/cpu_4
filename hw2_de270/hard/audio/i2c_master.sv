module i2c_master  ( input        CLK,
                     input        RESET,
                     inout        SDA,
                     inout        SCL );

logic [7:0] data_in;
logic [5:0] addr;

logic       start, busy, rd_adv;

counter_ll #(6) addr_cnt(CLK, RESET, rd_adv, addr );

i2c_rom #(6, 8) rom(CLK, addr, data_in);

rsd start_rsd(CLK, busy, RESET, start);

i2c   i2c( .CLK      ( CLK      ),
           .RESET    ( RESET    ),
           .START    ( start    ),     
           .BUSY     ( busy     ),
           .DATA_IN  ( data_in  ),  
           .RD_ADV   ( rd_adv   ),
           .SDA      ( SDA      ),
           .SCL      ( SCL      ));

endmodule
//============================================================//
module i2c_rom #( parameter          DEPTH = 6,
                  parameter          WIDTH = 8 )

                ( input              CLK,
                  input  [DEPTH-1:0] ADDR_IN,
                  output [WIDTH-1:0] DATA );


logic [WIDTH-1:0] ROM[0:2**DEPTH-1];
logic [WIDTH-1:0] rd_reg;

initial
   $readmemh ("i2c.txt", ROM);

always_ff@(posedge CLK)
   rd_reg <= ROM[ADDR_IN];

assign DATA = rd_reg;

endmodule
//============================================================//