class lsc_monitor extends uvm_monitor;
    `uvm_component_utils(lsc_monitor)

    uvm_analysis_port#(lsc_pkt) mon_port;
    virtual lsc_interface LSC_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual lsc_interface)::get(null, "", "LSC_IF", LSC_IF))
            `uvm_fatal("LSC_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        lsc_pkt pkt;
        forever begin
            @(posedge LSC_IF.cg_mon);
            pkt = lsc_pkt::type_id::create("pkt");
            pkt.resetn          = LSC_IF.cg_mon.resetn;
            pkt.valid_in        = LSC_IF.cg_mon.valid_in;
            pkt.valid_out       = LSC_IF.cg_mon.valid_out;
            pkt.h_sync_out      = LSC_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = LSC_IF.cg_mon.v_sync_out;
            pkt.pixel_in        = LSC_IF.cg_mon.pixel_in;
            pkt.pixel_out       = LSC_IF.cg_mon.pixel_out;
            pkt.x_count         = LSC_IF.cg_mon.x_count;
            pkt.y_count         = LSC_IF.cg_mon.y_count;

            mon_port.write(pkt);
        end
    endtask

endclass