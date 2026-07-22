#!/bin/bash

verilator --lint-only src/LSC.v &> lint_result.txt
                      
                    
iverilog -o lsc_sim \
            src/LSC.v \
            src/lsc_tb.v  &> sim_results.txt

vvp lsc_sim &> sim_results.txt