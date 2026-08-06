class ccm_monitor extends uvm_monitor;
    `uvm_component_utils(ccm_monitor)

    uvm_analysis_port#(ccm_pkt) mon_port;
    virtual ccm_interface CCM_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ccm_interface)::get(null, "", "CCM_IF", CCM_IF))
            `uvm_fatal("CCM_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        ccm_pkt pkt;
        forever begin
            @(posedge CCM_IF.cg_mon);
            pkt = ccm_pkt::type_id::create("pkt");
            pkt.resetn          = CCM_IF.cg_mon.resetn;
            pkt.coef_in         = CCM_IF.cg_mon.coef_in;
            pkt.valid_in        = CCM_IF.cg_mon.valid_in;
            pkt.valid_out       = CCM_IF.cg_mon.valid_out;
            pkt.h_sync_out      = CCM_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = CCM_IF.cg_mon.v_sync_out;
            pkt.red_in       	= CCM_IF.cg_mon.red_in;
            pkt.green_in        = CCM_IF.cg_mon.green_in;
            pkt.blue_in       	= CCM_IF.cg_mon.blue_in;
            pkt.red_out       	= CCM_IF.cg_mon.red_out;
            pkt.green_out       = CCM_IF.cg_mon.green_out;
            pkt.blue_out       	= CCM_IF.cg_mon.blue_out;
            pkt.row0      	    = CCM_IF.cg_mon.row0;
            pkt.row1      	    = CCM_IF.cg_mon.row1;
            pkt.row2      	    = CCM_IF.cg_mon.row2;

            mon_port.write(pkt);
        end
    endtask

endclass