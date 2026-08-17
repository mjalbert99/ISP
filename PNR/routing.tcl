set_routing_layers -signal metal2-metal8
set_routing_layers -clock metal5-metal8

global_route -verbose

detailed_placement

detailed_route -output_drc reports/5_route_drc.rpt -verbose 1

repair_antennas
check_antennas


report_design_area

filler_placement -prefix FILLER_ {FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32}

source report.tcl

write_def output/${TOP}_routed.def
puts "\[INFO\] Routing completed successfully. File generated: output/${TOP}_routed.def"

