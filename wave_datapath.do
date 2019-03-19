# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns Hangman.v

# Load simulation using mux as the top level simulation module.
vsim datapath

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {clk} 0 0, 1 5 -r 10
force {resetn} 0 0, 1 10

force {enable_l1} 1 
force {enable_l2} 0
force {enable_l3} 1
force {enable_l4} 0
force {enable_l5} 0

force {enable_l1} 1
force {enable_l2} 1
force {enable_l3} 1
force {enable_l4} 0
force {enable_l5} 0

force {enable_l1} 0
force {enable_l2} 0
force {enable_l3} 0
force {enable_l4} 0
force {enable_l5} 0

force {enable_l1} 1
force {enable_l2} 1
force {enable_l3} 1
force {enable_l4} 1
force {enable_l5} 1
run 300ns
