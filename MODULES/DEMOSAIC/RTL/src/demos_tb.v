module demos_tb();

    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;
    localparam DELAY = 4;

    reg clk, resetn, valid_in, h_sync, v_sync;
    reg[PIXEL_W-1:0] pixel_in;
    wire valid_out, h_sync_out, v_sync_out;
    wire[PIXEL_W-1:0] red_out, green_out, blue_out;

    reg[PIXEL_W-1:0] ref_image[FRAME_W-1:0][LINE_W-1:0];

    DEMOSAIC #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W)
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
        .red_out(red_out),
        .green_out(green_out),
        .blue_out(blue_out)
    );

    initial clk = 0;
    always #1.5 clk = ~clk;

    integer x, y, errors;
    integer w_x, w_y;
    integer m, n;
    reg[PIXEL_W-1:0] window [4:0][4:0];
    reg[PIXEL_W-1:0] calc_window [4:0][4:0];
    
    integer C;
    integer sum_cross, sum_diag, sum_h_inner, sum_h_outer, sum_v_inner, sum_v_outer;
    integer g_rb, rb_br, r_gr, b_gr;
    integer exp_r, exp_g, exp_b;
    reg[1:0] phase;

    always@(posedge clk) begin
        if(resetn === 1 && valid_out === 1 && y < FRAME_W) begin
            
            for (m = 0; m < 5; m = m + 1) begin
                for (n = 0; n < 5; n = n + 1) begin
                    w_y = y + (2 - m);
                    w_x = x + (2 - n);
                    
                    if (w_y >= 0 && w_y < FRAME_W && w_x >= 0 && w_x < LINE_W)
                        window[m][n] = ref_image[w_y][w_x];
                    else
                        window[m][n] = 0; 
                end
            end

            for(m = 0; m < 5; m = m + 1) begin
                for(n = 0; n < 5; n = n + 1) begin
                    calc_window[m][n] = window[m][n];
                end
            end

            if(y == 0) begin
                for(n = 0; n < 5; n = n + 1) begin
                    calc_window[4][n] = window[0][n];
                    calc_window[3][n] = window[1][n];
                end
            end
            else if(y == 1) begin
                for(n = 0; n < 5; n = n + 1) begin
                    calc_window[4][n] = window[0][n];
                end
            end
            else if(y == FRAME_W-2) begin
                for(n = 0; n < 5; n = n + 1) begin
                    calc_window[0][n] = window[4][n];
                end
            end
            else if(y == FRAME_W-1) begin
                for(n = 0; n < 5; n = n + 1) begin
                    calc_window[0][n] = window[4][n];
                    calc_window[1][n] = window[3][n];
                end
            end

            if(x == 0) begin
                for(m = 0; m < 5; m = m + 1) begin
                    calc_window[m][4] = calc_window[m][0];
                    calc_window[m][3] = calc_window[m][1];
                end
            end
            else if(x == 1) begin
                for(m = 0; m < 5; m = m + 1) begin
                    calc_window[m][4] = calc_window[m][0];
                end
            end
            else if(x == LINE_W-2) begin
                for(m = 0; m < 5; m = m + 1) begin
                    calc_window[m][0] = calc_window[m][4];
                end
            end
            else if(x == LINE_W-1) begin
                for(m = 0; m < 5; m = m + 1) begin
                    calc_window[m][0] = calc_window[m][4];
                    calc_window[m][1] = calc_window[m][3];
                end
            end

            C           = calc_window[2][2];
            sum_cross   = calc_window[1][2] + calc_window[3][2] + calc_window[2][1] + calc_window[2][3];
            sum_diag    = calc_window[1][1] + calc_window[1][3] + calc_window[3][1] + calc_window[3][3];
            sum_v_outer = calc_window[0][2] + calc_window[4][2];
            sum_v_inner = calc_window[1][2] + calc_window[3][2];
            sum_h_outer = calc_window[2][0] + calc_window[2][4];
            sum_h_inner = calc_window[2][1] + calc_window[2][3];

            g_rb  = (C << 2) + (sum_cross << 1) - (sum_v_outer + sum_h_outer);
            rb_br = (C * 12) + (sum_diag << 2) - ((sum_v_outer + sum_h_outer) * 3);
            r_gr  = (C * 10) + (sum_h_inner << 3) - ((sum_diag + sum_h_outer) << 1) + sum_v_outer;
            b_gr  = (C * 10) + (sum_v_inner << 3) - ((sum_diag + sum_v_outer) << 1) + sum_h_outer;

            g_rb  = g_rb  >>> 3;
            rb_br = rb_br >>> 4;
            r_gr  = r_gr  >>> 4;
            b_gr  = b_gr  >>> 4;

            if (g_rb < 0) g_rb = 0; else if (g_rb > (1<<PIXEL_W)-1) g_rb = (1<<PIXEL_W)-1;
            if (rb_br < 0) rb_br = 0; else if (rb_br > (1<<PIXEL_W)-1) rb_br = (1<<PIXEL_W)-1;
            if (r_gr < 0) r_gr = 0; else if (r_gr > (1<<PIXEL_W)-1) r_gr = (1<<PIXEL_W)-1;
            if (b_gr < 0) b_gr = 0; else if (b_gr > (1<<PIXEL_W)-1) b_gr = (1<<PIXEL_W)-1;

            phase = {y[0], x[0]};
            case(phase)
                2'b00: begin 
                    exp_r = C;
                    exp_g = g_rb;
                    exp_b = rb_br;
                end
                2'b01: begin 
                    exp_r = r_gr;
                    exp_g = C;
                    exp_b = b_gr;
                end
                2'b10: begin 
                    exp_r = b_gr;
                    exp_g = C;
                    exp_b = r_gr;
                end
                2'b11: begin 
                    exp_r = rb_br;
                    exp_g = g_rb;
                    exp_b = C;
                end
            endcase

            if (exp_r !== red_out || exp_g !== green_out || exp_b !== blue_out) begin
                $display("MISMATCH at [X:%0d, Y:%0d] -> EXPECTED: (R:%0d, G:%0d, B:%0d) ACTUAL: (R:%0d, G:%0d, B:%0d)", 
                         x, y, exp_r, exp_g, exp_b, red_out, green_out, blue_out);
                errors = errors + 1;
            end

            x++;
            if(x === LINE_W) begin
                x = 0;
                y++;
            end
        end
    end

    integer i, j;

    initial begin
            x = 0;
            y = 0;

            resetn = 0;
            valid_in = 0;
            h_sync = 0;
            v_sync = 0;
            pixel_in = 0;
            errors = 0;

            for(i = 0; i < FRAME_W; i++)
                for(j = 0; j < LINE_W; j++)
                    ref_image[i][j] = 0;

        @(posedge clk);
            resetn = 1;
        @(posedge clk);

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

        repeat((LINE_W*2)+10) @(posedge clk); // BUFFER FLUSH 

        valid_in = 0;

        #20;
        $display("----------------------------------------");
        if (errors == 0)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED with %0d errors.", errors);
        $display("----------------------------------------");

        $finish;
    end

    initial begin
        $dumpfile("demos_trace.vcd");
        $dumpvars(0, demos_tb);
    end

endmodule