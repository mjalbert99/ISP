class wbg_monitor extends uvm_monitor;
    `uvm_component_utils(wbg_monitor)

    uvm_analysis_port#(wbg_pkt) mon_port;
    virtual wbg_interface WBG_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual wbg_interface)::get(null, "", "WBG_IF", WBG_IF))
            `uvm_fatal("WBG_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        wbg_pkt pkt;
        forever begin
            @(posedge WBG_IF.cg_mon);
            pkt = wbg_pkt::type_id::create("pkt");
            pkt.resetn          = WBG_IF.cg_mon.resetn;
            pkt.valid_in        = WBG_IF.cg_mon.valid_in;
            pkt.valid_out       = WBG_IF.cg_mon.valid_out;
            pkt.h_sync_out      = WBG_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = WBG_IF.cg_mon.v_sync_out;
            pkt.pixel_in        = WBG_IF.cg_mon.pixel_in;
            pkt.pixel_out       = WBG_IF.cg_mon.pixel_out;
            pkt.row_phase       = WBG_IF.cg_mon.row_phase;
            pkt.col_phase       = WBG_IF.cg_mon.col_phase;

            mon_port.write(pkt);
        end
    endtask

endclass