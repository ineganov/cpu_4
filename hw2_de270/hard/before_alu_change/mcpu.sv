module mcpu(  input        CLK,
              input        RESET,
              input        RUN,
              output [7:0] LEDS );
              
            

def::c_inst INST_INFO; //instruction decoder input
def::ctrl   CTRL_INFO; //instruction decoder output

if_hazard  if_hazard();  //hazard unit interface
if_except  if_except();  //exceptions interface
if_cp0     if_cp0();     //coprocessor0 interface
if_memory  if_memory();  //memory interface

controller the_controller ( INST_INFO, CTRL_INFO );

hazard_unit the_hazard_unit( if_hazard );

datapath     the_datapath ( .CLK            ( CLK            ),
                            .RUN            ( RUN            ),
                                  
                            //Controller iface
                            .INST_O         ( INST_INFO      ), //DP->C instruction info
                            .CI             ( CTRL_INFO      ), //C->DP decoded control

                            //Hazard unit iface
                            .HZRD      ( if_hazard      ),
                          
                            //Coprocessor 0 interface
                            .CP0         ( if_cp0         ), 

                            //Exception controller interface
                            .EXC      ( if_except      ),
                  
                            //Memory interface
                            .MEM      ( if_memory      ));

coprocessor0         cp0  ( .CLK      ( CLK            ),
                            .RESET    ( RESET          ),
                            .RUN      ( RUN            ),
                            .CP0      ( if_cp0         ),
                            .EXC      ( if_except      ));


exceptions       excp_unit( .CLK      ( CLK            ),
                            .RESET    ( RESET          ),
                            .EXC      ( if_except      ));


phy_mem          phy_mem(CLK, RESET, LEDS, if_memory);
          
endmodule
