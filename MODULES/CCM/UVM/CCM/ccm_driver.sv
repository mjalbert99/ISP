class ccm_driver extends uvm_driver #(ccm_pkt);
    `uvm_component_utils(ccm_driver)

    virtual ccm_interface CCM_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ccm_interface)::get(null, "", "CCM_IF", CCM_IF))
            `uvm_fatal("CCM_DRV", "FAILED TO GET INTERFACE")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge CCM_IF.cg_drv);
            CCM_IF.cg_drv.resetn       <= req.resetn;
            CCM_IF.cg_drv.coef_in      <= req.coef_in;
            CCM_IF.cg_drv.valid_in     <= req.valid_in;
            CCM_IF.cg_drv.h_sync       <= req.h_sync;
            CCM_IF.cg_drv.v_sync       <= req.v_sync;
            CCM_IF.cg_drv.red_in       <= req.red_in;
            CCM_IF.cg_drv.green_in     <= req.green_in;
            CCM_IF.cg_drv.blue_in      <= req.blue_in;
            CCM_IF.cg_drv.row0         <= req.row0;
            CCM_IF.cg_drv.row1         <= req.row1;
            CCM_IF.cg_drv.row2         <= req.row2;

            seq_item_port.item_done();
        end
    endtask

endclass