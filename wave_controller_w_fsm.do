# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns Hangman.v

# Load simulation using mux as the top level simulation module.
vsim controller

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}
force {clk} 0 0, 1 5 -r 10
force {resetn} 0 0, 1 10
force {letter1[5:0]} 100100
force {letter2[5:0]} 100110
force {letter3[5:0]} 111111
force {letter4[5:0]} 110000
force {guess[5:0]} 111111
force {go} 0
force {start_new_game} 0

force {go} 0
run 20ns

force {go} 1
run 300ns

force {clk} 0 0, 1 5 -r 10
force {guess[5:0]} 100110
force {go} 0
run 20ns

force {go} 1
run 300ns

force {clk} 0 0, 1 5 -r 10
force {guess[5:0]} 000001
force {go} 0
run 20ns

force {go} 1
run 300ns

force {clk} 0 0, 1 5 -r 10
force {guess[5:0]} 000001
force {go} 0
run 20ns

force {go} 1
run 300ns

force {clk} 0 0, 1 5 -r 10
force {guess[5:0]} 100100
force {go} 0
run 20ns

force {go} 1
run 300ns

force {clk} 0 0, 1 5 -r 10
force {guess[5:0]} 110000
force {go} 0
run 20ns

force {go} 1
run 300ns

force {clk} 0 0, 1 5 -r 10
force {guess[5:0]} 001001
force {go} 0
run 20ns

force {go} 1
run 300ns





