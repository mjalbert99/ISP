class dpc_monitor extends uvm_monitor;
    `uvm_component_utils(dpc_monitor)

    uvm_analysis_port#(dpc_pkt) mon_port;
    virtual dpc_interface DPC_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dpc_interface)::get(null, "", "DPC_IF", DPC_IF))
            `uvm_fatal("DPC_MON", "FAILED TO GET INTERFACE")
          mon_port = new("mon_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        dpc_pkt pkt;
        forever begin
            @(posedge DPC_IF.cg_mon);
            pkt = dpc_pkt::type_id::create("pkt");
            pkt.resetn          = DPC_IF.cg_mon.resetn;
            pkt.valid_in        = DPC_IF.cg_mon.valid_in;
            pkt.valid_out       = DPC_IF.cg_mon.valid_out;
            pkt.h_sync_out      = DPC_IF.cg_mon.h_sync_out;
            pkt.v_sync_out      = DPC_IF.cg_mon.v_sync_out;
            pkt.pixel_in        = DPC_IF.cg_mon.pixel_in;
            pkt.pixel_out       = DPC_IF.cg_mon.pixel_out;
            pkt.wr_addr         = DPC_IF.cg_mon.wr_addr;
            pkt.rd_addr         = DPC_IF.cg_mon.rd_addr;
            pkt.is_dead         = DPC_IF.cg_mon.is_dead;
            pkt.is_hot          = DPC_IF.cg_mon.is_hot;
            pkt.is_green        = DPC_IF.cg_mon.is_green;
            pkt.is_edge         = DPC_IF.cg_mon.is_edge;
            pkt.x_count         = DPC_IF.cg_mon.x_count;
            pkt.y_count         = DPC_IF.cg_mon.y_count;

            mon_port.write(pkt);
        end
    endtask

endclass