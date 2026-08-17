#!/bin/bash

verilator --lint-only src/C_CPU.v &> lint_result.txt
                                      
iverilog -o d_cpu_sim \
                src/C_CPU.v \
            ../../CCM/RTL/src/CCM.v \
            ../../GAM/RTL/src/GAM.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v   &> sim_results.txt

# vvp isp_sim &> sim_results.txt