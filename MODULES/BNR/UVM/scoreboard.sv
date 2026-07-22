class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;

    uvm_analysis_imp#(bnr_pkt, scoreboard) mon_imp;

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
        bit is_green, is_edge;
        int n, diff, range_w, spatial_w;
        int total_weight, weighted_total;
        int final_total_weight, recip;

        // check bounds
        is_edge = (row < 2 || row >= FRAME_W-2 || col < 2 || col >= LINE_W-2);
        
        if(is_edge) begin
            return ref_image[row][col];
        end

        center = ref_image[row][col];
        is_green = (col[0] ^ row[0]);

        if(is_green) begin
            neigh[0] = ref_image[row-2][col];
            neigh[1] = ref_image[row-1][col-1];
            neigh[2] = ref_image[row-1][col+1];
            neigh[3] = ref_image[row][col-2];
            neigh[4] = ref_image[row][col+2];
            neigh[5] = ref_image[row+1][col-1];
            neigh[6] = ref_image[row+1][col+1];
            neigh[7] = ref_image[row+2][col];
        end 
        else begin
            neigh[0] = ref_image[row-2][col-2];
            neigh[1] = ref_image[row-2][col];
            neigh[2] = ref_image[row-2][col+2];
            neigh[3] = ref_image[row][col-2];
            neigh[4] = ref_image[row][col+2];
            neigh[5] = ref_image[row+2][col-2];
            neigh[6] = ref_image[row+2][col];
            neigh[7] = ref_image[row+2][col+2];
        end

        total_weight = 0;
        weighted_total = 0;

        for(n = 0; n < 8; n++) begin
            if(center > neigh[n]) diff = center - neigh[n];
            else                   diff = neigh[n] - center;
            
            if(diff <= 15)       range_w = 4;
            else if(diff <= 31)  range_w = 3;
            else if(diff <= 63)  range_w = 2;
            else if(diff <= 127) range_w = 1;
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

            total_weight   += (spatial_w * range_w);
            weighted_total += (spatial_w * range_w * neigh[n]);
        end

        final_total_weight = total_weight + 16; 
        recip = (final_total_weight == 0) ? 0 : (1024 / final_total_weight);
        
        return ((weighted_total + (center * 16)) * recip) >> 10;
    endfunction

    function void write(bnr_pkt pkt);
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