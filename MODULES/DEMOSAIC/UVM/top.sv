module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    demos_interface DEMOS_IF(clk);

    DEMOSAIC DUT(
        .clk(clk),
        .resetn(DEMOS_IF.resetn),
        .valid_in(DEMOS_IF.valid_in),
        .h_sync(DEMOS_IF.h_sync),
        .v_sync(DEMOS_IF.v_sync),
        .pixel_in(DEMOS_IF.pixel_in),
        .valid_out(DEMOS_IF.valid_out),
        .h_sync_out(DEMOS_IF.h_sync_out),
        .v_sync_out(DEMOS_IF.v_sync_out),
      	.red_out(DEMOS_IF.red_out),
      	.green_out(DEMOS_IF.green_out),
        .blue_out(DEMOS_IF.blue_out)
    );


    initial begin
        clk = 0;
        uvm_config_db#(virtual demos_interface)::set(null, "*", "DEMOS_IF", DEMOS_IF);
        run_test("test");
    end   

endmodule