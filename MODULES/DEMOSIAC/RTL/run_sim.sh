#!/bin/bash

verilator --lint-only src/DEMOSIAC.v src/DEMOS_CORE.v &> lint_result.txt
                      
                    
iverilog -o demos_sim \
            src/DEMOSIAC.v \
            src/DEMOS_CORE.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v \
            src/demos_tb.v  &> sim_results.txt

# vvp demos_sim &> sim_results.txt
