class gam_driver extends uvm_driver #(gam_pkt);
    `uvm_component_utils(gam_driver)

    virtual gam_interface GAM_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual gam_interface)::get(null, "", "GAM_IF", GAM_IF))
            `uvm_fatal("GAM_DRV", "FAILED TO FETCH INTERFACE")

    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge GAM_IF.cg_drv);
            
            GAM_IF.resetn       <= req.resetn;
            GAM_IF.valid_in     <= req.valid_in;
            GAM_IF.h_sync       <= req.h_sync;
            GAM_IF.v_sync       <= req.v_sync;
            GAM_IF.red_in       <= req.red_in;
            GAM_IF.green_in     <= req.green_in;
            GAM_IF.blue_in      <= req.blue_in;
            GAM_IF.gam_red_in   <= req.gam_red_in;
            GAM_IF.gam_green_in <= req.gam_green_in;
            GAM_IF.gam_blue_in  <= req.gam_blue_in;

            seq_item_port.item_done();
        end
    endtask
endclass