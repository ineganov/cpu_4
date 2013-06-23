module mcpu(  input        CLK,
              input        RESET,
              if_io.io     IO);
              

parameter RAM_DEPTH = 13; //num_words = 2^D; bytes = 2^(D+2)
            
logic jtag_reset, any_reset;
assign any_reset = jtag_reset | RESET;

def::c_inst INST_INFO; //instruction decoder input
def::ctrl   CTRL_INFO; //instruction decoder output

if_hazard  if_hazard();  //hazard unit interface
if_except  if_except();  //exceptions interface
if_cp0     if_cp0();     //coprocessor0 interface
if_memory  if_memory();  //memory interface
if_debug   if_debug();   //JTAG debug interface

controller the_controller ( INST_INFO, CTRL_INFO );

hazard_unit the_hazard_unit( if_hazard );

datapath     the_datapath ( .CLK      ( CLK            ),
                                  
                            //Controller iface
                            .INST_O   ( INST_INFO      ), //DP->C instruction info
                            .CI       ( CTRL_INFO      ), //C->DP decoded control

                            //Hazard unit iface
                            .HZRD     ( if_hazard      ),
                          
                            //Coprocessor 0 interface
                            .CP0      ( if_cp0         ), 

                            //Exception controller interface
                            .EXC      ( if_except      ),
                  
                            //Memory interface
                            .MEM      ( if_memory      ),

                            //Debug interface
                            .DEBUG    ( if_debug       ));

coprocessor0 #(RAM_DEPTH) cp0  ( .CLK      ( CLK            ),
                                 .RESET    ( any_reset      ),
                                 .CP0      ( if_cp0         ),
                                 .EXC      ( if_except      ),
                                 .DEBUG    ( if_debug       ));


exceptions            excp_unit( .CLK      ( CLK            ),
                                 .RESET    ( any_reset      ),
                                 .EXC      ( if_except      ),
                                 .DEBUG    ( if_debug       ));


phy_mem #(RAM_DEPTH) phy_mem(CLK, any_reset, if_memory, IO);

jtag_stub      jtag(CLK, RESET, jtag_reset, if_debug );
          
endmodule
