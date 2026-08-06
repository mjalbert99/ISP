class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W   = 10;
    localparam FRAME_W   = 16;
    localparam LINE_W    = 16;
    localparam MAX_VAL   = (1 << PIXEL_W) - 1;

    uvm_analysis_imp#(demos_pkt, scoreboard) mon_imp;

    // Reference image buffer
    bit [PIXEL_W-1:0] ref_image[FRAME_W-1:0][LINE_W-1:0];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    // Tracking variables
    integer in_x = 0, in_y = 0;
    integer x = 0, y = 0;
    integer m, n, w_x, w_y;
    
    // Calculation arrays
    bit [PIXEL_W-1:0] window [4:0][4:0];
    bit [PIXEL_W-1:0] calc_window [4:0][4:0];

    // Math variables
    integer C;
    integer sum_cross, sum_diag, sum_h_inner, sum_h_outer, sum_v_inner, sum_v_outer;
    integer g_rb, rb_br, r_gr, b_gr;
    integer exp_r, exp_g, exp_b;
    reg [1:0] phase;

    // Checks packet data against reference model
    function void check_result(demos_pkt pkt);
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

        // Mirror boundaries 
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

        if (g_rb < 0) g_rb = 0; else if (g_rb > MAX_VAL) g_rb = MAX_VAL;
        if (rb_br < 0) rb_br = 0; else if (rb_br > MAX_VAL) rb_br = MAX_VAL;
        if (r_gr < 0) r_gr = 0; else if (r_gr > MAX_VAL) r_gr = MAX_VAL;
        if (b_gr < 0) b_gr = 0; else if (b_gr > MAX_VAL) b_gr = MAX_VAL;

        phase = {y[0], x[0]};
        case(phase)
            2'b00: begin exp_r = C;     exp_g = g_rb;  exp_b = rb_br; end
            2'b01: begin exp_r = r_gr;  exp_g = C;     exp_b = b_gr;  end
            2'b10: begin exp_r = b_gr;  exp_g = C;     exp_b = r_gr;  end
            2'b11: begin exp_r = rb_br; exp_g = g_rb;  exp_b = C;     end
        endcase

        // Trigger UVM error on mismatch
        if (exp_r !== pkt.red_out || exp_g !== pkt.green_out || exp_b !== pkt.blue_out) begin
            `uvm_error("SCBD_MISMATCH", $sformatf("MISMATCH at [X:%0d, Y:%0d] -> EXPECTED: (R:%0d, G:%0d, B:%0d) ACTUAL: (R:%0d, G:%0d, B:%0d)", 
                        x, y, exp_r, exp_g, exp_b, pkt.red_out, pkt.green_out, pkt.blue_out))
        end

        // Increment phase counters
        x++;
        if(x === LINE_W) begin
            x = 0;
            y++;
            if(y === FRAME_W) y = 0;
        end
    endfunction

    // Captures input and triggers output evaluation 
    function void write(demos_pkt pkt);
        if(pkt.valid_in) begin
            ref_image[in_y][in_x] = pkt.pixel_in;
            in_x++;
            if(in_x === LINE_W) begin
                in_x = 0;
                in_y++;
                if(in_y === FRAME_W) in_y = 0;
            end
        end

        if(pkt.valid_out) begin
            check_result(pkt);
        end
    endfunction

endclass