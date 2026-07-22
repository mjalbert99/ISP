yosys -import
file mkdir output
set TOP SRAM

set WORKING_DIR "../RTL/"
set END_DIR "../SYNTH/"
set ABC_FILE "../constraints/abc_settings"

set SLW_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_slow.lib"
set TYP_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_typical.lib"
set FST_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_fast.lib"

set SLW_SRAM_LIB "/root/Work/vlsi/pdks/pdk/nangate45/sram_10x1024/sram_10x1024_SS_0p95V_125C.lib"
set TYP_SRAM_LIB "/root/Work/vlsi/pdks/pdk/nangate45/sram_10x1024/sram_10x1024_TT_1p1V_25C.lib"
set FST_SRAM_LIB "/root/Work/vlsi/pdks/pdk/nangate45/sram_10x1024/sram_10x1024_FF_1p25V_0C.lib"

cd ${WORKING_DIR}

set corners [list \
    "slow" $SLW_PDK_LIB $SLW_SRAM_LIB\
    "typ"  $TYP_PDK_LIB $TYP_SRAM_LIB\
    "fast" $FST_PDK_LIB $FST_SRAM_LIB\
]

foreach {corner_name corner_lib sram_lib} $corners {
    file mkdir ${END_DIR}/output/${corner_name}

    design -reset
    read_verilog src/SRAM_MEM.v

    read_liberty -lib $sram_lib

    hierarchy -check -top $TOP

    synth -top $TOP -flatten

    fsm
    memory_map
    opt -full

    dfflibmap -liberty $corner_lib
    opt_clean -purge

    abc -liberty $corner_lib -D 3000 -clk clk0 clk1

    hilomap -hicell LOGIC1_X1 Z -locell LOGIC0_X1 Z

    opt -full
    opt_clean -purge
    clean -purge

    write_verilog ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_netlist.v

    read_liberty -lib -ignore_miss_dir $corner_lib
    read_liberty -lib -ignore_miss_dir $sram_lib
    tee -o ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_stat.txt \
        stat -liberty $corner_lib -liberty $sram_lib
}

cd ${END_DIR}