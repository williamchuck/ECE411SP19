onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /urchin_tb/mem/dmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/mem/dmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/mem/dmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/mem/imem_address
add wave -noupdate -radix hexadecimal /urchin_tb/mem/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/PC/out
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/regfile/data
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/cmpmux_out
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/ctw
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/ctw_EX
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/ctw_MEM
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/ctw_WB
add wave -noupdate -radix hexadecimal /urchin_tb/cpu/ctwmux_out
add wave -noupdate -radix hexadecimal -childformat {{{/urchin_tb/cpu/regfile/data[0]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[1]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[2]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[3]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[4]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[5]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[6]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[7]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[8]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[9]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[10]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[11]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[12]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[13]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[14]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[15]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[16]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[17]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[18]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[19]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[20]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[21]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[22]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[23]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[24]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[25]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[26]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[27]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[28]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[29]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[30]} -radix hexadecimal} {{/urchin_tb/cpu/regfile/data[31]} -radix hexadecimal}} -expand -subitemconfig {{/urchin_tb/cpu/regfile/data[0]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[1]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[2]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[3]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[4]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[5]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[6]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[7]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[8]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[9]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[10]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[11]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[12]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[13]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[14]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[15]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[16]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[17]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[18]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[19]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[20]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[21]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[22]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[23]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[24]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[25]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[26]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[27]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[28]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[29]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[30]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/regfile/data[31]} {-height 16 -radix hexadecimal}} /urchin_tb/cpu/regfile/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 445
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {932546 ps}
