module gam_tb();
    localparam PIXEL_W = 10;
    localparam LINE_W  = 16;
    localparam FRAME_W = 4;
    localparam GAM_W   = 10;
    localparam MAX_VAL = (1 << PIXEL_W) - 1;

    reg clk, resetn;
    reg valid_in, h_sync, v_sync;
    reg[PIXEL_W-1:0] red_in, green_in, blue_in;
    reg[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in;

    wire valid_out, h_sync_out, v_sync_out;
    wire[PIXEL_W-1:0] red_out, green_out, blue_out;

    GAM #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W),
        .GAM_W(GAM_W)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .red_in(red_in),
        .green_in(green_in),
        .blue_in(blue_in),
        .gam_red_in(gam_red_in),
        .gam_green_in(gam_green_in),
        .gam_blue_in(gam_blue_in),
        .valid_out(valid_out),
        .h_sync_out(h_sync_out),
        .v_sync_out(v_sync_out),
        .red_out(red_out),
        .green_out(green_out),
        .blue_out(blue_out)
    );

    initial clk = 0;
    always #1.5 clk = ~clk;

    reg[PIXEL_W-1:0] LUT_R [0:GAM_W-1];
    reg[PIXEL_W-1:0] LUT_G [0:GAM_W-1];
    reg[PIXEL_W-1:0] LUT_B [0:GAM_W-1];

    integer k;
    initial begin
        for(k = 0; k < GAM_W; k = k + 1) begin
            LUT_R[k] = (k * 2) & MAX_VAL;
            LUT_G[k] = (k * 3) & MAX_VAL;
            LUT_B[k] = (MAX_VAL - k) & MAX_VAL;
        end
    end

    reg[PIXEL_W-1:0] exp_r [0:LINE_W*FRAME_W-1];
    reg[PIXEL_W-1:0] exp_g [0:LINE_W*FRAME_W-1];
    reg[PIXEL_W-1:0] exp_b [0:LINE_W*FRAME_W-1];

    integer wr_ptr = 0;
    integer rd_ptr = 0;
    integer err_count = 0;

    task send_pixel(
        input[PIXEL_W-1:0] r, 
        input[PIXEL_W-1:0] g, 
        input[PIXEL_W-1:0] b, 
        input[PIXEL_W-1:0] gr, 
        input[PIXEL_W-1:0] gg, 
        input[PIXEL_W-1:0] gb, 
        input integer line_idx
    );
        begin
            valid_in     <= 1;
            red_in       <= r;
            green_in     <= g;
            blue_in      <= b;
            gam_red_in   <= gr;
            gam_green_in <= gg;
            gam_blue_in  <= gb;

            exp_r[wr_ptr] = LUT_R[r];
            exp_g[wr_ptr] = LUT_G[g];
            exp_b[wr_ptr] = LUT_B[b];
            wr_ptr = wr_ptr + 1;
        end
    endtask

    integer i, j, timeout;
    reg[PIXEL_W-1:0] rand_red, rand_green, rand_blue;
    reg[PIXEL_W-1:0] gam_r, gam_g, gam_b;

    initial begin
        resetn       = 0;
        valid_in     = 0;
        h_sync       = 0;
        v_sync       = 0;
        red_in       = 0;
        green_in     = 0;
        blue_in      = 0;
        gam_red_in   = 0;
        gam_green_in = 0;
        gam_blue_in  = 0;

        repeat(2) @(posedge clk);
            resetn = 1;
        repeat(2) @(posedge clk);

        for(i = 0; i < FRAME_W; i = i + 1) begin
            for(j = 0; j < LINE_W; j = j + 1) begin
                v_sync = (i == 0 && j == 0);
                h_sync = (j == 0);

                rand_red   = $unsigned($random) % GAM_W;
                rand_green = $unsigned($random) % GAM_W;
                rand_blue  = $unsigned($random) % GAM_W;

                gam_r = (j < GAM_W) ? LUT_R[j] : 0;
                gam_g = (j < GAM_W) ? LUT_G[j] : 0;
                gam_b = (j < GAM_W) ? LUT_B[j] : 0;

                send_pixel(rand_red, rand_green, rand_blue, gam_r, gam_g, gam_b, i);
                @(posedge clk);
            end
        end

        valid_in = 1; 

        timeout = 0;
        while((rd_ptr < wr_ptr) && (timeout < (LINE_W * 3))) begin
            @(posedge clk);
            timeout = timeout + 1;
        end

        valid_in = 0;

        if(err_count == 0)
            $display("SUCCESS: All %0d pixel comparisons passed!", rd_ptr);
        else
            $display("FAILED: Found %0d mismatch errors.", err_count);

        $finish;
    end

    always @(posedge clk) begin
        if(valid_out) begin
            if(red_out !== exp_r[rd_ptr] || green_out !== exp_g[rd_ptr] || blue_out !== exp_b[rd_ptr]) begin
                $display("ERROR at %0t | Pixel #%0d | Expected R:%0d G:%0d B:%0d | Got R:%0d G:%0d B:%0d",
                         $time, rd_ptr, exp_r[rd_ptr], exp_g[rd_ptr], exp_b[rd_ptr], red_out, green_out, blue_out);
                err_count = err_count + 1;
            end
            rd_ptr = rd_ptr + 1;
        end
    end

    initial begin
        $dumpfile("gam_trace.vcd");
        $dumpvars(0, gam_tb);
    end

endmodule