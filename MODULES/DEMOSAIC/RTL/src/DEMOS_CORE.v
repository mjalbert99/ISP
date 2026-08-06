// USES MHC to demosaic the single channel to RGGB
module DEMOS_CORE #(
    parameter PIXEL_W   = 10,
    parameter LINE_W    = 2048,
    parameter FRAME_W   = 1080
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    input[PIXEL_W-1:0] sram_in0, sram_in1, sram_in2, sram_in3,
    output reg valid_out, h_sync_out, v_sync_out,
    output reg[PIXEL_W-1:0] red_out, green_out, blue_out
);
    localparam MAX_VAL   = {PIXEL_W{1'b1}};
    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W+2);
    localparam DELAY     = 4;
    localparam ADD_W     = $clog2(4*MAX_VAL);
    localparam CLAMP_W = $clog2(28*MAX_VAL) + 2;
 
    // coord positions
    reg[LINE_CNT-1:0]  x_count;
    reg[FRAME_CNT-1:0] y_count;
    wire valid_gated = (y_count >= 2 && valid_in);

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

    // delayed positions
    reg[LINE_CNT-1:0]  x_out;
    reg[FRAME_CNT-1:0] y_out;

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            x_out <= {LINE_CNT{1'b0}};
            y_out <= {FRAME_CNT{1'b0}};
        end 
        else if(v_sync) begin
            x_out <= {LINE_CNT{1'b0}};
            y_out <= {FRAME_CNT{1'b0}};
        end 
        else if(valid_gated) begin
            if(x_out == LINE_W - 1) begin
                x_out <= {LINE_CNT{1'b0}};
                y_out <= y_out + 1'b1;
            end 
            else begin
                x_out <= x_out + 1'b1;
            end
        end
    end

    reg[DELAY-1:0] valid_pipe, h_pipe, v_pipe;
    wire h_out, v_out;

    assign h_out = x_out == 0;
    assign v_out = (x_out == 0) && (y_out == 0);

    reg[PIXEL_W-1:0] window[4:0][4:0], calc_window[4:0][4:0];

    reg[LINE_CNT-1:0]  x_pipe[1:0];
    reg[FRAME_CNT-1:0] y_pipe[1:0];

    reg[1:0] phase[1:0];
    reg[PIXEL_W-1:0] center[1:0];

    reg[ADD_W-1:0] sum_diag, sum_cross, sum_h_inner, sum_h_outer, sum_v_inner, sum_v_outer;

    reg signed[CLAMP_W-1:0] g_rb, rb_br, r_gr, b_gr; 
    wire[PIXEL_W-1:0] r_val, g_val, b_val, rb_val;

    wire signed [CLAMP_W-1:0] g_norm  = g_rb  >>> 3;
    wire signed [CLAMP_W-1:0] rb_norm = rb_br >>> 4;
    wire signed [CLAMP_W-1:0] r_norm  = r_gr  >>> 4;
    wire signed [CLAMP_W-1:0] b_norm  = b_gr  >>> 4;

    assign g_val  = (g_norm  < 0) ? {PIXEL_W{1'b0}} : (g_norm  > MAX_VAL) ? MAX_VAL[PIXEL_W-1:0] : g_norm[PIXEL_W-1:0];
    assign rb_val = (rb_norm < 0) ? {PIXEL_W{1'b0}} : (rb_norm > MAX_VAL) ? MAX_VAL[PIXEL_W-1:0] : rb_norm[PIXEL_W-1:0];
    assign r_val  = (r_norm  < 0) ? {PIXEL_W{1'b0}} : (r_norm  > MAX_VAL) ? MAX_VAL[PIXEL_W-1:0] : r_norm[PIXEL_W-1:0];
    assign b_val  = (b_norm  < 0) ? {PIXEL_W{1'b0}} : (b_norm  > MAX_VAL) ? MAX_VAL[PIXEL_W-1:0] : b_norm[PIXEL_W-1:0];

    integer i, j;

    always@(*) begin
        for(i = 0; i < 5; i++) begin
            for(j = 0; j < 5; j++) begin
                calc_window[i][j] = window[i][j];
            end
        end


        if(y_pipe[1] == 0) begin
            for(j = 0; j < 5; j++) begin
                calc_window[4][j] = window[0][j];
                calc_window[3][j] = window[1][j];
            end
        end
        else if(y_pipe[1] == 1) begin
            for(j = 0; j < 5; j++) begin
                calc_window[4][j] = window[0][j];
            end
        end
        else if(y_pipe[1] == FRAME_W-2) begin
            for(j = 0; j < 5; j++) begin
                calc_window[0][j] = window[4][j];
            end
        end
        else if(y_pipe[1] == FRAME_W-1) begin
            for(j = 0; j < 5; j++) begin
                calc_window[0][j] = window[4][j];
                calc_window[1][j] = window[3][j];
            end
        end

        if(x_pipe[1] == 0) begin
            for(i = 0; i < 5; i++) begin
                calc_window[i][4] = calc_window[i][0];
                calc_window[i][3] = calc_window[i][1];
            end
        end
        else if(x_pipe[1] == 1) begin
            for(i = 0; i < 5; i++) begin
                calc_window[i][4] = calc_window[i][0];
            end
        end
        else if(x_pipe[1] == LINE_W-2) begin
            for(i = 0; i < 5; i++) begin
                calc_window[i][0] = calc_window[i][4];
            end
        end
        else if(x_pipe[1] == LINE_W-1) begin
            for(i = 0; i < 5; i++) begin
                calc_window[i][0] = calc_window[i][4];
                calc_window[i][1] = calc_window[i][3];
            end
        end
    end

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            red_out         <= 0;
            green_out       <= 0;
            blue_out        <= 0;
            valid_out       <= 0;
            h_sync_out      <= 0;
            v_sync_out      <= 0;

            sum_cross       <= 0;
            sum_diag        <= 0;
            sum_h_inner     <= 0;
            sum_h_outer     <= 0;
            sum_v_inner     <= 0;
            sum_v_outer     <= 0;

            g_rb            <= 0;
            rb_br           <= 0;
            r_gr            <= 0;
            b_gr            <= 0;

            for(i = 0; i < 5; i++) begin
                for(j = 0; j < 5; j++) begin
                    window[i][j] <= 0;
                end
            end

            for(i = 0; i < 2; i++) begin
                x_pipe[i] <= 0;
                y_pipe[i] <= 0;
                phase[i]  <= 0;
                center[i] <= 0;
            end
        end
        else begin

            valid_pipe  <= {valid_pipe[DELAY-2:0], valid_gated};
            h_pipe      <= {h_pipe[DELAY-2:0], h_out};
            v_pipe      <= {v_pipe[DELAY-2:0], v_out};

            x_pipe[1]   <= x_pipe[0];
            x_pipe[0]   <= x_out;
            y_pipe[1]   <= y_pipe[0];
            y_pipe[0]   <= y_out;

            valid_out  <= valid_pipe[DELAY-1];
            h_sync_out <= h_pipe[DELAY-1];
            v_sync_out <= v_pipe[DELAY-1];

            if(valid_in) begin
                window[0][0] <= pixel_in;
                window[1][0] <= sram_in0;
                window[2][0] <= sram_in1;
                window[3][0] <= sram_in2;
                window[4][0] <= sram_in3;

                for(j = 0; j < 4; j++) begin
                    window[0][j+1] <= window[0][j];
                    window[1][j+1] <= window[1][j];
                    window[2][j+1] <= window[2][j];
                    window[3][j+1] <= window[3][j];
                    window[4][j+1] <= window[4][j];
                end
            end

            if(valid_pipe[1]) begin

                phase[0]  <= {y_pipe[1][0], x_pipe[1][0]};
                center[0] <= calc_window[2][2];

                sum_cross   <= calc_window[1][2] + calc_window[3][2] + calc_window[2][1] + calc_window[2][3];
                sum_diag    <= calc_window[1][1] + calc_window[1][3] + calc_window[3][1] + calc_window[3][3];
                sum_v_outer <= calc_window[0][2] + calc_window[4][2];
                sum_v_inner <= calc_window[1][2] + calc_window[3][2];
                sum_h_outer <= calc_window[2][0] + calc_window[2][4];
                sum_h_inner <= calc_window[2][1] + calc_window[2][3];

            end

            if(valid_pipe[2]) begin
                phase[1]  <= phase[0]; 
                center[1] <= center[0];

                g_rb  <= (center[0] << 2) + (sum_cross << 1) - (sum_v_outer + sum_h_outer);
                rb_br <= (center[0] * 12) + (sum_diag << 2) - ((sum_v_outer + sum_h_outer) * 3);
                r_gr  <= (center[0] * 10) + (sum_h_inner << 3) - ((sum_diag + sum_h_outer) << 1) + sum_v_outer;
                b_gr  <= (center[0] * 10) + (sum_v_inner << 3) - ((sum_diag + sum_v_outer) << 1) + sum_h_outer;
            end

            if(valid_pipe[3]) begin
                case(phase[1])
                    2'b00: begin // red center
                        red_out   <= center[1];
                        green_out <= g_val;
                        blue_out  <= rb_val;
                    end
                    2'b01: begin // green on red row
                        red_out   <= r_val;
                        green_out <= center[1];
                        blue_out  <= b_val;
                    end
                    2'b10: begin // green on blue row
                        red_out   <= b_val;
                        green_out <= center[1];
                        blue_out  <= r_val;
                    end
                    2'b11: begin // blue center
                        red_out   <= rb_val;
                        green_out <= g_val;
                        blue_out  <= center[1];
                    end
                endcase
            end

        end
    end

    
endmodule