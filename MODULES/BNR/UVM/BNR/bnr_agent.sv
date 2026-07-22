class bnr_agent extends uvm_agent;
    `uvm_component_utils(bnr_agent)

    bnr_monitor mon;
    bnr_driver drv;
    bnr_sequencer seqr;
    bnr_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = bnr_monitor::type_id::create("mon", this);
        cov = bnr_coverage::type_id::create("cov", this);
        if(get_is_active() == UVM_ACTIVE) begin
            drv = bnr_driver::type_id::create("drv", this);
            seqr = bnr_sequencer::type_id::create("seqr", this);
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