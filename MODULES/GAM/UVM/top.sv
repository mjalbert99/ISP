module top();

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;
    gam_interface GAM_IF(clk);

    GAM DUT (
        .clk(GAM_IF.clk),
        .resetn(GAM_IF.resetn),
        .valid_in(GAM_IF.valid_in),
        .h_sync(GAM_IF.h_sync),
        .v_sync(GAM_IF.v_sync),
        .red_in(GAM_IF.red_in),
        .green_in(GAM_IF.green_in),
        .blue_in(GAM_IF.blue_in),
        .gam_red_in(GAM_IF.gam_red_in),
        .gam_green_in(GAM_IF.gam_green_in),
        .gam_blue_in(GAM_IF.gam_blue_in),
        .valid_out(GAM_IF.valid_out),
        .h_sync_out(GAM_IF.h_sync_out),
        .v_sync_out(GAM_IF.v_sync_out),
        .red_out(GAM_IF.red_out),
        .green_out(GAM_IF.green_out),
        .blue_out(GAM_IF.blue_out)        
    );

    always #1.5 clk = ~clk;

    initial begin
        clk = 0;
        uvm_config_db#(virtual gam_interface)::set(null, "*", "GAM_IF", GAM_IF);
        run_test("test");
    end

endmodule