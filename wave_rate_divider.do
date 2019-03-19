# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns rate_divider.v

# Load simulation using mux as the top level simulation module.
vsim rate_divider

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#Note: Can model the tests after the ratedivider lab's tests

force {clock} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 2
force {toggle_enable_for_hex_counter} 1
force {d[27:0]} 10111110101111000010000000
run 200ns
