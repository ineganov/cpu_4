onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/CLK
add wave -noupdate -format Logic /testbench/RESET
add wave -noupdate -format Literal -radix hexadecimal /testbench/leds
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /testbench/the_cpu/excp_unit/e_enter
add wave -noupdate -format Literal -radix unsigned /testbench/the_cpu/excp_unit/cause
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/excp_unit/epc
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/pc_f
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/pc_d
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/pc_e
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/pc_m
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/pc_w
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /testbench/the_cpu/if_hazard/STALL_FDE
add wave -noupdate -format Logic /testbench/the_cpu/if_hazard/STALL_M
add wave -noupdate -format Logic /testbench/the_cpu/if_hazard/RESET_M
add wave -noupdate -format Logic /testbench/the_cpu/if_hazard/RESET_W
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /testbench/the_cpu/the_datapath/mdiv_busy_m
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/muldiv_unit/HI
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/muldiv_unit/LO
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal /testbench/the_cpu/the_controller/I.FCODE
add wave -noupdate -format Literal /testbench/the_cpu/the_controller/I.OPCODE
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/inst_stll_f
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/inst_subs_f
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/inst_f
add wave -noupdate -format Literal -radix hexadecimal /testbench/the_cpu/the_datapath/inst_d
add wave -noupdate -format Logic /testbench/the_cpu/the_datapath/enable_inst_f
add wave -noupdate -format Logic /testbench/the_cpu/the_datapath/ien_f
add wave -noupdate -format Logic /testbench/the_cpu/the_datapath/br_take_e
add wave -noupdate -format Literal /testbench/the_cpu/the_datapath/next_pc_select
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {450000 ps} 0}
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
WaveRestoreZoom {15200 ps} {2063200 ps}
