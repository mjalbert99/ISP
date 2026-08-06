// all pixels delayed by three clock cycles for pipeline, coef_in read at frame start
module CCM #(
    parameter PIXEL_W = 10,
    parameter LINE_W  = 2048,
    parameter FRAME_W = 1080,
    parameter COEF_W  = 10,
    parameter FRAC_W  = 8
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync, coef_in,
    input[PIXEL_W-1:0] red_in, green_in, blue_in,
    input[(3*COEF_W)-1:0] row0, row1, row2,
    output reg valid_out, h_sync_out, v_sync_out,
    output reg[PIXEL_W-1:0] red_out, green_out, blue_out
);
    localparam MAX_VAL    = (1 << PIXEL_W) - 1;
    localparam MAX_MULT_W = PIXEL_W + COEF_W;
    localparam MAX_DIST_W = MAX_MULT_W + 2;
    localparam DELAY      = 3;
    localparam ROUND_CONST = (FRAC_W > 0) ? (1 <<< (FRAC_W-1)) : 0;

    reg signed[COEF_W-1:0] matrix[2:0][2:0];

    integer i, j;
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            for(i = 0; i < 3; i = i + 1)
                for(j = 0; j < 3; j = j + 1)
                    matrix[i][j] <= 0;

        end 
        else if(coef_in && v_sync) begin
                matrix[0][0] <= row0[COEF_W-1:0];
                matrix[0][1] <= row0[2*COEF_W-1:COEF_W];
                matrix[0][2] <= row0[3*COEF_W-1:2*COEF_W];

                matrix[1][0] <= row1[COEF_W-1:0];
                matrix[1][1] <= row1[2*COEF_W-1:COEF_W];
                matrix[1][2] <= row1[3*COEF_W-1:2*COEF_W];

                matrix[2][0] <= row2[COEF_W-1:0];
                matrix[2][1] <= row2[2*COEF_W-1:COEF_W];
                matrix[2][2] <= row2[3*COEF_W-1:2*COEF_W];
        end
    end
    
    reg[DELAY-1:0] valid_pipe, h_pipe, v_pipe;
    
    reg signed[PIXEL_W:0] red_pipe, green_pipe, blue_pipe; 

    reg signed[MAX_MULT_W-1:0] red_mult[2:0], green_mult[2:0], blue_mult[2:0];
    reg signed[MAX_DIST_W-1:0] red_dist, green_dist, blue_dist;

    wire signed[MAX_DIST_W:0] red_dist_rnd   = {red_dist[MAX_DIST_W-1],   red_dist}   + ROUND_CONST;
    wire signed[MAX_DIST_W:0] green_dist_rnd = {green_dist[MAX_DIST_W-1], green_dist} + ROUND_CONST;
    wire signed[MAX_DIST_W:0] blue_dist_rnd  = {blue_dist[MAX_DIST_W-1],  blue_dist}  + ROUND_CONST;

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            valid_out  <= 0;
            h_sync_out <= 0;
            v_sync_out <= 0;
            red_out    <= 0;
            green_out  <= 0;
            blue_out   <= 0;

            valid_pipe <= 0;
            h_pipe     <= 0;
            v_pipe     <= 0;

            red_pipe   <= 0;
            green_pipe <= 0;
            blue_pipe  <= 0;

            for(i = 0; i < 3; i = i + 1) begin
                red_mult[i]   <= 0;
                green_mult[i] <= 0;
                blue_mult[i]  <= 0;
            end

            red_dist   <= 0;
            green_dist <= 0;
            blue_dist  <= 0;

        end 
        else begin
            
            valid_pipe <= {valid_pipe[DELAY-2:0], valid_in};
            h_pipe     <= {h_pipe[DELAY-2:0], h_sync};
            v_pipe     <= {v_pipe[DELAY-2:0], v_sync};

            valid_out  <= valid_pipe[DELAY-1];
            h_sync_out <= h_pipe[DELAY-1];
            v_sync_out <= v_pipe[DELAY-1];

            if(valid_in) begin
                red_pipe   <= {1'b0, red_in};
                green_pipe <= {1'b0, green_in};
                blue_pipe  <= {1'b0, blue_in};
            end

            if(valid_pipe[0]) begin
                red_mult[0] <= red_pipe   * matrix[0][0];
                red_mult[1] <= green_pipe * matrix[0][1];
                red_mult[2] <= blue_pipe  * matrix[0][2];

                green_mult[0] <= red_pipe   * matrix[1][0];
                green_mult[1] <= green_pipe * matrix[1][1];
                green_mult[2] <= blue_pipe  * matrix[1][2];

                blue_mult[0] <= red_pipe   * matrix[2][0];
                blue_mult[1] <= green_pipe * matrix[2][1];
                blue_mult[2] <= blue_pipe  * matrix[2][2];
            end

            if(valid_pipe[1]) begin
                red_dist   <= red_mult[0]   + red_mult[1]   + red_mult[2];
                green_dist <= green_mult[0] + green_mult[1] + green_mult[2];
                blue_dist  <= blue_mult[0]  + blue_mult[1]  + blue_mult[2];
            end

            if(valid_pipe[2]) begin
                red_out   <= (red_dist_rnd[MAX_DIST_W]) ? 0 :
                             ((red_dist_rnd >>> FRAC_W) > MAX_VAL) ? MAX_VAL : (red_dist_rnd >>> FRAC_W);

                green_out <= (green_dist_rnd[MAX_DIST_W]) ? 0 :
                             ((green_dist_rnd >>> FRAC_W) > MAX_VAL) ? MAX_VAL : (green_dist_rnd >>> FRAC_W);

                blue_out  <= (blue_dist_rnd[MAX_DIST_W]) ? 0 :
                             ((blue_dist_rnd >>> FRAC_W) > MAX_VAL) ? MAX_VAL : (blue_dist_rnd >>> FRAC_W);
            end
        end
    end

endmodule