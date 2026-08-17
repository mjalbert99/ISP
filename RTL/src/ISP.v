module ISP #(
    parameter PIXEL_W = 10, 
    parameter COEF_W  = 10
)(
    input clk, resetn, coef_in,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    input[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in,
    input[(3*COEF_W)-1:0] row0, row1, row2,
    output valid_out, h_sync_out, v_sync_out,
    output[PIXEL_W-1:0] red_out, green_out, blue_out
);

    wire valid_p_d, h_p_d, v_p_d;
    wire[PIXEL_W-1:0] pixel_p_d;

    wire reg_valid_p_d, reg_h_p_d, reg_v_p_d;
    wire[PIXEL_W-1:0] reg_pixel_p_d;

    wire valid_d_c, h_d_c, v_d_c;
    wire[PIXEL_W-1:0] red_d_c, green_d_c, blue_d_c;

    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            reg_valid_p_d <= 0;
            reg_h_p_d     <= 0;
            reg_v_p_d     <= 0;
            reg_pixel_p_d <= 0;
        end
        else begin

            reg_valid_p_d <= valid_p_d;
            reg_h_p_d     <= h_p_d    ;
            reg_v_p_d     <= v_p_d    ;
            reg_pixel_p_d <= pixel_p_d;
        
        end
    end
    
    P_CPU p_cpu (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in), 
        .h_sync(h_sync), 
        .v_sync(v_sync),
        .pixel_in(pixel_in),
        .valid_out(valid_p_d), 
        .h_sync_out(h_p_d), 
        .v_sync_out(v_p_d),
        .pixel_out(pixel_p_d)   
    );   

    D_CPU d_cpu (
        .clk(clk),
        .resetn(resetn),
        .valid_in(reg_valid_p_d), 
        .h_sync(reg_h_p_d), 
        .v_sync(reg_v_p_d),
        .pixel_in(reg_pixel_p_d),
        .valid_out(valid_d_c), 
        .h_sync_out(h_d_c), 
        .v_sync_out(v_d_c),
        .red_out(red_d_c),   
        .green_out(green_d_c),   
        .blue_out(blue_d_c)   
    );   

    C_CPU c_cpu (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_d_c), 
        .h_sync(h_d_c), 
        .v_sync(v_d_c),
        .coef_in(coef_in),
        .red_in(red_d_c),
        .green_in(green_d_c),
        .blue_in(blue_d_c),
        .gam_red_in(gam_red_in),
        .gam_green_in(gam_green_in),
        .gam_blue_in(gam_blue_in),
        .row0(row0),
        .row1(row1),
        .row2(row2),
        .valid_out(valid_out), 
        .h_sync_out(h_sync_out), 
        .v_sync_out(v_sync_out),
        .red_out(red_out),   
        .green_out(green_out),  
        .blue_out(blue_out)   
    );   




endmodule 