module bnr_tb();
    parameter PIXEL_W = 10;
    parameter LINE_W = 8;
    parameter FRAME_W = 8;
    parameter THRESHOLD = 70;
    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W);

    reg clk, resetn;
    reg valid_in, h_sync, v_sync;
    reg[PIXEL_W-1:0] pixel_in;
    wire valid_out, h_sync_out, v_sync_out;
    wire[PIXEL_W-1:0] pixel_out;

    BNR #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W),
        .THRESHOLD(THRESHOLD)
    ) DUT (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .pixel_in(pixel_in),
       
        .valid_out(valid_out),
        .h_sync_out(h_sync_out),
        .v_sync_out(v_sync_out),
        .pixel_out(pixel_out)
    );
    always #1.5 clk = ~clk;

    reg[PIXEL_W-1:0] ref_image [0:FRAME_W-1][0:LINE_W-1];
    
    integer out_x = 0;
    integer out_y = 0;
    integer error_count = 0;
    integer expected_pixel = 0;
    
    reg[PIXEL_W-1:0] neighbors[0:7];
    reg[PIXEL_W-1:0] center_pixel;
    
    integer n;
    integer diff;
    integer range_w;
    integer spatial_w;
    integer total_weight;
    integer weighted_total;
    
    integer final_total_weight;
    integer recip; 

    wire is_edge = (out_x < 2 || out_x >= LINE_W-2 || out_y < 2 || out_y >= FRAME_W-2);
    wire is_green = (out_x[0] ^ out_y[0]);

    always@(posedge clk) begin
        if(resetn === 1'b1 && valid_out === 1'b1) begin
            if(v_sync_out && h_sync_out) begin
                out_x = 0;
                out_y = 0;
            end 
            else if(h_sync_out) begin
                out_x = 0;
                out_y = out_y + 1;
            end

            center_pixel = ref_image[out_y][out_x];
            if(is_edge) begin
                expected_pixel = center_pixel;
            end 
            else begin
                if(is_green) begin
                    neighbors[0] = ref_image[out_y-2][out_x];
                    neighbors[1] = ref_image[out_y-1][out_x-1]; 
                    neighbors[2] = ref_image[out_y-1][out_x+1]; 
                    neighbors[3] = ref_image[out_y][out_x-2];   
                    neighbors[4] = ref_image[out_y][out_x+2];   
                    neighbors[5] = ref_image[out_y+1][out_x-1]; 
                    neighbors[6] = ref_image[out_y+1][out_x+1];
                    neighbors[7] = ref_image[out_y+2][out_x];   
                end 
                else begin
                    neighbors[0] = ref_image[out_y-2][out_x-2];
                    neighbors[1] = ref_image[out_y-2][out_x];   
                    neighbors[2] = ref_image[out_y-2][out_x+2]; 
                    neighbors[3] = ref_image[out_y][out_x-2];   
                    neighbors[4] = ref_image[out_y][out_x+2];   
                    neighbors[5] = ref_image[out_y+2][out_x-2]; 
                    neighbors[6] = ref_image[out_y+2][out_x];
                    neighbors[7] = ref_image[out_y+2][out_x+2]; 
                end

                total_weight = 0;
                weighted_total = 0;
                
                for(n = 0; n < 8; n = n + 1) begin
                    if(center_pixel > neighbors[n]) begin
                        diff = center_pixel - neighbors[n];
                    end 
                    else begin
                        diff = neighbors[n] - center_pixel;
                    end
                    
                    if      (diff <= 15)  range_w = 4;
                    else if (diff <= 31)  range_w = 3;
                    else if (diff <= 63)  range_w = 2;
                    else if (diff <= 127) range_w = 1;
                    else                  range_w = 0;
                    if(is_green) begin 
                        case(n)
                            0, 3, 4, 7: spatial_w = 2;
                            1, 2, 5, 6: spatial_w = 3;
                            default:    spatial_w = 0;
                        endcase
                    end 
                    else begin
                        case(n)
                            0, 2, 5, 7: spatial_w = 1;
                            1, 3, 4, 6: spatial_w = 2;
                            default:    spatial_w = 0;
                        endcase
                    end

                    total_weight   = total_weight   + (spatial_w * range_w);
                    weighted_total = weighted_total + (spatial_w * range_w * neighbors[n]);
                end

                final_total_weight = total_weight + 16; 
                
                if(final_total_weight == 0) begin
                    recip = 0;
                end 
                else begin
                    recip = 1024 / final_total_weight;
                end
                
                expected_pixel = ((weighted_total + (center_pixel * 16)) * recip) >> 10;
            end

            if(pixel_out !== expected_pixel) begin
                $display("ERROR at (x=%0d, y=%0d): Expected %0d, Got %0d", out_x, out_y, expected_pixel, pixel_out);
                error_count = error_count + 1;
            end

            out_x = out_x + 1;
        end
    end

    integer i, j;
    initial begin
        clk = 0;
        resetn = 0;
        valid_in = 0;
        h_sync = 0;
        v_sync = 0;
        pixel_in = 0;

        for(i = 0; i < FRAME_W; i++)
            for(j = 0; j < LINE_W; j++)
                ref_image[i][j] = 0;
        @(posedge clk);
        resetn = 1;
        
        @(posedge clk);

        repeat(1) begin
            for(i = 0; i < FRAME_W; i++) begin
                for(j = 0; j < LINE_W; j++) begin
                    valid_in = 1;
                    v_sync = (i == 0 && j == 0);
                    h_sync = (j == 0);
                    
                    pixel_in = $urandom & {PIXEL_W{1'b1}};
                    ref_image[i][j] = pixel_in;
                    @(posedge clk);
                end
            end
            
            pixel_in = 0;
            valid_in = 1; 
            
            repeat((2*LINE_W)-1) @(posedge clk); 
        end

        #20;
        $display("----------------------------------------");
        if (error_count == 0)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED with %0d errors.", error_count);
        $display("----------------------------------------");

        $finish;
    end

    initial begin
        $dumpfile("bnr_trace.vcd");
        $dumpvars(0, bnr_tb);
    end
endmodule