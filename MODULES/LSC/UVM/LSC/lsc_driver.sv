class lsc_driver extends uvm_driver #(lsc_pkt);
    `uvm_component_utils(lsc_driver)

    virtual lsc_interface LSC_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual lsc_interface)::get(null, "", "LSC_IF", LSC_IF))
            `uvm_fatal("LSC_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge LSC_IF.cg_drv);
            LSC_IF.cg_drv.resetn       <= req.resetn;
            LSC_IF.cg_drv.valid_in     <= req.valid_in;
            LSC_IF.cg_drv.h_sync       <= req.h_sync;
            LSC_IF.cg_drv.v_sync       <= req.v_sync;
            LSC_IF.cg_drv.pixel_in     <= req.pixel_in;

            seq_item_port.item_done();
        end
    endtask

endclass