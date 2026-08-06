interface ccm_interface(input clk);
    localparam PIXEL_W = 10;
    localparam COEF_W = 10;

    logic resetn, coef_in;
    logic valid_in, h_sync, v_sync;
    logic[PIXEL_W-1:0] red_in, green_in, blue_in;
    logic[COEF_W-1:0] row0[3], row1[3], row2[3];
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] red_out, green_out, blue_out;

    clocking cg_drv@(posedge clk);
        default input #1ns output #1ns;
        output resetn, valid_in, h_sync, v_sync, coef_in;
        output red_in, green_in, blue_in, row0, row1, row2;
    endclocking

    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;
        input valid_in, valid_out, h_sync_out, v_sync_out, resetn, coef_in;
        input red_in, green_in, blue_in, red_out, green_out, blue_out, row0, row1, row2;
    endclocking


endinterface