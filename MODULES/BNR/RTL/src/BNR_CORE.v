module BNR_CORE #(
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
    localparam MAX_VAL       = {PIXEL_W{1'b1}};
    localparam LINE_CNT      = $clog2(LINE_W);
    localparam FRAME_CNT     = $clog2(FRAME_W+2);
    localparam DELAY         = 10; 
    localparam WEIGHT_W      = 4;
    localparam TOTAL_W       = PIXEL_W + 7;
    localparam CENTER_WEIGHT = 16;


    reg[PIXEL_W-1:0] window[4:0][4:0];

    reg[DELAY-1:0] valid_pipe, h_pipe, v_pipe;
    reg[DELAY-1:0] edge_pipe, green_pipe;
    reg[PIXEL_W-1:0] neighs0[7:0], neighs1[7:0], neigh_diff[7:0]; 
    reg[TOTAL_W-1:0] weighted_neigh[7:0]; 
    reg[WEIGHT_W-1:0] neigh_weight[7:0];

    reg[TOTAL_W-1:0] weighted_total0, weighted_total1, weighted_total2;
    reg[WEIGHT_W+8:0] total_weight0_0, total_weight0_1, total_weight1, total_weight2;

    reg[PIXEL_W-1:0] pixel_pipe[7:0]; 
    reg[TOTAL_W-1:0] final_weighted_total, delayed_weighted_total;
    reg[7:0]         final_total_weight;
    reg[11:0]        current_recip;
    reg[TOTAL_W+11:0] mult_result;

    reg[LINE_CNT-1:0]  x_out;
    reg[FRAME_CNT-1:0] y_out;

    reg[TOTAL_W-1:0] spatial_weight[7:0];

    reg[LINE_CNT-1:0]  x_count;
    reg[FRAME_CNT-1:0] y_count;

    wire valid_gated = (y_count >= 2 && valid_in);
    wire is_green = (y_out[0] ^ x_out[0]);
    wire is_edge  = ((y_out < 2) || (y_out >= FRAME_W-2) || (x_out < 2) || (x_out >= LINE_W-2));
    wire center_h_sync = (x_out == 0);
    wire center_v_sync = (y_out == 0 && x_out == 0);
    wire[2:0] lut_weight_out[7:0];

// coord positions


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

// LUT


    genvar g;
    generate
        for(g = 0; g < 8; g = g + 1) begin : weight_luts
            RANGE_LUT #(
                .DIFF_W(PIXEL_W),
                .WEIGHT_W(3)
            ) range_lut_inst (
                .neigh_diff(neigh_diff[g]),
                .range_weight(lut_weight_out[g])
            );
        end
    endgenerate

// ROM
    reg[11:0] recip_rom[0:127];

    integer r;
    initial begin
        for(r = 0; r < 128; r = r + 1) begin
            if(r == 0) 
                recip_rom[r] = 0;
            else        
                recip_rom[r] = 1024 / r;
        end
    end

// transformation

    
    integer i, j;
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            valid_pipe      <= 0;
            h_pipe          <= 0;
            v_pipe          <= 0;
            edge_pipe       <= 0;
            green_pipe      <= 0;
            weighted_total0 <= 0;
            weighted_total1 <= 0;
            weighted_total2 <= 0;
            total_weight0_0 <= 0;
            total_weight0_1 <= 0;
            total_weight1   <= 0;
            total_weight2   <= 0;
            
            final_weighted_total   <= 0;
            delayed_weighted_total <= 0;
            final_total_weight     <= 0;
            current_recip          <= 0;
            mult_result            <= 0;

            pixel_out    <= 0;
            valid_out    <= 0;
            h_sync_out   <= 0;
            v_sync_out   <= 0;
            
            for(i = 0; i < 8; i++) begin
                pixel_pipe[i] <= 0;
            end
            for(i = 0; i < 5; i++) begin
                for(j = 0; j < 5; j++) begin
                    window[i][j] <= 0;
                end
            end    

            for(i = 0; i < 8; i++) begin
                neigh_diff[i]     <= 0;
                neigh_weight[i]   <= 0;
                weighted_neigh[i] <= 0;
                neighs0[i]        <= 0;
                neighs1[i]        <= 0;
                spatial_weight[i] <= 0;
            end   
        end
        else begin
            valid_pipe  <= {valid_pipe[DELAY-2:0], valid_gated};
            h_pipe      <= {h_pipe[DELAY-2:0], center_h_sync};
            v_pipe      <= {v_pipe[DELAY-2:0], center_v_sync};
            green_pipe  <= {green_pipe[DELAY-2:0], is_green};
            edge_pipe   <= {edge_pipe[DELAY-2:0], is_edge};

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
                if(~edge_pipe[1] && green_pipe[1]) begin
                    neigh_diff[0] <= (window[0][2] > window[2][2]) ? (window[0][2] - window[2][2]) : (window[2][2] - window[0][2]);
                    neigh_diff[1] <= (window[1][1] > window[2][2]) ? (window[1][1] - window[2][2]) : (window[2][2] - window[1][1]);
                    neigh_diff[2] <= (window[1][3] > window[2][2]) ? (window[1][3] - window[2][2]) : (window[2][2] - window[1][3]);
                    neigh_diff[3] <= (window[2][0] > window[2][2]) ? (window[2][0] - window[2][2]) : (window[2][2] - window[2][0]);
                    neigh_diff[4] <= (window[2][4] > window[2][2]) ? (window[2][4] - window[2][2]) : (window[2][2] - window[2][4]);
                    neigh_diff[5] <= (window[3][1] > window[2][2]) ? (window[3][1] - window[2][2]) : (window[2][2] - window[3][1]);
                    neigh_diff[6] <= (window[3][3] > window[2][2]) ? (window[3][3] - window[2][2]) : (window[2][2] - window[3][3]);
                    neigh_diff[7] <= (window[4][2] > window[2][2]) ? (window[4][2] - window[2][2]) : (window[2][2] - window[4][2]);
                    
                    neighs0[0]     <= window[0][2];
                    neighs0[1]     <= window[1][1];
                    neighs0[2]     <= window[1][3];
                    neighs0[3]     <= window[2][0];
                    neighs0[4]     <= window[2][4];
                    neighs0[5]     <= window[3][1];
                    neighs0[6]     <= window[3][3];
                    neighs0[7]     <= window[4][2];

                    spatial_weight[0] <= 2; 
                    spatial_weight[1] <= 3;
                    spatial_weight[2] <= 3;
                    spatial_weight[3] <= 2;
                    spatial_weight[4] <= 2;
                    spatial_weight[5] <= 3;
                    spatial_weight[6] <= 3;
                    spatial_weight[7] <= 2;
                end
                else if(~edge_pipe[1] && ~green_pipe[1]) begin
                    neigh_diff[0] <= (window[0][0] > window[2][2]) ? (window[0][0] - window[2][2]) : (window[2][2] - window[0][0]);
                    neigh_diff[1] <= (window[0][2] > window[2][2]) ? (window[0][2] - window[2][2]) : (window[2][2] - window[0][2]);
                    neigh_diff[2] <= (window[0][4] > window[2][2]) ? (window[0][4] - window[2][2]) : (window[2][2] - window[0][4]);
                    neigh_diff[3] <= (window[2][0] > window[2][2]) ? (window[2][0] - window[2][2]) : (window[2][2] - window[2][0]);
                    neigh_diff[4] <= (window[2][4] > window[2][2]) ? (window[2][4] - window[2][2]) : (window[2][2] - window[2][4]);
                    neigh_diff[5] <= (window[4][0] > window[2][2]) ? (window[4][0] - window[2][2]) : (window[2][2] - window[4][0]);
                    neigh_diff[6] <= (window[4][2] > window[2][2]) ? (window[4][2] - window[2][2]) : (window[2][2] - window[4][2]);
                    neigh_diff[7] <= (window[4][4] > window[2][2]) ? (window[4][4] - window[2][2]) : (window[2][2] - window[4][4]);
                    
                    neighs0[0]     <= window[0][0];
                    neighs0[1]     <= window[0][2];
                    neighs0[2]     <= window[0][4];
                    neighs0[3]     <= window[2][0];
                    neighs0[4]     <= window[2][4];
                    neighs0[5]     <= window[4][0];
                    neighs0[6]     <= window[4][2];
                    neighs0[7]     <= window[4][4];

                    spatial_weight[0] <= 1; 
                    spatial_weight[1] <= 2;
                    spatial_weight[2] <= 1; 
                    spatial_weight[3] <= 2; 
                    spatial_weight[4] <= 2; 
                    spatial_weight[5] <= 1; 
                    spatial_weight[6] <= 2; 
                    spatial_weight[7] <= 1;
                end

                pixel_pipe[0] <= window[2][2];
            end

            if(valid_pipe[2]) begin
                pixel_pipe[1] <= pixel_pipe[0];

                for(i = 0; i < 8; i = i + 1) begin
                    neighs1[i]      <= neighs0[i];
                    neigh_weight[i] <= spatial_weight[i] * lut_weight_out[i];
                end
            end

            if(valid_pipe[3]) begin
                pixel_pipe[2] <= pixel_pipe[1];

                total_weight0_0 <= neigh_weight[7] + neigh_weight[6] + neigh_weight[5] + neigh_weight[4];
                total_weight0_1 <= neigh_weight[3] + neigh_weight[2] + neigh_weight[1] + neigh_weight[0];

                for(i = 0; i < 8; i = i + 1) begin
                    weighted_neigh[i] <= neigh_weight[i] * neighs1[i];
                end
            end

            if(valid_pipe[4]) begin
                pixel_pipe[3] <= pixel_pipe[2];

                total_weight1   <= total_weight0_0 + total_weight0_1;

                weighted_total0 <= weighted_neigh[0] + weighted_neigh[1] + weighted_neigh[2] + weighted_neigh[3];
                weighted_total1 <= weighted_neigh[4] + weighted_neigh[5] + weighted_neigh[6] + weighted_neigh[7];
            end

            if(valid_pipe[5]) begin
                pixel_pipe[4]   <= pixel_pipe[3];
                total_weight2   <= total_weight1;
                weighted_total2 <= weighted_total1 + weighted_total0;
            end


            if(valid_pipe[6]) begin
                pixel_pipe[5] <= pixel_pipe[4];

                final_total_weight   <= total_weight2 + CENTER_WEIGHT;
                final_weighted_total <= weighted_total2 + (pixel_pipe[4] * CENTER_WEIGHT);
            end

            if(valid_pipe[7]) begin
                pixel_pipe[6] <= pixel_pipe[5];

                current_recip          <= recip_rom[final_total_weight];
                delayed_weighted_total <= final_weighted_total;
            end

            if(valid_pipe[8]) begin
                pixel_pipe[7] <= pixel_pipe[6];
                
                mult_result <= delayed_weighted_total * current_recip;
            end

            if(valid_pipe[9]) begin
                if(edge_pipe[9]) begin
                    pixel_out <= pixel_pipe[7];
                end 
                else begin
                    pixel_out <= mult_result >> 10;
                end
            end
        end
    end
endmodule