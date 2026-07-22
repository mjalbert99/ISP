class bnr_driver extends uvm_driver #(bnr_pkt);
    `uvm_component_utils(bnr_driver)

    virtual bnr_interface BNR_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual bnr_interface)::get(null, "", "BNR_IF", BNR_IF))
            `uvm_fatal("BNR_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge BNR_IF.cg_drv);
            BNR_IF.cg_drv.resetn       <= req.resetn;
            BNR_IF.cg_drv.valid_in     <= req.valid_in;
            BNR_IF.cg_drv.h_sync       <= req.h_sync;
            BNR_IF.cg_drv.v_sync       <= req.v_sync;
            BNR_IF.cg_drv.pixel_in     <= req.pixel_in;

            seq_item_port.item_done();
        end
    endtask

endclass