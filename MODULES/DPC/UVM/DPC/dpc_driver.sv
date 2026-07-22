class dpc_driver extends uvm_driver #(dpc_pkt);
    `uvm_component_utils(dpc_driver)

    virtual dpc_interface DPC_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dpc_interface)::get(null, "", "DPC_IF", DPC_IF))
            `uvm_fatal("DPC_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge DPC_IF.cg_drv);
            DPC_IF.cg_drv.resetn       <= req.resetn;
            DPC_IF.cg_drv.valid_in     <= req.valid_in;
            DPC_IF.cg_drv.h_sync       <= req.h_sync;
            DPC_IF.cg_drv.v_sync       <= req.v_sync;
            DPC_IF.cg_drv.pixel_in     <= req.pixel_in;

            seq_item_port.item_done();
        end
    endtask

endclass