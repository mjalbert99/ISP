set cts_buffers {CLKBUF_X1 \
                 CLKBUF_X2 \
                 CLKBUF_X3 \
                }

repair_clock_inverters

clock_tree_synthesis -buf_list $cts_buffers \
                     -repair_clock_nets

set_propagated_clock [all_clocks]


# repair_design -verbose
# repair_timing

detailed_placement -incremental

source report.tcl

write_def output/${TOP}_cts.def
puts "\[INFO\] CTS completed successfully. File generated: output/${TOP}_cts.def"