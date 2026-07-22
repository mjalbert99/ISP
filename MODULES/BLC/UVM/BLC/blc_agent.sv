class blc_agent extends uvm_agent;
    `uvm_component_utils(blc_agent)

    blc_monitor mon;
    blc_driver drv;
    blc_sequencer seqr;
    blc_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = blc_monitor::type_id::create("mon", this);
        cov = blc_coverage::type_id::create("cov", this);
        if(get_is_active() == UVM_ACTIVE) begin
            drv = blc_driver::type_id::create("drv", this);
            seqr = blc_sequencer::type_id::create("seqr", this);
        end
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.mon_port.connect(cov.mon_imp);
        if(get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass