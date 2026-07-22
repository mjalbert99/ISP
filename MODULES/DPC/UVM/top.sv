module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    dpc_interface DPC_IF(clk);

    DPC DUT(
        .clk(clk),
        .resetn(DPC_IF.resetn),
        .valid_in(DPC_IF.valid_in),
        .h_sync(DPC_IF.h_sync),
        .v_sync(DPC_IF.v_sync),
        .pixel_in(DPC_IF.pixel_in),
        .valid_out(DPC_IF.valid_out),
        .h_sync_out(DPC_IF.h_sync_out),
        .v_sync_out(DPC_IF.v_sync_out),
        .pixel_out(DPC_IF.pixel_out)
    );

    assign DPC_IF.wr_addr  = DUT.wr_addr;
    assign DPC_IF.rd_addr  = DUT.rd_addr;
    assign DPC_IF.is_dead  = DUT.core.is_dead;
    assign DPC_IF.is_hot   = DUT.core.is_hot;
    assign DPC_IF.is_green = DUT.core.is_green;
    assign DPC_IF.is_edge  = DUT.core.is_edge; 
    assign DPC_IF.x_count  = DUT.core.x_count; 
    assign DPC_IF.y_count  = DUT.core.y_count; 

    initial begin
        clk = 0;
        uvm_config_db#(virtual dpc_interface)::set(null, "*", "DPC_IF", DPC_IF);
        run_test("test");
    end   

endmodule