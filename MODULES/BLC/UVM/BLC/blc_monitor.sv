class blc_monitor extends uvm_monitor;
    `uvm_component_utils(blc_monitor)

    uvm_analysis_port#(blc_pkt) mon_port;
    virtual blc_interface BLC_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual blc_interface)::get(null, "", "BLC_IF", BLC_IF))
            `uvm_fatal("BLC_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        blc_pkt pkt;
        forever begin
            @(posedge BLC_IF.cg_mon);
            pkt = blc_pkt::type_id::create("pkt");
            pkt.resetn          = BLC_IF.cg_mon.resetn;
            pkt.valid_in        = BLC_IF.cg_mon.valid_in;
            pkt.valid_out       = BLC_IF.cg_mon.valid_out;
            pkt.h_sync_out      = BLC_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = BLC_IF.cg_mon.v_sync_out;
            pkt.pixel_in        = BLC_IF.cg_mon.pixel_in;
            pkt.pixel_out       = BLC_IF.cg_mon.pixel_out;
            pkt.row_phase       = BLC_IF.cg_mon.row_phase;
            pkt.col_phase       = BLC_IF.cg_mon.col_phase;

            mon_port.write(pkt);
        end
    endtask

endclass