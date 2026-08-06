module ccm_tb();
    localparam PIXEL_W   = 10;
    localparam LINE_W    = 8;
    localparam FRAME_W   = 8;
    localparam COEF_W    = 10;
    localparam FRAC_W    = 8;
    localparam MAX_VAL   = (1 << PIXEL_W) - 1;
    localparam SAT_LEVEL = MAX_VAL;

    localparam MAX_MULT_W = PIXEL_W + COEF_W;
    localparam MAX_DIST_W = MAX_MULT_W + 2;

    reg clk, resetn;
    reg valid_in, h_sync, v_sync, coef_in;
    reg[PIXEL_W-1:0] red_in, green_in, blue_in;
    reg[(3*COEF_W)-1:0] row0, row1, row2;

    wire valid_out, h_sync_out, v_sync_out;
    wire[PIXEL_W-1:0] red_out, green_out, blue_out;

    CCM #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W),
        .COEF_W(COEF_W),
        .FRAC_W(FRAC_W)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .coef_in(coef_in),
        .red_in(red_in),
        .green_in(green_in),
        .blue_in(blue_in),
        .row0(row0),
        .row1(row1),
        .row2(row2),
        .valid_out(valid_out),
        .h_sync_out(h_sync_out),
        .v_sync_out(v_sync_out),
        .red_out(red_out),
        .green_out(green_out),
        .blue_out(blue_out)
    );

    initial clk = 0;
    always #1.5 clk = ~clk;

    // Row 0: [ 1.20, -0.10, -0.10] -> [ 307, -26, -26]
    // Row 1: [-0.10,  1.20, -0.10] -> [-26,  307, -26]
    // Row 2: [-0.10, -0.10,  1.20] -> [-26, -26,  307]
    reg signed [COEF_W-1:0] c[2:0][2:0];

    initial begin
        c[0][0] = 10'sd307;  c[0][1] = -10'sd26; c[0][2] = -10'sd26;
        c[1][0] = -10'sd26;  c[1][1] = 10'sd307; c[1][2] = -10'sd26;
        c[2][0] = -10'sd26;  c[2][1] = -10'sd26; c[2][2] = 10'sd307;

        row0 = {c[0][2], c[0][1], c[0][0]};
        row1 = {c[1][2], c[1][1], c[1][0]};
        row2 = {c[2][2], c[2][1], c[2][0]};
    end

    function [PIXEL_W-1:0] calc_expected;
        input[PIXEL_W-1:0] r, g, b;
        input signed[COEF_W-1:0] c0, c1, c2;
        reg signed[PIXEL_W:0] r_p, g_p, b_p;
        reg signed[MAX_MULT_W-1:0] m0, m1, m2;
        reg signed[MAX_DIST_W-1:0] dist;
        reg signed[MAX_DIST_W:0] dist_rnd;
        reg signed[MAX_DIST_W:0] shifted;
        begin
            r_p = {1'b0, r};
            g_p = {1'b0, g};
            b_p = {1'b0, b};

            m0 = r_p * c0;
            m1 = g_p * c1;
            m2 = b_p * c2;

            dist = m0 + m1 + m2;
            dist_rnd = {dist[MAX_DIST_W-1], dist} + (1 << (FRAC_W - 1));
            shifted = dist_rnd >>> FRAC_W;

            if(dist_rnd[MAX_DIST_W])
                calc_expected = 0;

            else if(shifted > MAX_VAL)
                calc_expected = MAX_VAL;

            else
                calc_expected = shifted[PIXEL_W-1:0];
        end
    endfunction

    reg[PIXEL_W-1:0] exp_r [0:LINE_W*FRAME_W-1];
    reg[PIXEL_W-1:0] exp_g [0:LINE_W*FRAME_W-1];
    reg[PIXEL_W-1:0] exp_b [0:LINE_W*FRAME_W-1];

    integer wr_ptr = 0;
    integer rd_ptr = 0;
    integer err_count = 0;

    task send_pixel(input [PIXEL_W-1:0] r, input [PIXEL_W-1:0] g, input [PIXEL_W-1:0] b);
        begin
            valid_in <= 1;
            red_in   <= r;
            green_in <= g;
            blue_in  <= b;

            exp_r[wr_ptr] = calc_expected(r, g, b, c[0][0], c[0][1], c[0][2]);
            exp_g[wr_ptr] = calc_expected(r, g, b, c[1][0], c[1][1], c[1][2]);
            exp_b[wr_ptr] = calc_expected(r, g, b, c[2][0], c[2][1], c[2][2]);

            wr_ptr = wr_ptr + 1;
        end
    endtask

    integer i, j;
    reg[PIXEL_W-1:0] rand_red, rand_green, rand_blue;

    initial begin
        resetn   = 0;
        valid_in = 0;
        h_sync   = 0;
        v_sync   = 0;
        coef_in  = 0;
        red_in   = 0;
        green_in = 0;
        blue_in  = 0;

        repeat(2) @(posedge clk);
            resetn = 1;
        repeat(2) @(posedge clk);

            for(i = 0; i < FRAME_W; i = i + 1) begin
                for(j = 0; j < LINE_W; j = j + 1) begin
                    v_sync  = (i == 0 && j == 0);
                    h_sync  = (j == 0);
                    coef_in = (i == 0 && j == 0);

                    rand_red = $random & MAX_VAL;
                    rand_green = $random & MAX_VAL;
                    rand_blue = $random & MAX_VAL;

                    send_pixel(rand_red, rand_green, rand_blue);
                    @(posedge clk);
                end
            end

        valid_in = 0;
        repeat(20) @(posedge clk);

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
        $dumpfile("ccm_trace.vcd");
        $dumpvars(0, ccm_tb);
    end

endmodule