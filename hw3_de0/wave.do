onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/CLK
add wave -noupdate {/testbench/BTNS[0]}
add wave -noupdate /testbench/uut/reset
add wave -noupdate /testbench/uut/mcpu/if_except/RESET
add wave -noupdate /testbench/LEDS
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/inst_f
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/inst_stll_f
add wave -noupdate /testbench/uut/mcpu/if_hazard/ALUORMEM_E
add wave -noupdate /testbench/uut/mcpu/the_datapath/aluormem_e
add wave -noupdate /testbench/uut/mcpu/the_datapath/CI.ALUORMEM_WR
add wave -noupdate /testbench/uut/mcpu/if_hazard/STALL
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/pc_f
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/pc_d
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/pc_e
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/pc_m
add wave -noupdate -radix hexadecimal /testbench/uut/mcpu/the_datapath/pc_w
add wave -noupdate /testbench/uut/mcpu/the_datapath/ien_f
add wave -noupdate /testbench/uut/mcpu/the_datapath/ien_d
add wave -noupdate /testbench/uut/mcpu/the_datapath/ien_e
add wave -noupdate /testbench/uut/mcpu/the_datapath/ien_m
add wave -noupdate /testbench/uut/mcpu/the_datapath/ien_w
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal {/testbench/uut/mcpu/phy_mem/onchip_ram/RAM[0]}
add wave -noupdate -radix hexadecimal {/testbench/uut/mcpu/phy_mem/onchip_ram/RAM[1]}
add wave -noupdate -radix hexadecimal {/testbench/uut/mcpu/phy_mem/onchip_ram/RAM[2]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5450000 ps} 0}
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
WaveRestoreZoom {5647122 ps} {6159122 ps}
