interface gam_interface(input clk);
    parameter PIXEL_W = 10;
    parameter GAM_W = 10;

    logic resetn, valid_in, h_sync, v_sync;
    logic[PIXEL_W-1:0] red_in, green_in, blue_in;
    logic[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in;
    
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] red_out, green_out, blue_out;
    
    clocking cg_drv@(posedge clk);
        default input #1ns output #1ns;

        output resetn, valid_in, h_sync, v_sync;
        output red_in, green_in, blue_in;
        output gam_red_in, gam_green_in, gam_blue_in;
    endclocking

    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;

        input resetn, valid_in, h_sync, v_sync;
        input red_in, green_in, blue_in;
        input gam_red_in, gam_green_in, gam_blue_in;

        input valid_out, h_sync_out, v_sync_out;
        input red_out, green_out, blue_out;
    endclocking

endinterface    