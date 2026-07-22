#!/bin/bash

                      
                    
iverilog -o sram_out src/sram.v src/SRAM_MEM.v &> sim_results.txt
