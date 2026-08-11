typedef class virtual_sequencer;

class virtual_sequence extends uvm_sequence;
  	`uvm_object_utils(virtual_sequence)

    function new(string name = "virt_seq");
        super.new(name);
    endfunction

    `uvm_declare_p_sequencer(virtual_sequencer)

    gam_base_seq  base_seq;

    virtual task body();
        base_seq = gam_base_seq::type_id::create("base_seq");
        base_seq.start(p_sequencer.gam_seqr);
    endtask
endclass

class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    gam_sequencer gam_seqr;
endclass