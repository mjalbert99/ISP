class demos_coverage extends uvm_subscriber #(demos_pkt);
    `uvm_component_utils(demos_coverage)

    localparam PIXEL_W = 10;

    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0]pixel_in, red_out, green_out, blue_out;
    logic resetn;

    uvm_analysis_imp#(demos_pkt, demos_coverage) mon_imp;

    covergroup cg;

        data_in_range: coverpoint pixel_in{
          bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_rout_range: coverpoint red_out{
          bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_gout_range: coverpoint green_out{
          bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_bout_range: coverpoint blue_out{
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

    function void write(demos_pkt t);
        this.resetn     = t.resetn;
        this.valid_out  = t.valid_out;
        this.h_sync_out = t.h_sync_out;
        this.v_sync_out = t.v_sync_out;
        this.pixel_in   = t.pixel_in;
        this.red_out    = t.red_out;
        this.green_out  = t.green_out;
        this.blue_out   = t.blue_out;
        cg.sample();
    endfunction

     function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("UART_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction     

endclass