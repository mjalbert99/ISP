#!/bin/bash

verilator --lint-only src/fifo.v  &>  lint_result.txt
                      
                    
iverilog -o fifo_sim \
            src/fifo.v \
            src/fifo_tb.v &> sim_results.txt

vvp fifo_sim &> sim_results.txt