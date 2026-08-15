#!/bin/bash

verilator --lint-only src/D_CPU.v &> lint_result.txt
                                      
iverilog -o d_cpu_sim \
                src/D_CPU.v \
            ../../BNR/RTL/src/BNR.v \
            ../../BNR/RTL/src/BNR_CORE.v \
            ../../BNR/RTL/src/RANGE_LUT.v \
            ../../WBG/RTL/src/WBG.v \
            ../../DEMOSAIC/RTL/src/DEMOSAIC.v \
            ../../DEMOSAIC/RTL/src/DEMOS_CORE.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v   &> sim_results.txt

# vvp isp_sim &> sim_results.txt