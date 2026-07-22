
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "BNR.v"
`include "BNR_CORE.v"
`include "RANGE_LUT.v"
`include "SRAM_MEM.v"
`include "SRAM_MEM1.v"
`include "sram.v"


// INTERFACES
`include "bnr_interface.sv"


// 3. Basic Data and Components
`include "bnr_sequencer.sv"
`include "bnr_driver.sv"
`include "bnr_monitor.sv"
`include "bnr_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "bnr_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           