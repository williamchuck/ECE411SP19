onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk -radix hexadecimal /urchin_tb/dut/cpu/clk
add wave -noupdate -radix decimal /urchin_tb/dut/cache/icache_core/miss_counter
add wave -noupdate -radix decimal /urchin_tb/dut/cache/dcache_core/miss_counter
add wave -noupdate -radix decimal /urchin_tb/dut/cpu/alu/multiplier/control_unit/executed_ins_count
add wave -noupdate /urchin_tb/dut/cpu/pipe1
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/PC/out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/pcmux_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/pcmux_sel
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/jump
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/buffer_jump
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs1_out_EX_sel
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs2_out_EX_sel
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/buffer_branch_target
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/branch_target
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alumux1_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alumux2_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/selected_rs1_EX_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs1_out_EX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/dmem_wdata_unshifted
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/selected_rs2_EX_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/selected_rs2_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs2_out_EX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/rs2_out_MEM
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_ready
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/ctw
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/ctwmux_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/ctw_EX
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/ctw_MEM
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/ctw_WB
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/aluop
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/a
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/b
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/f
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu_resp_
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/cmpop
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/arg1
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/arg2
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/cmp/br_en
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/Aval
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/Bval
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/opA
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/opB
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/multiplier/_opA
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/multiplier/_opB
add wave -noupdate /urchin_tb/dut/cpu/alu/multiplier/div
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/ready
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/alu/resp
add wave -noupdate /urchin_tb/dut/cpu/alu/multiplier/stall
add wave -noupdate /urchin_tb/dut/cpu/alu/multiplier/ready
add wave -noupdate /urchin_tb/dut/cpu/alu/multiplier/Run
add wave -noupdate /urchin_tb/dut/cpu/alu/multiplier/control_unit/curr_state
add wave -noupdate -radix hexadecimal -childformat {{{/urchin_tb/dut/cpu/regfile/data[0]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[1]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[2]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[3]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[4]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[5]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[6]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[7]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[8]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[9]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[10]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[11]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[12]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[13]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[14]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[15]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[16]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[17]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[18]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[19]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[20]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[21]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[22]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[23]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[24]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[25]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[26]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[27]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[28]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[29]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[30]} -radix hexadecimal} {{/urchin_tb/dut/cpu/regfile/data[31]} -radix hexadecimal}} -subitemconfig {{/urchin_tb/dut/cpu/regfile/data[0]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[1]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[2]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[3]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[4]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[5]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[6]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[7]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[8]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[9]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[10]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[11]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[12]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[13]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[14]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[15]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[16]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[17]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[18]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[19]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[20]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[21]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[22]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[23]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[24]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[25]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[26]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[27]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[28]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[29]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[30]} {-height 16 -radix hexadecimal} {/urchin_tb/dut/cpu/regfile/data[31]} {-height 16 -radix hexadecimal}} /urchin_tb/dut/cpu/regfile/data
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_resp
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_read
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_write
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_address
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/pmem_rdata
add wave -noupdate /urchin_tb/pm_error
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
add wave -noupdate /urchin_tb/dut/cache/icache_core/downstream_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cpu/br_en
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/stall
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/upstream_ready
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/downstream_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/downstream_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/downstream_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/way
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_core/datas
add wave -noupdate -radix hexadecimal {/urchin_tb/dut/cache/dcache_core/arrays/forloop[3]/line/data}
add wave -noupdate -radix hexadecimal {/urchin_tb/dut/cache/dcache_core/arrays/forloop[2]/line/data}
add wave -noupdate -radix hexadecimal {/urchin_tb/dut/cache/dcache_core/arrays/forloop[1]/line/data}
add wave -noupdate -radix hexadecimal {/urchin_tb/dut/cache/dcache_core/arrays/forloop[0]/line/data}
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_wdata_ACT
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dcache_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/dmem_wdata
add wave -noupdate /urchin_tb/dut/cpu/data_hazard_stall
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/control/wb_required
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/upstream_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/upstream_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/upstream_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/upstream_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/upstream_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/upstream_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_resp
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_rdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_wdata
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_address
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_write
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/hit
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/downstream_address_sel
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/arbiter/l2_icache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/arbiter/l2_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/arbiter/state
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/wb_reg/data
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/wb_reg/in
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/wb_reg/load
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/wb_reg/out
add wave -noupdate /urchin_tb/dut/cache/l2_cache_core/datapath/way
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/index_WB
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/index_
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/index
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/datas
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/datapath/inmux_out
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/cache_read
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/dirty
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/wb_required
add wave -noupdate -radix hexadecimal /urchin_tb/dut/cache/l2_cache_core/control/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {355135000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 399
configure wave -valuecolwidth 245
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
WaveRestoreZoom {354010025 ps} {355548111 ps}
