onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk -radix hexadecimal /urchin_tb/dut/cpu/clk
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/PC/out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rd_MEM
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rd_WB
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs1_EX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs2_EX
add wave -noupdate -label ctw -radix hexadecimal /urchin_tb/dut/cpu/ctw
add wave -noupdate -label ctwmux_out -radix hexadecimal /urchin_tb/dut/cpu/ctwmux_out
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
add wave -noupdate -radix hexadecimal -childformat {{{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[7]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[6]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[5]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[4]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[3]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[2]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[1]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[0]} -radix hexadecimal}} -subitemconfig {{/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[7]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[6]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[5]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[4]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[3]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[2]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[1]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data[0]} {-height 16 -radix hexadecimal}} {/urchin_tb/dut/cache/dcache_core/datapath/arrays/forloop[0]/line/data}
add wave -noupdate -radix hexadecimal -childformat {{{/urchin_tb/dut/cache/dcache_core/datapath/datas[0]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/datas[1]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/datas[2]} -radix hexadecimal} {{/urchin_tb/dut/cache/dcache_core/datapath/datas[3]} -radix hexadecimal}} -subitemconfig {{/urchin_tb/dut/cache/dcache_core/datapath/datas[0]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/datas[1]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/datas[2]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cache/dcache_core/datapath/datas[3]} {-height 16 -radix hexadecimal}} /urchin_tb/dut/cache/dcache_core/datapath/datas
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/datapath/upstream_rdata
add wave -noupdate -radix hexadecimal -childformat {{{/urchin_tb/dut/cpu/regfile/data[0]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[1]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[2]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[3]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[4]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[5]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[6]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[7]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[8]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[9]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[10]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[11]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[12]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[13]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[14]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[15]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[16]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[17]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[18]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[19]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[20]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[21]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[22]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[23]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[24]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[25]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[26]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[27]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[28]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[29]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[30]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[31]} -radix hexadecimal}} -expand -subitemconfig {{/urchin_tb/dut/cpu/regfile/data[0]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[1]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[2]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[3]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[4]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[5]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[6]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[7]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[8]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[9]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[10]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[11]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[12]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[13]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[14]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[15]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[16]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[17]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[18]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[19]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[20]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[21]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[22]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[23]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[24]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[25]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[26]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[27]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[28]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[29]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[30]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[31]} {-height 16 -radix hexadecimal}} /urchin_tb/dut/cpu/regfile/data
add wave -noupdate -label stall -radix hexadecimal /urchin_tb/dut/cpu/stall
add wave -noupdate -label no_mem -radix hexadecimal /urchin_tb/dut/cpu/no_mem
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/select
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/pc
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/permit
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/_select
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_blocking_unit/_pc
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_hit
add wave -noupdate /urchin_tb/dut/cache/icache_core/datapath/hits
add wave -noupdate /urchin_tb/dut/cache/icache_valid
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/datapath/_address_
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_byte_enable
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_offset
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/control/next_state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/control/state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/datapath/index
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_hit
add wave -noupdate /urchin_tb/dut/cache/dcache_valid
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_byte_enable
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_offset
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/datapath/index
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/control/next_state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/control/state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_hit
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_write
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_icache_read
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_icache_write
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_icache_address
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_icache_wdata
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_icache_resp
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_icache_rdata
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_dcache_read
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_dcache_write
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_dcache_address
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_dcache_wdata
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_dcache_resp
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_dcache_rdata
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_resp
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_rdata
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_read
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_write
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_address
add wave -noupdate /urchin_tb/dut/cache/arbiter/l2_wdata
add wave -noupdate /urchin_tb/dut/cache/arbiter/rdata_buffer_out
add wave -noupdate /urchin_tb/dut/cache/arbiter/pending_resp
add wave -noupdate /urchin_tb/dut/cache/arbiter/next_pending_resp
add wave -noupdate /urchin_tb/dut/cache/arbiter/state
add wave -noupdate /urchin_tb/dut/cache/arbiter/next_state
add wave -noupdate /urchin_tb/dut/cache/arbiter/icache_sel
add wave -noupdate /urchin_tb/dut/cache/arbiter/dcache_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1034820 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 424
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
WaveRestoreZoom {490210 ps} {1802710 ps}
