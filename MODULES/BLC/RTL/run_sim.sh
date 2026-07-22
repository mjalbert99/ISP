#!/bin/bash

verilator --lint-only src/BLC.v &> lint_result.txt
                      
                    
iverilog -o blc_sim \
            src/BLC.v \
            src/blc_tb.v  &> sim_results.txt

vvp blc_sim &> sim_results.txt