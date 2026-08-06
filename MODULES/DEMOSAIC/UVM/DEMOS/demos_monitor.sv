class demos_monitor extends uvm_monitor;
    `uvm_component_utils(demos_monitor)

    uvm_analysis_port#(demos_pkt) mon_port;
    virtual demos_interface DEMOS_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual demos_interface)::get(null, "", "DEMOS_IF", DEMOS_IF))
            `uvm_fatal("DEMOS_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        demos_pkt pkt;
        forever begin
            @(posedge DEMOS_IF.cg_mon);
            pkt = demos_pkt::type_id::create("pkt");
            pkt.resetn          = DEMOS_IF.cg_mon.resetn;
            pkt.valid_in        = DEMOS_IF.cg_mon.valid_in;
            pkt.valid_out       = DEMOS_IF.cg_mon.valid_out;
            pkt.h_sync_out      = DEMOS_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = DEMOS_IF.cg_mon.v_sync_out;
            pkt.pixel_in        = DEMOS_IF.cg_mon.pixel_in;
            pkt.red_out       	= DEMOS_IF.cg_mon.red_out;
            pkt.green_out       = DEMOS_IF.cg_mon.green_out;
            pkt.blue_out       	= DEMOS_IF.cg_mon.blue_out;

            mon_port.write(pkt);
        end
    endtask

endclass