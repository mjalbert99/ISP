
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "DEMOSAIC.v"
`include "DEMOS_CORE.v"


// INTERFACES
`include "demos_interface.sv"


// 3. Basic Data and Components
`include "demos_sequencer.sv"
`include "demos_driver.sv"
`include "demos_monitor.sv"
`include "demos_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "demos_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           