class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W = 10;
    localparam OFFSET_W = 8;
    localparam SCALE_INT = 2;
    localparam FRAC_BITS = 16;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;


    localparam OFFSET_R = 65;
    localparam OFFSET_Gr = 64;
    localparam OFFSET_Gb = 63;
    localparam OFFSET_B = 62;
    
    localparam SAT_LEVEL   = (1 << PIXEL_W) - 1;
    localparam SCALE_FACTOR_R = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_R);
    localparam SCALE_FACTOR_Gr = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_Gr);
    localparam SCALE_FACTOR_Gb = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_Gb);
    localparam SCALE_FACTOR_B = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_B);

    uvm_analysis_imp#(blc_pkt, scoreboard) mon_imp;

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
        integer active_offset, active_scale, exp, sub_val, mult_val;

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
              sub_val = in - active_offset;
            if (sub_val < 0) begin
                exp = 0;
            end else begin
                mult_val = sub_val * active_scale;
                exp = mult_val >> FRAC_BITS;
                if (exp > SAT_LEVEL) begin
                    exp = SAT_LEVEL;
                end
            end

        exp_que.push_back(exp);

    endfunction

    function void write(blc_pkt pkt);
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