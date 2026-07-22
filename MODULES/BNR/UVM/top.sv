module top();

  import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    always #1.5 clk = ~clk;

    bnr_interface BNR_IF(clk);

    BNR DUT(
        .clk(clk),
        .resetn(BNR_IF.resetn),
        .valid_in(BNR_IF.valid_in),
        .h_sync(BNR_IF.h_sync),
        .v_sync(BNR_IF.v_sync),
        .pixel_in(BNR_IF.pixel_in),
        .valid_out(BNR_IF.valid_out),
        .h_sync_out(BNR_IF.h_sync_out),
        .v_sync_out(BNR_IF.v_sync_out),
        .pixel_out(BNR_IF.pixel_out)
    );

    assign BNR_IF.wr_addr  = DUT.wr_addr;
    assign BNR_IF.rd_addr  = DUT.rd_addr;
    assign BNR_IF.is_green = DUT.core.is_green;
    assign BNR_IF.is_edge  = DUT.core.is_edge; 
    assign BNR_IF.x_count  = DUT.core.x_count; 
    assign BNR_IF.y_count  = DUT.core.y_count; 

    initial begin
        clk = 0;
        uvm_config_db#(virtual bnr_interface)::set(null, "*", "BNR_IF", BNR_IF);
        run_test("test");
    end   

endmodule