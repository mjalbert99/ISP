
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "WBG.v"


// INTERFACES
`include "wbg_interface.sv"


// 3. Basic Data and Components
`include "wbg_sequencer.sv"
`include "wbg_driver.sv"
`include "wbg_monitor.sv"
`include "wbg_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "wbg_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           