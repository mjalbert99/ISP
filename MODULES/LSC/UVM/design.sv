
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "LSC.v"


// INTERFACES
`include "lsc_interface.sv"


// 3. Basic Data and Components
`include "lsc_sequencer.sv"
`include "lsc_driver.sv"
`include "lsc_monitor.sv"
`include "lsc_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "lsc_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           