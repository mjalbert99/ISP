#!/bin/bash

verilator --lint-only src/BNR.v src/BNR_CORE.v src/RANGE_LUT.v &> lint_result.txt
                      
                    
iverilog -o bnr_sim \
            src/BNR.v \
            src/BNR_CORE.v \
            src/RANGE_LUT.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v \
            src/bnr_tb.v  &> sim_results.txt

vvp bnr_sim &> sim_results.txt
