class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;
    localparam THRESHOLD = 70;

    uvm_analysis_imp#(dpc_pkt, scoreboard) mon_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    bit[PIXEL_W-1:0] ref_image[16][16];
    integer x = 0, y = 0;
    integer i = 0, j = 0;

    function bit[PIXEL_W-1:0] expected_result(integer row, integer col);
        bit [PIXEL_W-1:0] center;
        bit [PIXEL_W-1:0] neigh[8];
        bit [PIXEL_W-1:0] max_n, min_n;
        int sum_n;
        bit is_green, is_hot, is_dead;
        int n;

        if(row < 2 || row >= FRAME_W-2 || col < 2 || col >= LINE_W-2) begin
            return ref_image[row][col];
        end

        center = ref_image[row][col];
        is_green = (col[0] ^ row[0]);

        if (is_green) begin
            neigh[0] = ref_image[row-2][col];
            neigh[1] = ref_image[row-1][col-1];
            neigh[2] = ref_image[row-1][col+1];
            neigh[3] = ref_image[row][col-2];
            neigh[4] = ref_image[row][col+2];
            neigh[5] = ref_image[row+1][col-1];
            neigh[6] = ref_image[row+1][col+1];
            neigh[7] = ref_image[row+2][col];
        end else begin
            neigh[0] = ref_image[row-2][col-2];
            neigh[1] = ref_image[row-2][col];
            neigh[2] = ref_image[row-2][col+2];
            neigh[3] = ref_image[row][col-2];
            neigh[4] = ref_image[row][col+2];
            neigh[5] = ref_image[row+2][col-2];
            neigh[6] = ref_image[row+2][col];
            neigh[7] = ref_image[row+2][col+2];
        end

        sum_n = (neigh[0] + neigh[1] + neigh[2] + neigh[3] +
                 neigh[4] + neigh[5] + neigh[6] + neigh[7]) >> 3;

        max_n = neigh[0];
        min_n = neigh[0];
        for (n = 1; n < 8; n++) begin
            if (neigh[n] > max_n) max_n = neigh[n];
            if (neigh[n] < min_n) min_n = neigh[n];
        end

        is_hot  = (center > max_n) && ((center - max_n) > THRESHOLD);
        is_dead = (center < min_n) && ((min_n - center) > THRESHOLD);

        if (is_hot || is_dead) begin
            return sum_n;
        end else begin
            return center;
        end
    endfunction

    function void write(dpc_pkt pkt);
        if(pkt.valid_in) begin
            ref_image[y][x] = pkt.pixel_in; 
            x++;
            if(x == LINE_W) begin
                x = 0;
                y++;
            end
        end

        if(pkt.valid_out) begin
            bit[PIXEL_W-1:0] exp_val = expected_result(j, i);
            if(pkt.pixel_out !== exp_val) begin
              `uvm_error("SB_MISMATCH", $sformatf("Mismatch!Exp=%0d | Got=%0d  | i=%0d | j=%0d", exp_val, pkt.pixel_out, i, j))
            end

            i++;
            if(i == LINE_W) begin
                i = 0;
                j++;
            end
        end
        
    endfunction

endclass