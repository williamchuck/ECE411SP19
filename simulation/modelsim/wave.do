onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk -radix hexadecimal /urchin_tb/dut/cpu/clk
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/PC/out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/imem_address
add wave -noupdate /urchin_tb/dut/cpu/alumux2_sel
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rd_MEM
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rd_WB
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs1_EX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs2_EX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/a
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/b
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/f
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/regfile/data
add wave -noupdate -label ctw -radix hexadecimal /urchin_tb/dut/cpu/ctw
add wave -noupdate -label ctwmux_out -radix hexadecimal /urchin_tb/dut/cpu/ctwmux_out
add wave -noupdate -label ctw_EX -radix hexadecimal /urchin_tb/dut/cpu/ctw_EX
add wave -noupdate -label ctw_MEM -radix hexadecimal /urchin_tb/dut/cpu/ctw_MEM
add wave -noupdate -label ctw_WB -radix hexadecimal /urchin_tb/dut/cpu/ctw_WB
add wave -noupdate -label stall -radix hexadecimal /urchin_tb/dut/cpu/stall
add wave -noupdate -label no_mem -radix hexadecimal /urchin_tb/dut/cpu/no_mem
add wave -noupdate /urchin_tb/dut/cpu/fresh_IF
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_hit
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_byte_enable
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_offset
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdatamux_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_rdatamux_out_prev
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/imem_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/control/next_state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/control/state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/icache_core/datapath/index
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_hit
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_byte_enable
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_offset
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdatamux_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdatamux_out_prev
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
WaveRestoreCursors {{Cursor 1} {35000 ps} 0}
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
WaveRestoreZoom {0 ps} {1312500 ps}
