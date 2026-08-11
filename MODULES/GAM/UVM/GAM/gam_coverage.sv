class gam_coverage extends uvm_subscriber #(gam_pkt);
    `uvm_component_utils(gam_coverage)

    localparam PIXEL_W = 10;

    logic resetn;
    logic[PIXEL_W-1:0] red_in, green_in, blue_in;
    logic[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in;

    logic valid_out, h_sync_out, v_sync_out;

    uvm_analysis_imp#(gam_pkt, gam_coverage) mon_imp;

    covergroup cg;

        data_rin_range: coverpoint red_in {
            bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_gin_range: coverpoint green_in {
            bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_bin_range: coverpoint blue_in {
            bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_grin_range: coverpoint gam_red_in {
            bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_ggin_range: coverpoint gam_green_in {
            bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_gbin_range: coverpoint gam_blue_in {
            bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        resent_point: coverpoint resetn {
            bins on = {1'b0}; 
            bins off = {1'b1}; 
        }

        valid_point: coverpoint valid_out {
            bins on = {1'b0}; 
            bins off = {1'b1}; 
        }

        h_point: coverpoint h_sync_out {
            bins on = {1'b0}; 
            bins off = {1'b1}; 
        }

        v_point: coverpoint v_sync_out {
            bins on = {1'b0}; 
            bins off = {1'b1}; 
        }


        output_sigs: cross valid_out, h_sync_out, v_sync_out;
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    function void write(gam_pkt t);
        this.resetn       = t.resetn;
        this.valid_out    = t.valid_out;
        this.h_sync_out   = t.h_sync_out;
        this.v_sync_out   = t.v_sync_out;
        this.red_in       = t.red_in;
        this.green_in     = t.green_in;
        this.blue_in      = t.blue_in;
        this.gam_red_in   = t.gam_red_in;
        this.gam_green_in = t.gam_green_in;
        this.gam_blue_in  = t.gam_blue_in;
        cg.sample();
    endfunction

     function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("UART_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction     

endclass