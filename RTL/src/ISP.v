module ISP #(
    parameter PIXEL_W = 10, 
    parameter LINE_W  = 2048,
    // BLC
    parameter FRAME_W = 1080,
    parameter OFFSET_W = 8, 
    parameter SCALE_INT = 2, 
    parameter FRAC_BITS = 16,
    parameter OFFSET_R = 65,
    parameter OFFSET_Gr = 64, 
    parameter OFFSET_Gb = 63, 
    parameter OFFSET_B = 62,
    // LSC
    parameter C2_R    = 2, 
    parameter C2_Gr   = 2,
    parameter C2_Gb   = 2,
    parameter C2_B    = 2,
    // DPC
    parameter THRESHOLD = 70,
    // BNR
    parameter BNR_THRESHOLD = 70,
    // WBG
    parameter WBG_FRAC_BITS = 8,
    parameter R_GAIN    = 384,
    parameter GR_GAIN   = 256,
    parameter GB_GAIN   = 256,
    parameter B_GAIN    = 512,
    // DEMOS
    // CCM
    parameter COEF_W  = 10,
    parameter FRAC_W  = 8,
    // GAM
    parameter GAM_W   = 1024

)(
    input clk, resetn, coef_in,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    input[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in,
    input[(3*COEF_W)-1:0] row0, row1, row2,
    output valid_out, h_sync_out, v_sync_out,
    output[PIXEL_W-1:0] red_out, green_out, blue_out
);

    
    


endmodule 