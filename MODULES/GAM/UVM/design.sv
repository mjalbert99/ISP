
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "GAM.v"


// INTERFACES
`include "gam_interface.sv"


// 3. Basic Data and Components
`include "gam_sequencer.sv"
`include "gam_driver.sv"
`include "gam_monitor.sv"
`include "gam_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "gam_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           