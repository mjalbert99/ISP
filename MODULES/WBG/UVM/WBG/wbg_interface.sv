interface wbg_interface(input clk);
    localparam PIXEL_W = 10;

    logic resetn;
    logic valid_in, h_sync, v_sync;
    logic[PIXEL_W-1:0] pixel_in;
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] pixel_out;

    logic row_phase, col_phase;   

    clocking cg_drv@(posedge clk);
        default input #1ns output #1ns;
        output resetn, valid_in, h_sync, v_sync;
        output pixel_in;
    endclocking

    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;
        input valid_in, valid_out, h_sync_out, v_sync_out, resetn;
        input pixel_in, pixel_out;
        input row_phase, col_phase;
    endclocking

    valid_out_proc: assert property(@(posedge clk) disable iff(!resetn) valid_in |=> ## 1 valid_out)
        else `uvm_error("SVA_PROT_FAIL", "Valid_in to Valid_out not aligned0")

    not_valid_out_proc: assert property(@(posedge clk) disable iff(!resetn) !valid_in |=> ## 1 !valid_out)
        else `uvm_error("SVA_PROT_FAIL", "Valid_in to Valid_out not aligned1")

    resetn_proc: assert property(@(posedge clk) (!resetn) |=> (row_phase == 0) && (col_phase == 0) && (pixel_out == 0))
        else `uvm_error("SVA_PROT_FAIL", "Resetn did not work")

    vsync_proc: assert property(@(posedge clk) disable iff(!resetn) (v_sync) |=> (row_phase == 0) && (col_phase == 0))
        else `uvm_error("SVA_PROT_FAIL", "V_sync did not work")

    hsync_proc: assert property(@(posedge clk) disable iff(!resetn || v_sync) (h_sync) |=> (col_phase == 0) && (!$stable(row_phase)))
        else `uvm_error("SVA_PROT_FAIL", "H_sync did not work")

endinterface