class demos_driver extends uvm_driver #(demos_pkt);
    `uvm_component_utils(demos_driver)

    virtual demos_interface DEMOS_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual demos_interface)::get(null, "", "DEMOS_IF", DEMOS_IF))
            `uvm_fatal("DEMOS_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge DEMOS_IF.cg_drv);
            DEMOS_IF.cg_drv.resetn       <= req.resetn;
            DEMOS_IF.cg_drv.valid_in     <= req.valid_in;
            DEMOS_IF.cg_drv.h_sync       <= req.h_sync;
            DEMOS_IF.cg_drv.v_sync       <= req.v_sync;
            DEMOS_IF.cg_drv.pixel_in     <= req.pixel_in;

            seq_item_port.item_done();
        end
    endtask

endclass