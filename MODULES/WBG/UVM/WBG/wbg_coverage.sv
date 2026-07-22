class wbg_coverage extends uvm_subscriber #(wbg_pkt);
    `uvm_component_utils(wbg_coverage)

    localparam PIXEL_W = 10;

    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0]pixel_in, pixel_out;
    logic row_phase, col_phase, resetn;

    uvm_analysis_imp#(wbg_pkt, wbg_coverage) mon_imp;

    covergroup cg;

        data_in_range: coverpoint pixel_in{
          bins range[10] = {[0:(2**PIXEL_W)-1]};
        }

        data_out_range: coverpoint pixel_out{
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

        row_point: coverpoint row_phase {
            bins even = {1'b0};
            bins odd = {1'b1};
        }

        col_point: coverpoint col_phase {
            bins even = {1'b0};
            bins odd = {1'b1};
        }

        colors: cross row_point, col_point{
            bins R  = binsof(row_point.even) && binsof(col_point.even);
            bins Gr = binsof(row_point.even) && binsof(col_point.odd);
            bins Gb = binsof(row_point.odd)  && binsof(col_point.even);
            bins B  = binsof(row_point.odd)  && binsof(col_point.odd);
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

    function void write(wbg_pkt t);
        this.resetn     = t.resetn;
        this.valid_out  = t.valid_out;
        this.h_sync_out = t.h_sync_out;
        this.v_sync_out = t.v_sync_out;
        this.pixel_in   = t.pixel_in;
        this.pixel_out  = t.pixel_out;
        this.row_phase  = t.row_phase;
        this.col_phase  = t.col_phase;
        cg.sample();
    endfunction

     function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("UART_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction     

endclass