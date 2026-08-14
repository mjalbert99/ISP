yosys -import
file mkdir output
set TOP SRAM10x2048

set WORKING_DIR "../RTL/"
set END_DIR "../SYNTH/"
set ABC_FILE "../constraints/abc_settings"

set SLW_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_slow.lib"
set TYP_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_typical.lib"
set FST_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_LIB "../../10x1024/PNR/metals/SRAM.lib"

cd ${WORKING_DIR}

set corners [list \
    "slow" $SLW_PDK_LIB $SRAM_LIB\
    "typ"  $TYP_PDK_LIB $SRAM_LIB\
    "fast" $FST_PDK_LIB $SRAM_LIB\
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

    abc -liberty $corner_lib -D 3000

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