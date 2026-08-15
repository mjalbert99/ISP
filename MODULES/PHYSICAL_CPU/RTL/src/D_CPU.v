module P_CPU #(
    parameter PIXEL_W = 10,
    parameter LINE_W  = 2048,
    parameter FRAME_W = 1080,
    parameter C2_R    = 2, 
    parameter C2_Gr   = 2,
    parameter C2_Gb   = 2,
    parameter C2_B    = 2,
    parameter FRAC_BITS = 16,
    parameter OFFSET_R = 65,
    parameter OFFSET_Gr = 64, 
    parameter OFFSET_Gb = 63, 
    parameter OFFSET_B = 62,
    parameter THRESHOLD = 70
) (
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    output valid_out, h_sync_out, v_sync_out,
    output[PIXEL_W-1:0] pixel_out   
);

    wire valid_blc_lsc, h_blc_lsc, v_blc_lsc;
    wire[PIXEL_W-1:0] pixel_blc_lsc;

    wire valid_lsc_dpc, h_lsc_dpc, v_lsc_dpc;
    wire[PIXEL_W-1:0] pixel_lsc_dpc;

    wire valid_dpc_out, h_dpc_out, v_dpc_out;
    wire[PIXEL_W-1:0] pixel_dpc_out;

    assign valid_out   = valid_dpc_out;
    assign h_sync_out  = h_dpc_out;
    assign v_sync_out  = v_dpc_out;
    assign pixel_out   = pixel_dpc_out;


    BLC blc (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .pixel_in(pixel_in),
        .valid_out(valid_blc_lsc),
        .h_sync_out(h_blc_lsc),
        .v_sync_out(v_blc_lsc),
        .pixel_out(pixel_blc_lsc)
    );


    LSC lsc (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_blc_lsc),
        .h_sync(h_blc_lsc),
        .v_sync(v_blc_lsc),
        .pixel_in(pixel_blc_lsc),
        .valid_out(valid_lsc_dpc),
        .h_sync_out(h_lsc_dpc),
        .v_sync_out(v_lsc_dpc),
        .pixel_out(pixel_lsc_dpc)
    );


    DPC dpc (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_lsc_dpc),
        .h_sync(h_lsc_dpc),
        .v_sync(v_lsc_dpc),
        .pixel_in(pixel_lsc_dpc),
        .valid_out(valid_dpc_out),
        .h_sync_out(h_dpc_out),
        .v_sync_out(v_dpc_out),
        .pixel_out(pixel_dpc_out)
    );

    
endmodule