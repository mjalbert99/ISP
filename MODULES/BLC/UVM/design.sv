
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "BLC.v"


// INTERFACES
`include "blc_interface.sv"


// 3. Basic Data and Components
`include "blc_sequencer.sv"
`include "blc_driver.sv"
`include "blc_monitor.sv"
`include "blc_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "blc_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           