yosys -import
file mkdir output
set TOP ISP

set WORKING_DIR "../RTL/"
set END_DIR "../SYNTH/"
set ABC_FILE "../constraints/abc_settings"

set SLW_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_slow.lib"
set TYP_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_typical.lib"
set FST_PDK_LIB "/root/Work/vlsi/pdks/pdk/nangate45/libs/NangateOpenCellLibrary_fast.lib"

set SRAM_LIB "../MODULES/SRAM/10x2048V/PNR/metals/SRAM10x2048.lib"

set DPC_LIB   "../MODULES/DPC/PNR/metals/DPC.lib"
set BNR_LIB   "../MODULES/BNR/PNR/metals/BNR.lib"
set DEMOS_LIB "../MODULES/DEMOSAIC/PNR/metals/DEMOSAIC.lib"
set GAM_LIB   "../MODULES/GAM/PNR/metals/GAM.lib"

cd ${WORKING_DIR}

set corners [list \
    "slow" $SLW_PDK_LIB $SRAM_LIB $DPC_LIB $BNR_LIB $DEMOS_LIB $GAM_LIB\
    "typ"  $TYP_PDK_LIB $SRAM_LIB $DPC_LIB $BNR_LIB $DEMOS_LIB $GAM_LIB\
    "fast" $FST_PDK_LIB $SRAM_LIB $DPC_LIB $BNR_LIB $DEMOS_LIB $GAM_LIB\
]

foreach {corner_name corner_lib sram_lib dpc_lib bnr_lib demos_lib gam_lib} $corners {
    file mkdir ${END_DIR}/output/${corner_name}

    design -reset
    read_verilog src/ISP.v  ../MODULES/BLC/RTL/src/BLC.v ../MODULES/LSC/RTL/src/LSC.v ../MODULES/CCM/RTL/src/CCM.v ../MODULES/WBG/RTL/src/WBG.v

    read_liberty -lib $sram_lib
    read_liberty -lib $dpc_lib
    read_liberty -lib $bnr_lib
    read_liberty -lib $demos_lib
    read_liberty -lib $gam_lib

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
    read_liberty -lib -ignore_miss_dir $sram_lib
    tee -o ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_stat.txt \
        stat -liberty $corner_lib -liberty $sram_lib
}

cd ${END_DIR}