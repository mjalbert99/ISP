#!/bin/bash

verilator --lint-only src/GAM.v  &> lint_result.txt
                      
                    
iverilog -o gam_sim \
            src/GAM.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v \
            src/gam_tb.v  &> sim_results.txt

vvp gam_sim &> sim_results.txt
