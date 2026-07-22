
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "DPC.v"
`include "DPC_CORE.v"
`include "sram.v"


// INTERFACES
`include "dpc_interface.sv"


// 3. Basic Data and Components
`include "dpc_sequencer.sv"
`include "dpc_driver.sv"
`include "dpc_monitor.sv"
`include "dpc_coverage.sv"

`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "dpc_agent.sv"          
    
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           