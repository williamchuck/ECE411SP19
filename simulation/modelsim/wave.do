onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk -radix hexadecimal /urchin_tb/dut/cpu/clk
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_address_untruncated
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_wdata_unshifted
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/force_nop
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/br_en
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/PC/out
add wave -noupdate -label ctw -radix hexadecimal /urchin_tb/dut/cpu/ctw
add wave -noupdate -label ctw_EX -radix hexadecimal /urchin_tb/dut/cpu/ctw_EX
add wave -noupdate -label ctw_MEM -radix hexadecimal /urchin_tb/dut/cpu/ctw_MEM
add wave -noupdate -label ctw_WB -radix hexadecimal /urchin_tb/dut/cpu/ctw_WB
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/aluop
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/a
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/b
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/f
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/cmpop
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/arg1
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/arg2
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/br_en
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_output_transformer/dataout
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_output_transformer/line_data
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_output_transformer/offset
add wave -noupdate -radix hexadecimal -childformat {{{/urchin_tb/dut/cpu/regfile/data[0]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[1]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[2]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[3]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[4]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[5]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[6]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[7]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[8]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[9]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[10]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[11]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[12]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[13]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[14]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[15]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[16]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[17]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[18]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[19]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[20]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[21]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[22]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[23]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[24]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[25]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[26]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[27]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[28]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[29]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[30]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[31]} -radix hexadecimal}} -subitemconfig {{/urchin_tb/dut/cpu/regfile/data[0]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[1]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[2]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[3]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[4]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[5]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[6]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[7]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[8]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[9]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[10]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[11]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[12]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[13]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[14]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[15]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[16]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[17]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[18]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[19]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[20]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[21]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[22]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[23]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[24]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[25]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[26]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[27]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[28]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[29]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[30]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[31]} {-height 16 -radix hexadecimal}} /urchin_tb/dut/cpu/regfile/data
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_ready
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_stall
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/request_ACT
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/request_IDX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/force_nop
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/hit
add wave -noupdate -radix binary /urchin_tb/dut/cache/icache_core/equals
add wave -noupdate -radix binary /urchin_tb/dut/cache/icache_core/hits
add wave -noupdate -radix binary /urchin_tb/dut/cache/icache_core/valids
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/load_cache
add wave -noupdate -radix binary /urchin_tb/dut/cache/icache_core/way
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/index_ACT
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/index_IDX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/pipe
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/br_en
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/stall
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_ready
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdata
add wave -noupdate /urchin_tb/dut/cpu/data_hazard_stall
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52479237 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 464
configure wave -valuecolwidth 89
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
WaveRestoreZoom {52417963 ps} {52828121 ps}
