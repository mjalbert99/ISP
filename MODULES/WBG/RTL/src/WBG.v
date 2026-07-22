module WBG #(
    parameter PIXEL_W   = 10,
    parameter FRAME_W   = 1080,
    parameter LINE_W    = 2048,
    parameter FRAC_BITS = 8,
    parameter R_GAIN    = 384,
    parameter GR_GAIN   = 256,
    parameter GB_GAIN   = 256,
    parameter B_GAIN    = 512
)(
    input clk, resetn,
    input valid_in, v_sync, h_sync,
    input[PIXEL_W-1:0] pixel_in,
    output reg valid_out, v_sync_out, h_sync_out,
    output reg[PIXEL_W-1:0] pixel_out
);
    localparam MAX_VAL = {PIXEL_W{1'b1}};
    localparam DELAY   = 1;

    reg row, col;
    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            row <= 0;
            col <= 0;
        end
        else begin
            if(v_sync) begin 
                row <= 0;
                col <= 0;
            end
            else if(h_sync) begin 
                col <= 0;
                row <= ~row;
            end
            else if(valid_in)
                col <= ~col;
        end
    end

    reg[DELAY-1:0] valid_pipe, h_pipe, v_pipe;
    reg[(PIXEL_W + FRAC_BITS + 4)-1:0] res_pipe;

    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            pixel_out  <= 0;
            valid_out  <= 0;
            h_sync_out <= 0;
            v_sync_out <= 0;
            valid_pipe <= 0;
            v_pipe     <= 0;
            h_pipe     <= 0;
            res_pipe   <= 0;
        end
        else begin
            valid_pipe <= {valid_pipe[0], valid_in};
            h_pipe     <= {h_pipe[0], h_sync};
            v_pipe     <= {v_pipe[0], v_sync};

            valid_out  <= valid_pipe[DELAY-1];
            h_sync_out <= h_pipe[DELAY-1];
            v_sync_out <= v_pipe[DELAY-1];

            if(valid_in) begin
                case({row, col})
                    2'b00: res_pipe <= pixel_in * R_GAIN;
                    2'b01: res_pipe <= pixel_in * GR_GAIN;
                    2'b10: res_pipe <= pixel_in * GB_GAIN;
                    2'b11: res_pipe <= pixel_in * B_GAIN;
                endcase
            end

            if(valid_pipe[0]) begin
                if((res_pipe >> FRAC_BITS) > MAX_VAL) begin
                    pixel_out <= MAX_VAL;
                end
                else begin
                    pixel_out <= res_pipe[FRAC_BITS + PIXEL_W - 1 : FRAC_BITS];
                end
            end
        end
    end

endmodule