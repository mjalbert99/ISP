set_layer_rc -layer metal1 -resistance 5.4286e-03  -capacitance 7.41819E-02
set_layer_rc -layer metal2 -resistance 3.70635E-03 -capacitance 8.33611E-02
set_layer_rc -layer metal3 -resistance 3.57728E-03 -capacitance 1.03981E-01
set_layer_rc -layer metal4 -resistance 1.47397E-03 -capacitance 1.19150E-01
set_layer_rc -layer metal5 -resistance 1.49065E-03 -capacitance 1.09256E-01
set_layer_rc -layer metal6 -resistance 1.50265E-03 -capacitance 1.14168E-01

set_wire_rc -signal -layer metal3
set_wire_rc -clock  -layer metal5

set_dont_use {*BUF_X1 *BUF_X2 *INV_X1 *INV_X2 *CLKBUF_X1 *CLKBUF_X2}

global_placement -incremental -routability_driven

set_placement_padding -global -left 5 -right 5

detailed_placement -incremental
# estimate_parasitics -placement
repair_design -verbose
repair_timing


write_def output/${TOP}_placed.def
puts "\[INFO\] Placement completed successfully. File generated: output/${TOP}_placed.def"