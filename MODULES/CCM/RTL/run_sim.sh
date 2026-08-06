#!/bin/bash

verilator --lint-only src/CCM.v &> lint_result.txt
                      
                    
iverilog -o ccm_sim \
            src/CCM.v \
            src/ccm_tb.v  &> sim_results.txt

vvp ccm_sim &> sim_results.txt