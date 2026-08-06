class ccm_coverage extends uvm_subscriber #(ccm_pkt);
    `uvm_component_utils(ccm_coverage)

    localparam PIXEL_W = 10;
    localparam COEF_W = 10;

    logic resetn;
    logic valid_out, h_sync_out, v_sync_out, coef_in;
    logic [PIXEL_W-1:0] red_in, green_in, blue_in;
    
    logic [COEF_W-1:0] row0[3];
    logic [COEF_W-1:0] row1[3];
    logic [COEF_W-1:0] row2[3];

    uvm_analysis_imp#(ccm_pkt, ccm_coverage) mon_imp;

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

        row0_c0: coverpoint row0[0] { bins range[10] = {[0:(2**COEF_W)-1]}; }
        row0_c1: coverpoint row0[1] { bins range[10] = {[0:(2**COEF_W)-1]}; }
        row0_c2: coverpoint row0[2] { bins range[10] = {[0:(2**COEF_W)-1]}; }

        row1_c0: coverpoint row1[0] { bins range[10] = {[0:(2**COEF_W)-1]}; }
        row1_c1: coverpoint row1[1] { bins range[10] = {[0:(2**COEF_W)-1]}; }
        row1_c2: coverpoint row1[2] { bins range[10] = {[0:(2**COEF_W)-1]}; }

        row2_c0: coverpoint row2[0] { bins range[10] = {[0:(2**COEF_W)-1]}; }
        row2_c1: coverpoint row2[1] { bins range[10] = {[0:(2**COEF_W)-1]}; }
        row2_c2: coverpoint row2[2] { bins range[10] = {[0:(2**COEF_W)-1]}; }

        resent_point: coverpoint resetn {
            bins on = {1'b0}; 
            bins off = {1'b1}; 
        }

        coef_in_point: coverpoint coef_in {
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

    function void write(ccm_pkt t);
        this.resetn     = t.resetn;
        this.coef_in    = t.coef_in;
        this.valid_out  = t.valid_out;
        this.h_sync_out = t.h_sync_out;
        this.v_sync_out = t.v_sync_out;
        
        this.red_in     = t.red_in;
        this.green_in   = t.green_in;
        this.blue_in    = t.blue_in;

        this.row0       = t.row0;
        this.row1       = t.row1;
        this.row2       = t.row2;

        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("UART_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction     

endclass