onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /urchin_tb/clk
add wave -noupdate -label cpu_state /urchin_tb/dut/cpu/control/state
add wave -noupdate -label dcache_state /urchin_tb/dut/cache/dcache_core/control/state
add wave -noupdate -label L2_state /urchin_tb/dut/cache/l2_cache_core/control/state
add wave -noupdate -label dmem_resp /urchin_tb/dut/cache/dmem_resp
add wave -noupdate -label imem_resp /urchin_tb/dut/cache/imem_resp
add wave -noupdate -label pmem_resp /urchin_tb/dut/cache/pmem_resp
add wave -noupdate -label L2_resp /urchin_tb/dut/cache/l2_resp
add wave -noupdate -label L2_icache_resp /urchin_tb/dut/cache/l2_icache_resp
add wave -noupdate -label L2_dcache_resp /urchin_tb/dut/cache/l2_dcache_resp
add wave -noupdate -label lru /urchin_tb/dut/cache/dcache_core/datapath/lru
add wave -noupdate -label new_lru /urchin_tb/dut/cache/dcache_core/datapath/new_lru
add wave -noupdate -label way /urchin_tb/dut/cache/dcache_core/datapath/way
add wave -noupdate -label index /urchin_tb/dut/cache/dcache_core/datapath/index
add wave -noupdate -label dmem_rdatamux_out -radix hexadecimal /urchin_tb/dut/cache/dmem_rdatamux_out
add wave -noupdate -label dmem_rdata -radix hexadecimal /urchin_tb/dut/cache/dmem_rdata
add wave -noupdate -label dmem_address -radix hexadecimal /urchin_tb/dut/cache/dmem_address
add wave -noupdate -label dcache_rdata -radix hexadecimal /urchin_tb/dut/cache/dcache_rdata
add wave -noupdate -label L2_rdata -radix hexadecimal /urchin_tb/dut/cache/l2_rdata
add wave -noupdate -label pmem_rdata -radix hexadecimal /urchin_tb/dut/cache/pmem_rdata
add wave -noupdate -label mem_rdata -radix hexadecimal /urchin_tb/dut/cpu/mem_rdata
add wave -noupdate -label mem_resp /urchin_tb/dut/cpu/mem_resp
add wave -noupdate -label IR -radix hexadecimal /urchin_tb/dut/cpu/datapath/IR/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {504402620 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 211
configure wave -valuecolwidth 455
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
WaveRestoreZoom {504221667 ps} {504488334 ps}
