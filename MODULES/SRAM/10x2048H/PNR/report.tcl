file mkdir reports
set out_dir reports

report_checks -path_delay min_max -fields {slew cap input} > ${out_dir}/timing.rpt

report_worst_slack -min >> ${out_dir}/timing.rpt
report_worst_slack -max >> ${out_dir}/timing.rpt

report_check_types  -violators -max_slew -max_capacitance -max_fanout > ${out_dir}/violators.rpt

report_design_area_metrics > ${out_dir}/area.rpt
report_power > ${out_dir}/power.rpt