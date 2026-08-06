class env extends uvm_env;
    `uvm_component_utils(env)

    virtual_sequencer virt_seqr;
    scoreboard my_sb;

    demos_agent my_demos;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        virt_seqr = virtual_sequencer::type_id::create("virt_seqr", this);
        my_sb = scoreboard::type_id::create("my_sb", this);
        my_demos = demos_agent::type_id::create("my_demos", this);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        virt_seqr.demos_seqr = my_demos.seqr;
        my_demos.mon.mon_port.connect(my_sb.mon_imp);
    endfunction
endclass