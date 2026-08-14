set TOP "SRAM10x2048"
set SDC_FILE "../constraints/sram.sdc"


set corners [list \
    "slow"\
    "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_slow.lib" \
    "../../10x1024/PNR/metals/SRAM.lib" \
    "typ"\
    "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_typical.lib" \
    "../../10x1024/PNR/metals/SRAM.lib" \
    "fast" \
    "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_fast.lib" \
    "../../10x1024/PNR/metals/SRAM.lib" \
]

foreach {corner_name std_lib sram_lib} $corners {
    set out_dir "output/${corner_name}"

    puts "\n================================================================"
    puts " Corner : $corner_name"
    puts "================================================================\n"

    # 1. Read the standard cell library
    read_liberty $std_lib
    
    # 2. Read the SRAM macro library for this specific corner
    read_liberty $sram_lib
    
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