delete wave *
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/mul/Clk
add wave -noupdate -radix hexadecimal /testbench/mul/Run
add wave -noupdate -radix hexadecimal /testbench/mul/div
add wave -noupdate -radix hexadecimal /testbench/mul/ready
add wave -noupdate -radix decimal /testbench/mul/opA
add wave -noupdate -radix decimal /testbench/mul/opB
add wave -noupdate -radix decimal /testbench/mul/Aval
add wave -noupdate -radix decimal /testbench/mul/Bval
add wave -noupdate -radix decimal /testbench/multAns
add wave -noupdate /testbench/mul/control_unit/curr_state
add wave -noupdate -radix decimal /testbench/mul/control_unit/counter
add wave -noupdate -radix hexadecimal /testbench/mul/Sum
add wave -noupdate -radix hexadecimal /testbench/mul/X
add wave -noupdate -radix hexadecimal /testbench/mul/control_load
add wave -noupdate -radix hexadecimal /testbench/mul/control_shift
add wave -noupdate -radix hexadecimal /testbench/mul/control_subtract
add wave -noupdate -radix hexadecimal /testbench/mul/control_clearALoadB
add wave -noupdate -radix hexadecimal /testbench/mul/adder/outputEnable
add wave -noupdate /testbench/mul/control_unit/curr_state
add wave -noupdate -radix hexadecimal /testbench/mul/adder/internalSum
add wave -noupdate -radix hexadecimal /testbench/mul/adder/A
add wave -noupdate -radix hexadecimal /testbench/mul/adder/Switches
add wave -noupdate -radix hexadecimal /testbench/mul/adder/inA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64407 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 327
configure wave -valuecolwidth 170
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
WaveRestoreZoom {0 ps} {351554 ps}
restart -f
run 2us
