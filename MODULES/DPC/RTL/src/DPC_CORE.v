module DPC_CORE #(
    parameter PIXEL_W   = 10,
    parameter LINE_W    = 2048,
    parameter FRAME_W   = 1080,
    parameter THRESHOLD = 70
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    input[PIXEL_W-1:0] sram_in0, sram_in1, sram_in2, sram_in3,
    output reg valid_out, h_sync_out, v_sync_out,
    output reg[PIXEL_W-1:0] pixel_out
);
    localparam MAX_VAL   = {PIXEL_W{1'b1}};
    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W+2);
    localparam AVG_W     = $clog2(8*MAX_VAL);
    localparam PAIR_W     = $clog2(2*MAX_VAL);

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

// transformation
    reg[PIXEL_W-1:0] window[4:0][4:0];

    reg[3:0]valid_pipe, h_pipe, v_pipe;
    reg[3:0]edge_pipe, green_pipe;

    reg[AVG_W-1:0] neigh_total;
    reg[PIXEL_W-1:0]neigh_max0[3:0], neigh_min0[3:0];
    reg[PIXEL_W-1:0] neigh_max1, neigh_min1;

    reg[PAIR_W-1:0] pair0, pair1, pair2, pair3;

    reg[PIXEL_W-1:0] pixel_pipe[1:0];

    wire is_green = (y_out[0] ^ x_out[0]);
    wire is_edge  = ((y_out < 2) || (y_out >= FRAME_W-2) || (x_out < 2) || (x_out >= LINE_W-2));
    wire center_h_sync = (x_out == 0);
    wire center_v_sync = (y_out == 0 && x_out == 0);
    
    wire is_hot  = (pixel_pipe[1] > neigh_max1) && ((pixel_pipe[1] - neigh_max1) > THRESHOLD);
    wire is_dead = (pixel_pipe[1] < neigh_min1) && ((neigh_min1 - pixel_pipe[1]) > THRESHOLD);

    integer i, j;

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            neigh_total   <= 0;
            neigh_max0[0] <= 0;
            neigh_max0[1] <= 0;
            neigh_max0[2] <= 0;
            neigh_max0[3] <= 0;
            neigh_min0[0] <= 0;
            neigh_min0[1] <= 0;
            neigh_min0[2] <= 0;
            neigh_min0[3] <= 0;
            neigh_max1    <= 0;
            neigh_min1    <= 0;

            pixel_pipe[0] <= 0;
            pixel_pipe[1] <= 0;
            valid_pipe    <= 0;
            h_pipe        <= 0;
            v_pipe        <= 0;
            edge_pipe     <= 0;
            green_pipe    <= 0;

            pair0         <= 0;
            pair1         <= 0;
            pair2         <= 0;
            pair3         <= 0;

            pixel_out    <= 0;
            valid_out    <= 0;
            h_sync_out   <= 0;
            v_sync_out   <= 0;
            for(i = 0; i < 5; i++) begin
                for(j = 0; j < 5; j++) begin
                    window[i][j] <= 0;
                end
            end        
        end
        else begin
            valid_pipe  <= {valid_pipe[2:0], valid_gated};
            h_pipe      <= {h_pipe[2:0], center_h_sync};
            v_pipe      <= {v_pipe[2:0], center_v_sync};
            green_pipe  <= {green_pipe[2:0], is_green};
            edge_pipe   <= {edge_pipe[2:0], is_edge};

            valid_out  <= valid_pipe[3];
            h_sync_out <= h_pipe[3]; 
            v_sync_out <= v_pipe[3];

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
                if(~edge_pipe[1] && green_pipe[1]) begin
                    pair0 <= window[0][2] + window[1][1];
                    pair1 <= window[1][3] + window[2][0];
                    pair2 <= window[2][4] + window[3][1];
                    pair3 <= window[3][3] + window[4][2];

                    neigh_max0[0] <= (window[0][2] > window[1][1]) ? window[0][2] : window[1][1];
                    neigh_max0[1] <= (window[1][3] > window[2][0]) ? window[1][3] : window[2][0];
                    neigh_max0[2] <= (window[2][4] > window[3][1]) ? window[2][4] : window[3][1];
                    neigh_max0[3] <= (window[3][3] > window[4][2]) ? window[3][3] : window[4][2];

                    neigh_min0[0] <= (window[0][2] < window[1][1]) ? window[0][2] : window[1][1];
                    neigh_min0[1] <= (window[1][3] < window[2][0]) ? window[1][3] : window[2][0];
                    neigh_min0[2] <= (window[2][4] < window[3][1]) ? window[2][4] : window[3][1];
                    neigh_min0[3] <= (window[3][3] < window[4][2]) ? window[3][3] : window[4][2];
                end 
                else if(~edge_pipe[1] && ~green_pipe[1]) begin
                    pair0 <= window[0][0] + window[0][2];
                    pair1 <= window[0][4] + window[2][0];
                    pair2 <= window[2][4] + window[4][0];
                    pair3 <= window[4][2] + window[4][4];
                    
                    neigh_max0[0] <= (window[0][0] > window[0][2]) ? window[0][0] : window[0][2];
                    neigh_max0[1] <= (window[0][4] > window[2][0]) ? window[0][4] : window[2][0];
                    neigh_max0[2] <= (window[2][4] > window[4][0]) ? window[2][4] : window[4][0];
                    neigh_max0[3] <= (window[4][2] > window[4][4]) ? window[4][2] : window[4][4];

                    neigh_min0[0] <= (window[0][0] < window[0][2]) ? window[0][0] : window[0][2];
                    neigh_min0[1] <= (window[0][4] < window[2][0]) ? window[0][4] : window[2][0];
                    neigh_min0[2] <= (window[2][4] < window[4][0]) ? window[2][4] : window[4][0];
                    neigh_min0[3] <= (window[4][2] < window[4][4]) ? window[4][2] : window[4][4];
                end
                
                pixel_pipe[0] <= window[2][2];
            end

            if(valid_pipe[2]) begin
                pixel_pipe[1] <= pixel_pipe[0];

                neigh_max1  <=  ((neigh_max0[0] > neigh_max0[1] ? neigh_max0[0] : neigh_max0[1]) > 
                                 (neigh_max0[2] > neigh_max0[3] ? neigh_max0[2] : neigh_max0[3])) ? 
                                (neigh_max0[0] > neigh_max0[1] ? neigh_max0[0] : neigh_max0[1]) : 
                                (neigh_max0[2] > neigh_max0[3] ? neigh_max0[2] : neigh_max0[3]);

                neigh_min1  <=  ((neigh_min0[0] < neigh_min0[1] ? neigh_min0[0] : neigh_min0[1]) < 
                                 (neigh_min0[2] < neigh_min0[3] ? neigh_min0[2] : neigh_min0[3])) ? 
                                (neigh_min0[0] < neigh_min0[1] ? neigh_min0[0] : neigh_min0[1]) : 
                                (neigh_min0[2] < neigh_min0[3] ? neigh_min0[2] : neigh_min0[3]);

                neigh_total <= (pair0 + pair1 + pair2 + pair3) >> 3;
            end

            if(valid_pipe[3]) begin
                if(~edge_pipe[3] && (is_hot || is_dead)) begin
                    pixel_out <= neigh_total[PIXEL_W-1:0];
                end 
                else begin
                    pixel_out <= pixel_pipe[1];
                end
            end
        end
    end
endmodule