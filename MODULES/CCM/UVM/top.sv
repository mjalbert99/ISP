module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    ccm_interface CCM_IF(clk);

    CCM DUT(
        .clk(clk),
        .resetn(CCM_IF.resetn),
        .valid_in(CCM_IF.valid_in),
        .h_sync(CCM_IF.h_sync),
        .v_sync(CCM_IF.v_sync),
        .coef_in(CCM_IF.coef_in),
      	.red_in(CCM_IF.red_in),
      	.green_in(CCM_IF.green_in),
        .blue_in(CCM_IF.blue_in),
        .row0({CCM_IF.row0[2], CCM_IF.row0[1], CCM_IF.row0[0]}),
        .row1({CCM_IF.row1[2], CCM_IF.row1[1], CCM_IF.row1[0]}),
        .row2({CCM_IF.row2[2], CCM_IF.row2[1], CCM_IF.row2[0]}),
        .valid_out(CCM_IF.valid_out),
        .h_sync_out(CCM_IF.h_sync_out),
        .v_sync_out(CCM_IF.v_sync_out),
      	.red_out(CCM_IF.red_out),
      	.green_out(CCM_IF.green_out),
        .blue_out(CCM_IF.blue_out)
    );


    initial begin
        clk = 0;
        uvm_config_db#(virtual ccm_interface)::set(null, "*", "CCM_IF", CCM_IF);
        run_test("test");
    end   

endmodule