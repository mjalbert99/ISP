module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    lsc_interface LSC_IF(clk);

    LSC DUT(
        .clk(clk),
        .resetn(LSC_IF.resetn),
        .valid_in(LSC_IF.valid_in),
        .h_sync(LSC_IF.h_sync),
        .v_sync(LSC_IF.v_sync),
        .pixel_in(LSC_IF.pixel_in),
        .valid_out(LSC_IF.valid_out),
        .h_sync_out(LSC_IF.h_sync_out),
        .v_sync_out(LSC_IF.v_sync_out),
        .pixel_out(LSC_IF.pixel_out)
    );

    assign LSC_IF.x_count = DUT.x_count;
    assign LSC_IF.y_count = DUT.y_count;

    initial begin
        clk = 0;
        uvm_config_db#(virtual lsc_interface)::set(null, "*", "LSC_IF", LSC_IF);
        run_test("test");
    end   

endmodule