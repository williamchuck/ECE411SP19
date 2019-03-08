onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /urchin_tb/clk
add wave -noupdate -label IR -radix hexadecimal /urchin_tb/cpu/ir/data
add wave -noupdate -label PC -radix hexadecimal /urchin_tb/cpu/PC/data
add wave -noupdate -label opcode /urchin_tb/cpu/opcode
add wave -noupdate -label ctw /urchin_tb/cpu/control/ctw
add wave -noupdate -label ctw_EX /urchin_tb/cpu/ctw_EX
add wave -noupdate -label ctw_MEM /urchin_tb/cpu/ctw_MEM
add wave -noupdate -label ctw_WB /urchin_tb/cpu/ctw_WB
add wave -noupdate -label reg_back -radix hexadecimal /urchin_tb/cpu/reg_back
add wave -noupdate -label r1 -radix hexadecimal {/urchin_tb/cpu/regfile/data[1]}
add wave -noupdate -label r2 -radix hexadecimal {/urchin_tb/cpu/regfile/data[2]}
add wave -noupdate -label r3 -radix hexadecimal {/urchin_tb/cpu/regfile/data[3]}
add wave -noupdate -label rs1 /urchin_tb/cpu/rs1
add wave -noupdate -label rs1_EX /urchin_tb/cpu/rs1_EX
add wave -noupdate -label rs1_out -radix hexadecimal /urchin_tb/cpu/rs1_out
add wave -noupdate -label rs1_out_EX -radix hexadecimal /urchin_tb/cpu/rs1_out_EX
add wave -noupdate -label rs2 /urchin_tb/cpu/rs2
add wave -noupdate -label rs2_EX /urchin_tb/cpu/rs2_EX
add wave -noupdate -label rs2_out -radix hexadecimal /urchin_tb/cpu/rs2_out
add wave -noupdate -label rs2_out_EX -radix hexadecimal /urchin_tb/cpu/rs2_out_EX
add wave -noupdate -label rs2_out_MEM -radix hexadecimal /urchin_tb/cpu/rs2_out_MEM
add wave -noupdate -label rd /urchin_tb/cpu/rd
add wave -noupdate -label rd_EX /urchin_tb/cpu/rd_EX
add wave -noupdate -label rd_MEM /urchin_tb/cpu/rd_MEM
add wave -noupdate -label rd_WB /urchin_tb/cpu/rd_WB
add wave -noupdate -label stall /urchin_tb/cpu/stall
add wave -noupdate -label alumux1_sel /urchin_tb/cpu/alumux1_sel
add wave -noupdate -label alumux2_sel /urchin_tb/cpu/alumux2_sel
add wave -noupdate -label alu_A -radix hexadecimal /urchin_tb/cpu/alu/a
add wave -noupdate -label alu_B -radix hexadecimal /urchin_tb/cpu/alu/b
add wave -noupdate -label alu_out -radix hexadecimal -childformat {{{/urchin_tb/cpu/alu/f[31]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[30]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[29]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[28]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[27]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[26]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[25]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[24]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[23]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[22]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[21]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[20]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[19]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[18]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[17]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[16]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[15]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[14]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[13]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[12]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[11]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[10]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[9]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[8]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[7]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[6]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[5]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[4]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[3]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[2]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[1]} -radix hexadecimal} {{/urchin_tb/cpu/alu/f[0]} -radix hexadecimal}} -subitemconfig {{/urchin_tb/cpu/alu/f[31]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[30]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[29]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[28]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[27]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[26]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[25]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[24]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[23]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[22]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[21]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[20]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[19]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[18]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[17]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[16]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[15]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[14]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[13]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[12]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[11]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[10]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[9]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[8]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[7]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[6]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[5]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[4]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[3]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[2]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[1]} {-height 16 -radix hexadecimal} {/urchin_tb/cpu/alu/f[0]} {-height 16 -radix hexadecimal}} /urchin_tb/cpu/alu/f
add wave -noupdate -label aluop /urchin_tb/cpu/alu/aluop
add wave -noupdate -label alu_out_MEM -radix hexadecimal /urchin_tb/cpu/alu_out_MEM
add wave -noupdate -label no_mem /urchin_tb/cpu/no_mem
add wave -noupdate -label imem_read /urchin_tb/mem/imem_read
add wave -noupdate -label imem_write /urchin_tb/mem/imem_write
add wave -noupdate -label imem_byte_enable /urchin_tb/mem/imem_byte_enable
add wave -noupdate -label imem_address -radix hexadecimal /urchin_tb/mem/imem_address
add wave -noupdate -label imem_wdata -radix hexadecimal /urchin_tb/mem/imem_wdata
add wave -noupdate -label imem_resp /urchin_tb/mem/imem_resp
add wave -noupdate -label imem_rdata -radix hexadecimal /urchin_tb/mem/imem_rdata
add wave -noupdate -label dmem_read /urchin_tb/mem/dmem_read
add wave -noupdate -label dmem_resp /urchin_tb/mem/dmem_resp
add wave -noupdate -label dmem_rdata -radix hexadecimal /urchin_tb/mem/dmem_rdata
add wave -noupdate -label dmem_write /urchin_tb/mem/dmem_write
add wave -noupdate -label dmem_byte_enable /urchin_tb/mem/dmem_byte_enable
add wave -noupdate -label dmem_address -radix hexadecimal /urchin_tb/mem/dmem_address
add wave -noupdate -label dmem_wdata -radix hexadecimal /urchin_tb/mem/dmem_wdata
add wave -noupdate -label cpu_dmem_rdata -radix hexadecimal /urchin_tb/cpu/dmem_rdata
add wave -noupdate -label dmem_rdata_WB -radix hexadecimal /urchin_tb/cpu/dmem_rdata_WB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {870438 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {721059 ps} {1063023 ps}
