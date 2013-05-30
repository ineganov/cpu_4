## Generated SDC file "toplevel.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.0 Build 263 08/02/2012 Service Pack 2 SJ Web Edition"

## DATE    "Sun May 19 11:10:47 2013"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

#create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLK} -period 11.111 [get_ports {CLK}]
create_clock -name {JTAG_EN} -period 1000.000 -waveform { 0.000 500.000 } [get_keepers {sld_hub:auto_hub|node_ena[1]~reg0}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {CLK_CPU} -source [get_ports {CLK}] -master_clock {CLK} [get_nets {pll|altpll_component|auto_generated|wire_pll1_clk[0]}] 
create_generated_clock -name {CLK_IO} -source [get_ports {CLK}] -divide_by 50 -master_clock {CLK} [get_nets {pll|altpll_component|auto_generated|wire_pll1_clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path  -from  [get_clocks {JTAG_EN}]  -to  [get_clocks {CLK_CPU CLK_IO}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

