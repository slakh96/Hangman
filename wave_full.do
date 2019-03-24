# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns Hangman.v

# Load simulation using mux as the top level simulation module.
vsim Hangman

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {CLOCK_50} 0 0, 1 5 -r 10
force {SW[9]} 0 0, 1 10

force {SW[5:0]} 6'h1C


force {KEY[3]} 0
run 10ns
force {KEY[3]} 1


run 300ns

force {CLOCK_50} 0 0, 1 5 -r 10
force {SW[5:0]} 000001


force {KEY[3]} 0
run 10ns
force {KEY[3]} 1


run 300ns

force {CLOCK_50} 0 0, 1 5 -r 10
force {SW[5:0]} 6'hA


force {KEY[3]} 0
run 10ns
force {KEY[3]} 1


run 300ns