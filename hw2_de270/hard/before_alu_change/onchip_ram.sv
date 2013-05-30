//===============================================//
module onchip_ram  #( parameter D = 14 ) //num_words = 2^D; bytes = 2^(D+2)
 
                    ( input          CLK,

                      input  [D-1:0] I_ADDR,
                      output  [31:0] I_RD, 
        
                      input  [D-1:0] D_ADDR,
                      input          D_WE,
                      input    [3:0] D_BE,
                      input   [31:0] D_WD,
                      output  [31:0] D_RD );

logic [3:0][7:0] RAM[0:2**D-1];
logic [31:0] rr_i, rr_d;

initial
  $readmemh ("soft/program.txt", RAM);

always_ff@(posedge CLK)
   begin
   if (D_WE) 
     begin
     if(D_BE[0]) RAM[D_ADDR][0] <= D_WD[07:00];
     if(D_BE[1]) RAM[D_ADDR][1] <= D_WD[15:08];
     if(D_BE[2]) RAM[D_ADDR][2] <= D_WD[23:16];
     if(D_BE[3]) RAM[D_ADDR][3] <= D_WD[31:24];
     end
   rr_d <= RAM[D_ADDR];
   end

always_ff@(posedge CLK)
   rr_i <= RAM[I_ADDR];

assign D_RD = rr_d;
assign I_RD = rr_i;

endmodule
//===============================================//
