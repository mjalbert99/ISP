module C_CPU #(
    parameter PIXEL_W = 10,
    parameter LINE_W  = 2048,
    parameter FRAME_W = 1080,
    parameter COEF_W  = 10,
    parameter FRAC_W  = 8,
    parameter GAM_W   = 1024
) (
    input clk, resetn, coef_in,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] red_in, green_in, blue_in,
    input[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in,
    input[(3*COEF_W)-1:0] row0, row1, row2,
    output valid_out, h_sync_out, v_sync_out,
    output[PIXEL_W-1:0] red_out, green_out, blue_out   
);

    wire valid_ccm_gamma, h_ccm_gamma, v_ccm_gamma;
    wire[PIXEL_W-1:0] red_ccm_gamma, green_ccm_gamma, blue_ccm_gamma;


    CCM ccm (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .coef_in(coef_in),              
        .red_in(red_in),
        .green_in(green_in),
        .blue_in(blue_in),
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