create_clock -period 3.0 -name clk0 [get_ports clk0]
create_clock -period 3.0 -name clk1 [get_ports clk1]

set_clock_uncertainty -setup 0.15 [get_clocks clk0]
set_clock_uncertainty -hold  0.05 [get_clocks clk0]

set_input_delay -clock clk0 -max 0.8 [get_ports [all_inputs] -filter "name != clk0"]
set_input_delay -clock clk0 -min 0.15 [get_ports [all_inputs] -filter "name != clk0"]

set_output_delay -clock clk0 -max 0.8 [get_ports [all_outputs]]
set_output_delay -clock clk0 -min 0.15 [get_ports [all_outputs]]

set_clock_uncertainty -setup 0.15 [get_clocks clk1]
set_clock_uncertainty -hold  0.05 [get_clocks clk1]

set_input_delay -clock clk1 -max 0.8 [get_ports [all_inputs] -filter "name != clk1"]
set_input_delay -clock clk1 -min 0.15 [get_ports [all_inputs] -filter "name != clk1"]

set_output_delay -clock clk1 -max 0.8 [get_ports [all_outputs]]
set_output_delay -clock clk1 -min 0.15 [get_ports [all_outputs]]

set_timing_derate -late  -cell 1.08
set_timing_derate -late  -net  1.08
set_timing_derate -early -cell 0.92
set_timing_derate -early -net  0.92
