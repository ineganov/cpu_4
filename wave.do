onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/CLK
add wave -noupdate /testbench/RESET
add wave -noupdate /testbench/LEDS
add wave -noupdate -divider <NULL>
add wave -noupdate /testbench/mcpu/excp_unit/e_enter
add wave -noupdate -radix unsigned /testbench/mcpu/cp0/cause_q
add wave -noupdate -radix hexadecimal /testbench/mcpu/if_except/EPC_Q
add wave -noupdate -radix hexadecimal /testbench/mcpu/cp0/badvaddr_q
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/next_pc
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/pc_f
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/pc_d
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/pc_e
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/pc_m
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/pc_w
add wave -noupdate /testbench/mcpu/the_hazard_unit/LW_STALL
add wave -noupdate -divider <NULL>
add wave -noupdate /testbench/mcpu/the_datapath/ien_f
add wave -noupdate /testbench/mcpu/the_datapath/ien_d
add wave -noupdate /testbench/mcpu/the_datapath/ien_e
add wave -noupdate /testbench/mcpu/the_datapath/ien_m
add wave -noupdate /testbench/mcpu/the_datapath/ien_w
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /testbench/mcpu/the_datapath/rf_unit/RD_ADDR_1
add wave -noupdate -radix unsigned /testbench/mcpu/the_datapath/rf_unit/RD_ADDR_2
add wave -noupdate -radix unsigned /testbench/mcpu/the_datapath/rf_unit/WR_ADDR_3
add wave -noupdate /testbench/mcpu/the_datapath/rf_unit/WE
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/rf_unit/W_DATA
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/rf_unit/R_DATA_1
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/rf_unit/R_DATA_2
add wave -noupdate -divider <NULL>
add wave -noupdate /testbench/mcpu/if_hazard/ALU_FWD_A
add wave -noupdate /testbench/mcpu/if_hazard/ALU_FWD_B
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/src_a_e
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/src_b_e
add wave -noupdate -radix hexadecimal /testbench/mcpu/the_datapath/aluout_e
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[31]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[30]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[29]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[28]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[27]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[26]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[25]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[24]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[23]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[22]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[21]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[20]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[19]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[18]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[17]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[16]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[15]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[14]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[13]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[12]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[11]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[10]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[9]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[8]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[7]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[6]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[5]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[4]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[3]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[2]}
add wave -noupdate -radix hexadecimal {/testbench/mcpu/the_datapath/rf_unit/rf_memory/rf[1]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1770000 ps} 0} {{Cursor 2} {1870000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {1605455 ps} {2149655 ps}
