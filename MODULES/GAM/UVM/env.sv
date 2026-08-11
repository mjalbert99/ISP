class env extends uvm_env;
    `uvm_component_utils(env)

    gam_agent agent;
    scoreboard sb;
    virtual_sequencer virt_seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent     = gam_agent::type_id::create("agent", this);
        sb        = scoreboard::type_id::create("sb", this);
        virt_seqr = virtual_sequencer::type_id::create("virt_seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.mon.mon_port.connect(sb.mon_imp);
        virt_seqr.gam_seqr = agent.seqr;
    endfunction
endclass