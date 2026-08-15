module D_CPU #(
    parameter PIXEL_W = 10,
    parameter LINE_W  = 2048,
    parameter FRAME_W = 1080,
    parameter WBG_FRAC_BITS = 8,
    parameter R_GAIN    = 384,
    parameter GR_GAIN   = 256,
    parameter GB_GAIN   = 256,
    parameter B_GAIN    = 512,
    parameter BNR_THRESHOLD = 70
) (
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    output valid_out, h_sync_out, v_sync_out,
    output[PIXEL_W-1:0] red_out, green_out, blue_out   
);

    wire valid_bnr_wbg, h_bnr_wbg, v_bnr_wbg;
    wire[PIXEL_W-1:0] pixel_bnr_wbg;

    wire valid_wbg_demos, h_wbg_demos, v_wbg_demos;
    wire[PIXEL_W-1:0] pixel_wbg_demos;

    wire valid_demos_out, h_demos_out, v_demos_out;
    wire[PIXEL_W-1:0] red_demos_out, green_demos_out, blue_demos_out;

    assign valid_out   = valid_demos_out;
    assign h_sync_out  = h_demos_out;
    assign v_sync_out  = v_demos_out;
    assign red_out     = red_demos_out;
    assign green_out   = green_demos_out;
    assign blue_out    = blue_demos_out;

    BNR  bnr (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .pixel_in(pixel_in),
        .valid_out(valid_bnr_wbg),
        .h_sync_out(h_bnr_wbg),
        .v_sync_out(v_bnr_wbg),
        .pixel_out(pixel_bnr_wbg)
    );


    WBG wbg (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_bnr_wbg),
        .v_sync(v_bnr_wbg),
        .h_sync(h_bnr_wbg),
        .pixel_in(pixel_bnr_wbg),
        .valid_out(valid_wbg_demos),
        .v_sync_out(v_wbg_demos),
        .h_sync_out(h_wbg_demos),
        .pixel_out(pixel_wbg_demos)
    );


    DEMOSAIC demos (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_wbg_demos),
        .h_sync(h_wbg_demos),
        .v_sync(v_wbg_demos),
        .pixel_in(pixel_in),
        .valid_out(valid_demos_out),
        .h_sync_out(h_demos_out),
        .v_sync_out(v_demos_out),
        .red_out(red_demos_out),
        .green_out(green_demos_out),
        .blue_out(blue_demos_out)
    ); 

    
endmodule