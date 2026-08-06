class env extends uvm_env;
    `uvm_component_utils(env)

    virtual_sequencer virt_seqr;
    scoreboard my_sb;

    ccm_agent my_ccm;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        virt_seqr = virtual_sequencer::type_id::create("virt_seqr", this);
        my_sb = scoreboard::type_id::create("my_sb", this);
        my_ccm = ccm_agent::type_id::create("my_ccm", this);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        virt_seqr.ccm_seqr = my_ccm.seqr;
        my_ccm.mon.mon_port.connect(my_sb.mon_imp);
    endfunction
endclass