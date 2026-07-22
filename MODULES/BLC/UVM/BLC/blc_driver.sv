class blc_driver extends uvm_driver #(blc_pkt);
    `uvm_component_utils(blc_driver)

    virtual blc_interface BLC_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual blc_interface)::get(null, "", "BLC_IF", BLC_IF))
            `uvm_fatal("BLC_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge BLC_IF.cg_drv);
            BLC_IF.cg_drv.resetn       <= req.resetn;
            BLC_IF.cg_drv.valid_in     <= req.valid_in;
            BLC_IF.cg_drv.h_sync       <= req.h_sync;
            BLC_IF.cg_drv.v_sync       <= req.v_sync;
            BLC_IF.cg_drv.pixel_in     <= req.pixel_in;

            seq_item_port.item_done();
        end
    endtask

endclass