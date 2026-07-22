class bnr_monitor extends uvm_monitor;
    `uvm_component_utils(bnr_monitor)

    uvm_analysis_port#(bnr_pkt) mon_port;
    virtual bnr_interface BNR_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual bnr_interface)::get(null, "", "BNR_IF", BNR_IF))
            `uvm_fatal("BNR_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        bnr_pkt pkt;
        forever begin
            @(posedge BNR_IF.cg_mon);
            pkt = bnr_pkt::type_id::create("pkt");
            pkt.resetn          = BNR_IF.cg_mon.resetn;
            pkt.valid_in        = BNR_IF.cg_mon.valid_in;
            pkt.valid_out       = BNR_IF.cg_mon.valid_out;
            pkt.h_sync_out      = BNR_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = BNR_IF.cg_mon.v_sync_out;
            pkt.pixel_in        = BNR_IF.cg_mon.pixel_in;
            pkt.pixel_out       = BNR_IF.cg_mon.pixel_out;
            pkt.wr_addr         = BNR_IF.cg_mon.wr_addr;
            pkt.rd_addr         = BNR_IF.cg_mon.rd_addr;
            pkt.is_green        = BNR_IF.cg_mon.is_green;
            pkt.is_edge         = BNR_IF.cg_mon.is_edge;
            pkt.x_count         = BNR_IF.cg_mon.x_count;
            pkt.y_count         = BNR_IF.cg_mon.y_count;

            mon_port.write(pkt);
        end
    endtask

endclass