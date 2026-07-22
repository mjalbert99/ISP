class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W   = 10;
    localparam FRAME_W   = 16;
    localparam LINE_W    = 16;

    localparam FRAC_BITS = 8;
    localparam R_GAIN    = 384;
    localparam GR_GAIN   = 256;
    localparam GB_GAIN   = 256;
    localparam B_GAIN    = 512;
    
    localparam MAX_VAL   = (1 << PIXEL_W) - 1;

    uvm_analysis_imp#(wbg_pkt, scoreboard) mon_imp;

    bit[PIXEL_W-1:0] exp_q[$];
    bit[PIXEL_W-1:0] col = 0;
    bit[PIXEL_W-1:0] row = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    integer exp_que[$];

    function void expected_result(bit [PIXEL_W-1:0] in, bit row, bit col);
        integer exp, mult_val, active_gain;

            case({row, col})
                2'b00: active_gain = R_GAIN;
                2'b01: active_gain = GR_GAIN;
                2'b10: active_gain = GB_GAIN;
                2'b11: active_gain = B_GAIN;
            endcase

            mult_val = in * active_gain;
            exp = mult_val >> FRAC_BITS;
            
            if (exp > MAX_VAL) begin
                exp = MAX_VAL;
            end

        exp_que.push_back(exp);

    endfunction

    function void write(wbg_pkt pkt);
        if(pkt.valid_in) begin
            expected_result(pkt.pixel_in, pkt.row_phase, pkt.col_phase);
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