set TOP "ISP"
set SDC_FILE "../constraints/isp.sdc"

# Updated list: includes corner_name, std_cell_lib, and sram_lib
# Removed the "typ" corner.
# Make sure to update the SRAM paths to match exactly where your OpenRAM files are saved!
set corners [list \
    "slow"\
    "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_slow.lib" \
    "../MODULES/PHYSICAL_CPU/PNR/metals/P_CPU.lib" \
    "../MODULES/DIGITAL_CPU/PNR/metals/D_CPU.lib" \
    "../MODULES/COLOR_CPU/PNR/metals/C_CPU.lib" \
    "typ"\
    "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_typical.lib" \
    "../MODULES/PHYSICAL_CPU/PNR/metals/P_CPU.lib" \
    "../MODULES/DIGITAL_CPU/PNR/metals/D_CPU.lib" \
    "../MODULES/COLOR_CPU/PNR/metals/C_CPU.lib" \
    "fast" \
    "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_fast.lib" \
    "../MODULES/PHYSICAL_CPU/PNR/metals/P_CPU.lib" \
    "../MODULES/DIGITAL_CPU/PNR/metals/D_CPU.lib" \
    "../MODULES/COLOR_CPU/PNR/metals/C_CPU.lib" \
]

foreach {corner_name std_lib p_lib d_lib c_lib} $corners {
    set out_dir "output/${corner_name}"

    puts "\n================================================================"
    puts " Corner : $corner_name"
    puts "================================================================\n"

    # 1. Read the standard cell library
    read_liberty $std_lib
    read_liberty $p_lib
    read_liberty $d_lib
    read_liberty $c_lib
    

    
    read_verilog  output/${corner_name}/${TOP}_${corner_name}_netlist.v
    link_design   $TOP
    read_sdc      $SDC_FILE

    
    report_checks \
        -path_delay max \
        -fields     {slew cap input_pins fanout} \
        -format     full_clock_expanded \
        -no_line_splits \
        > ${out_dir}/setup_timing.rpt


    report_checks \
        -path_delay min \
        -fields     {slew cap input_pins fanout} \
        -format     full_clock_expanded \
        -no_line_splits \
        > ${out_dir}/hold_timing.rpt


    report_wns -digits 4 > ${out_dir}/wns.rpt
    report_tns -digits 4 > ${out_dir}/tns.rpt


    report_check_types \
        -max_slew \
        -violators \
        > ${out_dir}/slew_drv.rpt

    report_check_types \
        -max_capacitance \
        -violators \
        > ${out_dir}/cap_drv.rpt

    report_check_types \
        -max_fanout \
        -violators \
        > ${out_dir}/fanout_drv.rpt

    puts "  Done — reports in ${out_dir}/"
}
exit