#!/bin/bash

verilator --lint-only src/P_CPU.v &> lint_result.txt
                                      
iverilog -o p_cpu_sim \
                src/P_CPU.v \
            ../../BLC/RTL/src/BLC.v \
            ../../LSC/RTL/src/LSC.v \
            ../../DPC/RTL/src/DPC.v \
            ../../DPC/RTL/src/DPC_CORE.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v   &> sim_results.txt

# vvp isp_sim &> sim_results.txt