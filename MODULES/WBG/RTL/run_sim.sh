#!/bin/bash

verilator --lint-only src/WBG.v &> lint_result.txt

iverilog -o wbg_sim src/WBG.v src/wbg_tb.v &> sim_results.txt

vvp wbg_sim &> sim_results.txt