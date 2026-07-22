class lsc_coverage extends uvm_subscriber #(lsc_pkt);
    `uvm_component_utils(lsc_coverage)

    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;
    localparam X_W = $clog2(LINE_W);
    localparam Y_W = $clog2(FRAME_W);

    logic valid_out, h_sync_out, v_sync_out, resetn;
    logic[PIXEL_W-1:0]pixel_in, pixel_out;
    logic[X_W-1:0] x_count, y_count;

    uvm_analysis_imp#(lsc_pkt, lsc_coverage) mon_imp;

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

        x_coors : coverpoint x_count {
            bins vals[4] = {[0:15]};
        }

        y_coors : coverpoint y_count {
            bins vals[4] = {[0:15]};
        }

        coords_cross: cross x_coors, y_coors;
        
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

    function void write(lsc_pkt t);
        this.resetn     = t.resetn;
        this.valid_out  = t.valid_out;
        this.h_sync_out = t.h_sync_out;
        this.v_sync_out = t.v_sync_out;
        this.pixel_in   = t.pixel_in;
        this.pixel_out  = t.pixel_out;
        this.x_count    = t.x_count;
        this.y_count    = t.y_count;
        cg.sample();
    endfunction

     function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("UART_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction     

endclass