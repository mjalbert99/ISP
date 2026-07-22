create_clock -period 3.0 -name clk [get_ports clk]

set_clock_uncertainty -setup 0.15 [get_clocks clk]
set_clock_uncertainty -hold  0.05 [get_clocks clk]

set_false_path -from [get_ports resetn]

set_input_delay -clock clk -max 0.8 [get_ports [all_inputs] -filter "name != clk && name != resetn"]
set_input_delay -clock clk -min 0.15 [get_ports [all_inputs] -filter "name != clk && name != resetn"]

set_output_delay -clock clk -max 0.8 [get_ports [all_outputs]]
set_output_delay -clock clk -min 0.15 [get_ports [all_outputs]]

set_timing_derate -late  -cell 1.08
set_timing_derate -late  -net  1.08
set_timing_derate -early -cell 0.92
set_timing_derate -early -net  0.92
