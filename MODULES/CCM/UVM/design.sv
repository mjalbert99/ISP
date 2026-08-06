
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "CCM.v"


// INTERFACES
`include "ccm_interface.sv"


// 3. Basic Data and Components
`include "ccm_sequencer.sv"
`include "ccm_driver.sv"
`include "ccm_monitor.sv"
`include "ccm_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "ccm_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           