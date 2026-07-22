// BLACK LEVEL CORRECTION
// Follows the equation of  (pixel-offset) * (2^n)/(sat_level-offset)
module BLC#(
    parameter PIXEL_W = 10, 
    parameter OFFSET_W = 8, 
    parameter SCALE_INT = 2, 
    parameter FRAC_BITS = 16,
    parameter OFFSET_R = 65,
    parameter OFFSET_Gr = 64, 
    parameter OFFSET_Gb = 63, 
    parameter OFFSET_B = 62
    
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    output reg valid_out, h_sync_out, v_sync_out,
    output reg[PIXEL_W-1:0] pixel_out
);
    localparam MAX_VAL = {PIXEL_W{1'b1}};
    localparam DELAY   = 2;
    
    // (2^n)/(sat_level-offset) Scaling Factor
    localparam SAT_LEVEL       = (1 << PIXEL_W) - 1;
    localparam SCALE_FACTOR_R  = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_R);
    localparam SCALE_FACTOR_Gr = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_Gr);
    localparam SCALE_FACTOR_Gb = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_Gb);
    localparam SCALE_FACTOR_B  = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_B);

    reg row, col;
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            row  <= 0;
            col  <= 0;
        end
        else begin
            if(v_sync) begin 
                row  <= 0;
                col  <= 0;
            end
            else if(h_sync) begin 
                col  <= 0;
                row  <= ~row;
            end
            else if(valid_in)
                col <= ~col;
        end
    end

    reg[OFFSET_W-1:0] active_offset;
    reg[SCALE_INT+FRAC_BITS-1:0] active_scale, scale_pipe;

    always@(*) begin
        case({row, col})
            2'b00: begin
                active_offset = OFFSET_R;
                active_scale  = SCALE_FACTOR_R;
            end
            2'b01: begin
                active_offset = OFFSET_Gr;
                active_scale  = SCALE_FACTOR_Gr;
            end
            2'b10: begin
                active_offset = OFFSET_Gb;
                active_scale  = SCALE_FACTOR_Gb;
            end
            2'b11: begin
                active_offset = OFFSET_B;
                active_scale  = SCALE_FACTOR_B;
            end
        endcase
    end

    reg[PIXEL_W:0] sub_total, sub_pipe;
    reg[DELAY-1:0] valid_pipe, h_pipe, v_pipe;
    reg[PIXEL_W+SCALE_INT+FRAC_BITS-1:0] mult_res;

    integer i;
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            sub_total     <= 0;
            scale_pipe    <= 0;
            sub_pipe      <= 0;
            mult_res      <= 0;
            pixel_out     <= 0;

            for(i = 0; i < DELAY; i = i + 1) begin
                valid_pipe[i] <= 0;
                h_pipe[i]     <= 0;
                v_pipe[i]     <= 0;
            end
        end
        else begin
            
            valid_pipe <= {valid_pipe[DELAY-2:0], valid_in};
            h_pipe     <= {h_pipe[DELAY-2:0], h_sync};
            v_pipe     <= {v_pipe[DELAY-2:0], v_sync};

            valid_out  <= valid_pipe[DELAY-1];
            h_sync_out <= h_pipe[DELAY-1];
            v_sync_out <= v_pipe[DELAY-1];

            sub_total  <= {1'b0, pixel_in} - {{(PIXEL_W-OFFSET_W){1'b0}}, active_offset}; 
            scale_pipe <= active_scale;

            if(valid_pipe[0]) begin
                sub_pipe <= sub_total;
                mult_res <= sub_total[PIXEL_W] ? {(PIXEL_W+SCALE_INT+FRAC_BITS){1'b0}} : sub_total[PIXEL_W-1:0] * scale_pipe;
            end

            if(valid_pipe[1]) begin
                if(sub_pipe[PIXEL_W] == 1'b1) begin
                    pixel_out <= {PIXEL_W{1'b0}};
                end
                else if(mult_res[PIXEL_W+SCALE_INT+FRAC_BITS-1: FRAC_BITS] > {2'b0, MAX_VAL}) begin
                    pixel_out <= MAX_VAL;
                end
                else begin
                    pixel_out <= mult_res[FRAC_BITS+PIXEL_W-1: FRAC_BITS];
                end
            end
        end
        
    end
   
endmodule