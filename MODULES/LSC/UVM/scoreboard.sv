class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W = 10;
    localparam LINE_W  = 16;
    localparam FRAME_W = 16;
    localparam C2_R    = 2; 
    localparam C2_Gr   = 2;
    localparam C2_Gb   = 2;
    parameter C2_B    = 2;

    localparam MAX_VAL = {PIXEL_W{1'b1}};
    localparam DELAY   = 6;

    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W);
    
    localparam MID_X = LINE_W/2;
    localparam MID_Y = FRAME_W/2;

    localparam DX_W = $clog2(MID_X+1);                             
    localparam DY_W = $clog2(MID_Y+1);
    localparam X2_W = $clog2((MID_X**2)) + 1;
    localparam Y2_W = $clog2((MID_Y**2)) + 1;
    localparam R2_W = $clog2((MID_X**2) + (MID_Y**2)) + 1;

    localparam FP_SHIFT = 24; 
    localparam GAIN_W   = R2_W + FP_SHIFT;

    uvm_analysis_imp#(lsc_pkt, scoreboard) mon_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    integer exp_que[$];

    function bit [DX_W-1:0] max_val(bit [DX_W-1:0] a, bit [DX_W-1:0] b);
        return (a > b) ? a : b;
    endfunction

    function bit [DX_W-1:0] min_val(bit [DX_W-1:0] a, bit [DX_W-1:0] b);
        return (a < b) ? a : b;
    endfunction

    reg[DX_W-1:0] x_dist;
    reg[DY_W-1:0] y_dist;
    reg[R2_W-1:0] r2;
    reg[X2_W-1:0] x2;
    reg[Y2_W-1:0] y2;
    reg[R2_W: 0] r2_sc;
    reg[GAIN_W-1:0] gain;
    reg[GAIN_W+PIXEL_W-1:0] product;

    function void expected_result(bit [PIXEL_W-1:0] in, integer row, integer col);
        bit [GAIN_W+PIXEL_W-1:0] shifted;
        bit [PIXEL_W-1:0] clamped;

        x_dist = max_val(col, MID_X) - min_val(col, MID_X); 
        y_dist = max_val(row, MID_Y) - min_val(row, MID_Y); 

        x2 = x_dist**2;
        y2 = y_dist**2;

        r2 = x2 + y2;

        case({row[0], col[0]})
            2'b00: r2_sc = C2_R  * r2;
            2'b01: r2_sc = C2_Gr * r2;
            2'b10: r2_sc = C2_Gb * r2;
            2'b11: r2_sc = C2_B  * r2;
        endcase

        gain = (1 << FP_SHIFT) + r2_sc;

        product = gain * in;
        
        shifted = product >> FP_SHIFT;
        
        if(shifted > MAX_VAL) begin
            clamped = MAX_VAL;
        end else begin
            clamped = shifted[PIXEL_W-1:0];
        end

        exp_que.push_back(clamped);
    endfunction

    function void write(lsc_pkt pkt);

        if(pkt.valid_in) begin
            expected_result(pkt.pixel_in, pkt.x_count, pkt.y_count);
        end

        if(pkt.valid_out) begin
            if(exp_que.size() == 0) begin
                `uvm_error("SB_EMPTY", "Unexpected output packet received: Queue is empty!")
            end else begin
                integer exp_val = exp_que.pop_front();
                if(pkt.pixel_out !== exp_val) begin
                    `uvm_error("SB_MISMATCH", $sformatf("Mismatch!Exp=%0d | Got=%0d", 
                               exp_val, pkt.pixel_out))
                end
            end
        end
        
    endfunction

endclass