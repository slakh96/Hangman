# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns Hangman.v

# Load simulation using mux as the top level simulation module.
vsim control_letter

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {clk} 0 0, 1 5 -r 10
force {resetn} 0 0, 1 10
force {go} 0 0, 1 10 -r 20

force {letter1[4:0]} 10010
force {letter2[4:0]} 10011
force {letter3[4:0]} 00000
force {letter4[4:0]} 11000
force {letter5[4:0]} 11111

force {guess[4:0]} 00000

run 300ns
