yosys -import
file mkdir output
set TOP P_CPU

set WORKING_DIR "../RTL/"
set END_DIR "../SYNTH/"
set ABC_FILE "../constraints/abc_settings"

set SLW_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_slow.lib"
set TYP_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_typical.lib"
set FST_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_fast.lib"

set DPC_LIB "../../DPC/PNR/metals/DPC.lib"
set LSC_LIB "../../LSC/PNR/metals/LSC.lib"
set BLC_LIB "../../BLC/PNR/metals/BLC.lib"

cd ${WORKING_DIR}

set corners [list \
    "slow" $SLW_PDK_LIB $DPC_LIB $LSC_LIB $BLC_LIB\
    "typ"  $TYP_PDK_LIB $DPC_LIB $LSC_LIB $BLC_LIB\
    "fast" $FST_PDK_LIB $DPC_LIB $LSC_LIB $BLC_LIB\
]

foreach {corner_name corner_lib dpc_lib lsc_lib blc_lib} $corners {
    file mkdir ${END_DIR}/output/${corner_name}

    design -reset
    read_verilog src/P_CPU.v

    read_liberty -lib $dpc_lib
    read_liberty -lib $lsc_lib
    read_liberty -lib $blc_lib

    hierarchy -check -top $TOP

    synth -top $TOP -flatten

    fsm
    memory_map
    # opt -full

    dfflibmap -liberty $corner_lib
    # opt_clean -purge

    abc -liberty $corner_lib -D 3000 -clk clk

    hilomap -hicell LOGIC1_X1 Z -locell LOGIC0_X1 Z

    # opt -full
    # opt_clean -purge
    # clean -purge

    write_verilog ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_netlist.v

    read_liberty -lib -ignore_miss_dir $corner_lib

    tee -o ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_stat.txt \
        stat -liberty $corner_lib
}

cd ${END_DIR}