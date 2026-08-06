class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W     = 10;
    localparam COEF_W      = 10;
    localparam FRAC_W      = 8;
    localparam MAX_VAL     = (1 << PIXEL_W) - 1;
    localparam ROUND_CONST = (FRAC_W > 0) ? (1 <<< (FRAC_W-1)) : 0;
    localparam MAX_MULT_W  = PIXEL_W + COEF_W;
    localparam MAX_DIST_W  = MAX_MULT_W + 2;

    uvm_analysis_imp#(ccm_pkt, scoreboard) mon_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    bit [PIXEL_W-1:0] exp_que[$];
    logic[COEF_W-1:0] row0[3], row1[3], row2[3];

    function void calc_expected(bit [PIXEL_W-1:0] red, bit [PIXEL_W-1:0] green, bit [PIXEL_W-1:0] blue);
        bit signed [MAX_MULT_W-1:0] red_mult[2:0], green_mult[2:0], blue_mult[2:0];
        bit signed [MAX_DIST_W-1:0] red_dist, green_dist, blue_dist;
        bit signed [MAX_DIST_W:0]   red_dist_rnd, green_dist_rnd, blue_dist_rnd;
        bit [PIXEL_W-1:0]           red_out, green_out, blue_out;

        bit signed [PIXEL_W:0] r_p = {1'b0, red};
        bit signed [PIXEL_W:0] g_p = {1'b0, green};
        bit signed [PIXEL_W:0] b_p = {1'b0, blue};

        red_mult[0] = r_p * $signed(row0[0]);
        red_mult[1] = g_p * $signed(row0[1]);
        red_mult[2] = b_p * $signed(row0[2]);

        green_mult[0] = r_p * $signed(row1[0]);
        green_mult[1] = g_p * $signed(row1[1]);
        green_mult[2] = b_p * $signed(row1[2]);

        blue_mult[0] = r_p * $signed(row2[0]);
        blue_mult[1] = g_p * $signed(row2[1]);
        blue_mult[2] = b_p * $signed(row2[2]);

        red_dist   = red_mult[0]   + red_mult[1]   + red_mult[2];
        green_dist = green_mult[0] + green_mult[1] + green_mult[2];
        blue_dist  = blue_mult[0]  + blue_mult[1]  + blue_mult[2];

        red_dist_rnd   = {red_dist[MAX_DIST_W-1], red_dist} + ROUND_CONST;
        green_dist_rnd = {green_dist[MAX_DIST_W-1], green_dist} + ROUND_CONST;
        blue_dist_rnd  = {blue_dist[MAX_DIST_W-1], blue_dist} + ROUND_CONST;

        red_out   = (red_dist_rnd[MAX_DIST_W]) ? 0 : (((red_dist_rnd >>> FRAC_W) > MAX_VAL) ? MAX_VAL : (red_dist_rnd >>> FRAC_W));
        green_out = (green_dist_rnd[MAX_DIST_W]) ? 0 : (((green_dist_rnd >>> FRAC_W) > MAX_VAL) ? MAX_VAL : (green_dist_rnd >>> FRAC_W));
        blue_out  = (blue_dist_rnd[MAX_DIST_W]) ? 0 : (((blue_dist_rnd >>> FRAC_W) > MAX_VAL) ? MAX_VAL : (blue_dist_rnd >>> FRAC_W));

        exp_que.push_back(red_out);
        exp_que.push_back(green_out);
        exp_que.push_back(blue_out);
    endfunction

    function void write(ccm_pkt pkt);
      if(pkt.coef_in) begin
            row0 = pkt.row0;
            row1 = pkt.row1;
            row2 = pkt.row2;
        end
        if(pkt.valid_in) begin
            calc_expected(pkt.red_in, pkt.green_in, pkt.blue_in);
        end

        if(pkt.valid_out) begin
            if(exp_que.size() < 3) begin
                `uvm_error("SB_EMPTY", "Unexpected output packet received: Queue is empty or less than 3!")
            end else begin
                int exp_red   = exp_que.pop_front();
                int exp_green = exp_que.pop_front();
                int exp_blue  = exp_que.pop_front();

                if(pkt.red_out !== exp_red || pkt.green_out !== exp_green || pkt.blue_out !== exp_blue) begin
                    `uvm_error("SB_MISMATCH", $sformatf("Mismatch! Exp=R:%0d G:%0d B:%0d | Got=R:%0d G:%0d B:%0d", 
                               exp_red, exp_green, exp_blue, pkt.red_out, pkt.green_out, pkt.blue_out))
                end
            end           
        end
    endfunction
endclass