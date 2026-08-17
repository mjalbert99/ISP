#!/bin/bash

verilator --lint-only src/ISP.v &> lint_result.txt
                                      
iverilog -o isp_sim \
            src/ISP.v \
            ../MODULES/COLOR_CPU/RTL/src/C_CPU.v \
            ../MODULES/DIGITAL_CPU/RTL/src/D_CPU.v \
            ../MODULES/PHYSICAL_CPU/RTL/src/P_CPU.v \
            ../MODULES/BLC/RTL/src/BLC.v \
            ../MODULES/LSC/RTL/src/LSC.v \
            ../MODULES/DPC/RTL/src/DPC.v \
            ../MODULES/DPC/RTL/src/DPC_CORE.v \
            ../MODULES/BNR/RTL/src/BNR.v \
            ../MODULES/BNR/RTL/src/BNR_CORE.v \
            ../MODULES/BNR/RTL/src/RANGE_LUT.v \
            ../MODULES/WBG/RTL/src/WBG.v \
            ../MODULES/DEMOSAIC/RTL/src/DEMOSAIC.v \
            ../MODULES/DEMOSAIC/RTL/src/DEMOS_CORE.v \
            ../MODULES/CCM/RTL/src/CCM.v \
            ../MODULES/GAM/RTL/src/GAM.v \
            ../MODULES/SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../MODULES/SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../MODULES/SRAM/10x1024/RTL/src/sram.v   &> sim_results.txt

# vvp isp_sim &> sim_results.txt