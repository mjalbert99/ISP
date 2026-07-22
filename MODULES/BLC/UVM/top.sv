module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    blc_interface BLC_IF(clk);

    BLC DUT(
        .clk(clk),
        .resetn(BLC_IF.resetn),
        .valid_in(BLC_IF.valid_in),
        .h_sync(BLC_IF.h_sync),
        .v_sync(BLC_IF.v_sync),
        .pixel_in(BLC_IF.pixel_in),
        .valid_out(BLC_IF.valid_out),
        .h_sync_out(BLC_IF.h_sync_out),
        .v_sync_out(BLC_IF.v_sync_out),
        .pixel_out(BLC_IF.pixel_out)
    );

    assign BLC_IF.row_phase = DUT.row_phase;
    assign BLC_IF.col_phase = DUT.col_phase;

    initial begin
        clk = 0;
        uvm_config_db#(virtual blc_interface)::set(null, "*", "BLC_IF", BLC_IF);
        run_test("test");
    end   

endmodule