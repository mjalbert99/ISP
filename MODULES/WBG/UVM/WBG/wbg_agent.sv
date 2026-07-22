class wbg_agent extends uvm_agent;
    `uvm_component_utils(wbg_agent)

    wbg_monitor mon;
    wbg_driver drv;
    wbg_sequencer seqr;
    wbg_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = wbg_monitor::type_id::create("mon", this);
        cov = wbg_coverage::type_id::create("cov", this);
        if(get_is_active() == UVM_ACTIVE) begin
            drv = wbg_driver::type_id::create("drv", this);
            seqr = wbg_sequencer::type_id::create("seqr", this);
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