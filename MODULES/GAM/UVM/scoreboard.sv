class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    parameter GAM_W = 16;
    parameter PIXEL_W = 4;

    uvm_analysis_imp#(gam_pkt, scoreboard) mon_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    bit[PIXEL_W-1:0] red_gam[GAM_W];
    bit[PIXEL_W-1:0] green_gam[GAM_W];
    bit[PIXEL_W-1:0] blue_gam[GAM_W];

    bit[PIXEL_W-1:0] red_val[$];
    bit[PIXEL_W-1:0] green_val[$];
    bit[PIXEL_W-1:0] blue_val[$];

    integer gam_idx = 0;
    
    function void write(gam_pkt pkt);
        if(pkt.v_sync) begin
            gam_idx = 0;
            red_val.delete();
            green_val.delete();
            blue_val.delete();
        end

        if(pkt.valid_in) begin
            red_val.push_back(pkt.red_in);
            green_val.push_back(pkt.green_in);
            blue_val.push_back(pkt.blue_in);

            if(gam_idx < GAM_W) begin
                red_gam[gam_idx]   = pkt.gam_red_in;
                green_gam[gam_idx] = pkt.gam_green_in;
                blue_gam[gam_idx]  = pkt.gam_blue_in;
                
                gam_idx++;
            end
        end

       if(pkt.valid_out) begin
            if(red_val.size() < 1 || green_val.size() < 1 || blue_val.size() < 1) begin
                `uvm_error("GAM_SB", "VALUE QUEUES ARE EMPTY")
            end else begin
                bit[PIXEL_W-1:0] red   = red_val.pop_front();
                bit[PIXEL_W-1:0] green = green_val.pop_front();
                bit[PIXEL_W-1:0] blue  = blue_val.pop_front();

                if(red_gam[red] != pkt.red_out || green_gam[green] != pkt.green_out || blue_gam[blue] != pkt.blue_out)
                    `uvm_error("SB_MISMATCH", $sformatf("Mismatch! Exp=R:%0d G:%0d B:%0d | Got=R:%0d G:%0d B:%0d", 
                                red_gam[red], green_gam[green], blue_gam[blue], 
                                pkt.red_out, pkt.green_out, pkt.blue_out))

            end
        end
    endfunction

endclass