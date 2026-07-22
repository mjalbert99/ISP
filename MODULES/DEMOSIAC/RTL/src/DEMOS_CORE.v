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
    localparam AVG_W     = $clog2(8*MAX_VAL);
    localparam PAIR_W    = $clog2(2*MAX_VAL);
    localparam DELAY     = ;

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

    reg[DELAY-1:0] valid_pipe, h_pipe, v_pipe;
    reg[DELAY-1:0][1:0] edge_hor_pipe, edge_ver_pipe;
    reg[DELAY-1:0] green_pipe;


    wire is_green        = (y_out[0] ^ x_out[0]);
    wire[1:0]is_hor_edge = {(y_out >= FRAME_W-2), (y_out < 2)};
    wire[1:0]is_ver_edge = {(x_out >= LINE_W-2) , (x_out < 2)};

    wire center_h_sync = (x_out == 0);
    wire center_v_sync = (y_out == 0 && x_out == 0);
    
    integer i, j;

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            valid_pipe    <= 0;
            h_pipe        <= 0;
            v_pipe        <= 0;
            edge_hor_pipe <= 0;
            edge_ver_pipe <= 0;
            green_pipe    <= 0;

            red_out      <= 0;
            green_out    <= 0;
            blue_out     <= 0;
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
            valid_pipe     <= {valid_pipe[DELAY-2:0], valid_gated};
            h_pipe         <= {h_pipe[DELAY-2:0], center_h_sync};
            v_pipe         <= {v_pipe[DELAY-2:0], center_v_sync};
            green_pipe     <= {green_pipe[DELAY-2:0], is_green};
            edge_hor_pipe  <= {edge_hor_pipe[DELAY-2:0], is_hor_edge};
            edge_ver_pipe  <= {edge_ver_pipe[DELAY-2:0], is_ver_edge};

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
                case({{edge_hor_pipe[1], edge_ver_pipe[1]}})    // bottom, top, right, left
                    4'b0000: begin // middle pixel
                    end
                    4'b0001: begin // left
                    end
                    4'b0010: begin // right
                    end
                    4'b0100: begin  // top
                    end
                    4'b0101: begin  // top and left
                    end
                    4'b0110: begin  // top and right
                    end
                    4'b1000: begin // bottom
                    end
                    4'b1001: begin // bottom and left
                    end
                    4'b1010: begin // bottom and right
                    end
                    default: begin
                        
                    end
                endcase
            end
        end
    end
endmodule