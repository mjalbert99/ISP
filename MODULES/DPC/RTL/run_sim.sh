#!/bin/bash

verilator --lint-only src/DPC.v src/DPC_CORE.v &> lint_result.txt
                                      
iverilog -o dpc_sim \
            src/DPC.v \
            src/DPC_CORE.v \
            ../../SRAM/10x2048/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/SRAM_MEM.v \
            ../../SRAM/10x1024/RTL/src/sram.v \
            src/dpc_tb.v  &> sim_results.txt

vvp dpc_sim &> sim_results.txt