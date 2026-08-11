class gam_monitor extends uvm_monitor;
    `uvm_component_utils(gam_monitor)

    uvm_analysis_port#(gam_pkt) mon_port;
    virtual gam_interface GAM_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual gam_interface)::get(null, "", "GAM_IF", GAM_IF))
            `uvm_fatal("GAM_MON", "FAILED TO FETCH INTERFACE")
        mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gam_pkt pkt;
        forever begin
            @(posedge GAM_IF.cg_mon);
            pkt = gam_pkt::type_id::create("pkt");

            pkt.resetn       = GAM_IF.resetn;
            pkt.valid_in     = GAM_IF.valid_in;
            pkt.h_sync       = GAM_IF.h_sync;
            pkt.v_sync       = GAM_IF.v_sync;
            pkt.red_in       = GAM_IF.red_in;
            pkt.green_in     = GAM_IF.green_in;
            pkt.blue_in      = GAM_IF.blue_in;
            pkt.gam_red_in   = GAM_IF.gam_red_in;
            pkt.gam_green_in = GAM_IF.gam_green_in;
            pkt.gam_blue_in  = GAM_IF.gam_blue_in;
            pkt.valid_out    = GAM_IF.valid_out;
            pkt.h_sync_out   = GAM_IF.h_sync_out;
            pkt.v_sync_out   = GAM_IF.v_sync_out;
            pkt.red_out      = GAM_IF.red_out;
            pkt.green_out    = GAM_IF.green_out;
            pkt.blue_out     = GAM_IF.blue_out;

            mon_port.write(pkt);
        end
    endtask
endclass