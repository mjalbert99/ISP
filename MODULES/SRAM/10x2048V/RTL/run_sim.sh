#!/bin/bash

                      
                    
iverilog -o sram_out ../../10x1024/RTL/src/SRAM_MEM.v ../../10x1024/RTL/src/sram.v src/SRAM_MEM.v &> sim_results.txt
