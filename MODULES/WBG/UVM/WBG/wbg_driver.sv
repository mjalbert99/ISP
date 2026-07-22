class wbg_driver extends uvm_driver #(wbg_pkt);
    `uvm_component_utils(wbg_driver)

    virtual wbg_interface WBG_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual wbg_interface)::get(null, "", "WBG_IF", WBG_IF))
            `uvm_fatal("WBG_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge WBG_IF.cg_drv);
            WBG_IF.cg_drv.resetn       <= req.resetn;
            WBG_IF.cg_drv.valid_in     <= req.valid_in;
            WBG_IF.cg_drv.h_sync       <= req.h_sync;
            WBG_IF.cg_drv.v_sync       <= req.v_sync;
            WBG_IF.cg_drv.pixel_in     <= req.pixel_in;

            seq_item_port.item_done();
        end
    endtask

endclass