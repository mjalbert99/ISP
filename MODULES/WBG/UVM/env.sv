class env extends uvm_env;
    `uvm_component_utils(env)

    virtual_sequencer virt_seqr;
    scoreboard my_sb;

    wbg_agent my_wbg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        virt_seqr = virtual_sequencer::type_id::create("virt_seqr", this);
        my_sb = scoreboard::type_id::create("my_sb", this);
        my_wbg = wbg_agent::type_id::create("my_wbg", this);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        virt_seqr.wbg_seqr = my_wbg.seqr;
        my_wbg.mon.mon_port.connect(my_sb.mon_imp);
    endfunction
endclass