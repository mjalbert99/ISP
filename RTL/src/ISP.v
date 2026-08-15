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

    
    
    wire valid_ccm_gamma, h_ccm_gamma, v_ccm_gamma;
    wire[PIXEL_W-1:0] red_ccm_gamma, green_ccm_gamma, blue_ccm_gamma;




    


    CCM #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W),
        .COEF_W(COEF_W),
        .FRAC_W(FRAC_W)
    ) ccm (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_demos_ccm),
        .h_sync(h_demos_ccm),
        .v_sync(v_demos_ccm),
        .coef_in(coef_in),              
        .red_in(red_demos_ccm),
        .green_in(green_demos_ccm),
        .blue_in(blue_demos_ccm),
        .row0(row0),                    
        .row1(row1),                    
        .row2(row2),                    
        .valid_out(valid_ccm_gamma),
        .h_sync_out(h_ccm_gamma),
        .v_sync_out(v_ccm_gamma),
        .red_out(red_ccm_gamma),
        .green_out(green_ccm_gamma),
        .blue_out(blue_ccm_gamma)
    );


    GAM gam (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_ccm_gamma),
        .h_sync(h_ccm_gamma),
        .v_sync(v_ccm_gamma),
        .red_in(red_ccm_gamma),
        .green_in(green_ccm_gamma),
        .blue_in(blue_ccm_gamma),
        .gam_red_in(gam_red_in),
        .gam_green_in(gam_green_in),
        .gam_blue_in(gam_blue_in),
        .valid_out(valid_out),
        .h_sync_out(h_sync_out),
        .v_sync_out(v_sync_out),
        .red_out(red_out),
        .green_out(green_out),
        .blue_out(blue_out)
    );
endmodule 