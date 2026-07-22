// Lens Shading Correction with simplified radial equation
// pixel_out = pixel_in * Gain
// Gain = 1 + c2 * R^2 + c4 * R^4 .... (ommitted past c2)
// R^2 = dx^2 + dy^2
// find dx, dy -> find R^2 -> find Gain -> Multipler -> output
// Follows RGGB raw bayer
module LSC #(
    parameter PIXEL_W = 10,
    parameter LINE_W  = 2048,
    parameter FRAME_W = 1080,
    parameter C2_R    = 2, 
    parameter C2_Gr   = 2,
    parameter C2_Gb   = 2,
    parameter C2_B    = 2
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    output reg valid_out, h_sync_out, v_sync_out,
    output reg[PIXEL_W-1:0] pixel_out
);
    localparam MAX_VAL = {PIXEL_W{1'b1}};
    localparam DELAY   = 6;

    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W);
    
    localparam MID_X = LINE_W/2;
    localparam MID_Y = FRAME_W/2;

    localparam DX_W = $clog2(MID_X+1);                             
    localparam DY_W = $clog2(MID_Y+1);
    localparam X2_W = $clog2((MID_X**2)) + 1;
    localparam Y2_W = $clog2((MID_Y**2)) + 1;
    localparam R2_W = $clog2((MID_X**2) + (MID_Y**2)) + 1;

    localparam FP_SHIFT = 24; 
    localparam GAIN_W   = R2_W + FP_SHIFT;

    reg[LINE_CNT-1:0]  x_count;
    reg[FRAME_CNT-1:0] y_count;

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            x_count <= {LINE_CNT{1'b0}};
            y_count <= {FRAME_CNT{1'b0}};
        end 
        else if(v_sync) begin
            x_count <= {LINE_CNT{1'b0}};
            y_count <= {FRAME_CNT{1'b0}};
        end 
        else if(valid_in) begin
            if(x_count == LINE_W - 1) begin
                x_count <= {LINE_CNT{1'b0}};
                y_count <= y_count + 1'b1;
            end 
            else begin
                x_count <= x_count + 1'b1;
            end
        end
    end
  
    reg[DELAY-1:0]   valid_pipe;
    reg[DELAY-1:0]   hsync_pipe;
    reg[DELAY-1:0]   vsync_pipe;
    reg[PIXEL_W-1:0] pixel_pipe [DELAY-1:0];

    reg[DX_W-1:0] x_dist;
    reg[DY_W-1:0] y_dist;
    reg[R2_W-1:0] r2;
    reg[X2_W-1:0] x2;
    reg[Y2_W-1:0] y2;

    reg[GAIN_W-1:0] gain;
    reg[1:0] coef_pipe [DELAY-2:0];

    reg[R2_W: 0] r2_R , r2_Gr, r2_Gb, r2_B;

    reg[GAIN_W+PIXEL_W-1:0] product;
  
    wire[GAIN_W+PIXEL_W-1:0] shifted = product >> FP_SHIFT;
    wire[PIXEL_W-1:0] clamped_pixel  = (shifted > MAX_VAL) ? {PIXEL_W{1'b1}} : shifted[PIXEL_W-1:0];

    integer i;
    
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            pixel_out  <= {PIXEL_W{1'b0}};
            valid_out  <= 1'b0;
            h_sync_out <= 1'b0;
            v_sync_out <= 1'b0;
            valid_pipe <= {DELAY{1'b0}};
            hsync_pipe <= {DELAY{1'b0}};
            vsync_pipe <= {DELAY{1'b0}};
            x_dist     <= {DX_W{1'b0}};
            y_dist     <= {DY_W{1'b0}};
            r2         <= {R2_W{1'b0}};
            gain       <= {GAIN_W{1'b0}};

            for(i = 0; i < DELAY; i = i + 1) 
                pixel_pipe[i] <= {PIXEL_W{1'b0}};
            
            for(i = 0; i < DELAY-1; i = i + 1) 
                coef_pipe[i] <= 2'b0;
        end 
        else begin
            valid_pipe <= {valid_pipe[DELAY-2:0], valid_in};
            hsync_pipe <= {hsync_pipe[DELAY-2:0], h_sync};
            vsync_pipe <= {vsync_pipe[DELAY-2:0], v_sync};

            valid_out  <= valid_pipe[DELAY-1];
            h_sync_out <= hsync_pipe[DELAY-1];
            v_sync_out <= vsync_pipe[DELAY-1];

            for(i = DELAY-1; i > 0; i = i - 1) 
                pixel_pipe[i] <= pixel_pipe[i-1];
            pixel_pipe[0] <= pixel_in;

            for(i = DELAY-2; i > 0; i = i - 1) 
                coef_pipe[i] <= coef_pipe[i-1];
            coef_pipe[0] <= {y_count[0], x_count[0]}; 

            if(valid_in) begin
                x_dist <= (x_count <= MID_X) ? (MID_X - x_count) : (x_count - MID_X);
                y_dist <= (y_count <= MID_Y) ? (MID_Y - y_count) : (y_count - MID_Y);
            end

            if(valid_pipe[0]) begin
                x2 <= (x_dist * x_dist);
                y2 <= (y_dist * y_dist);
            end

            if(valid_pipe[1]) begin
                r2 <= x2 + y2;
            end

            if( valid_pipe[2] ) begin
                r2_R  <= C2_R  * r2; 
                r2_Gr <= C2_Gr * r2;
                r2_Gb <= C2_Gb * r2;
                r2_B  <= C2_B  * r2;
            end

            if(valid_pipe[3]) begin
                case(coef_pipe[DELAY-2])
                    2'b00: gain <= (1 << FP_SHIFT) + r2_R ;
                    2'b01: gain <= (1 << FP_SHIFT) + r2_Gr;
                    2'b10: gain <= (1 << FP_SHIFT) + r2_Gb;
                    2'b11: gain <= (1 << FP_SHIFT) + r2_B ;
                endcase
            end

            if(valid_pipe[4]) begin
                product <= gain * pixel_pipe[DELAY-2];
            end

            if(valid_pipe[5]) begin
                pixel_out  <= clamped_pixel;
            end
        end
    end
endmodule