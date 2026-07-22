module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    wbg_interface WBG_IF(clk);

    WBG DUT(
        .clk(clk),
        .resetn(WBG_IF.resetn),
        .valid_in(WBG_IF.valid_in),
        .h_sync(WBG_IF.h_sync),
        .v_sync(WBG_IF.v_sync),
        .pixel_in(WBG_IF.pixel_in),
        .valid_out(WBG_IF.valid_out),
        .h_sync_out(WBG_IF.h_sync_out),
        .v_sync_out(WBG_IF.v_sync_out),
        .pixel_out(WBG_IF.pixel_out)
    );

    assign WBG_IF.row_phase = DUT.row;
    assign WBG_IF.col_phase = DUT.col;

    initial begin
        clk = 0;
        uvm_config_db#(virtual wbg_interface)::set(null, "*", "WBG_IF", WBG_IF);
        run_test("test");
    end   

endmodule