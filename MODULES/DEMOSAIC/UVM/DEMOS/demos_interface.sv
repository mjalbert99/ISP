interface demos_interface(input clk);
    localparam PIXEL_W = 10;

    logic resetn;
    logic valid_in, h_sync, v_sync;
    logic[PIXEL_W-1:0] pixel_in;
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] red_out, green_out, blue_out;


    clocking cg_drv@(posedge clk);
        default input #1ns output #1ns;
        output resetn, valid_in, h_sync, v_sync;
        output pixel_in;
    endclocking

    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;
        input valid_in, valid_out, h_sync_out, v_sync_out, resetn;
        input pixel_in, red_out, green_out, blue_out;
    endclocking


endinterface