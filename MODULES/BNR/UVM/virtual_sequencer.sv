typedef class virtual_sequencer;

class virtual_sequence extends uvm_sequence;
  	`uvm_object_utils(virtual_sequence)

    function new(string name = "virt_seq");
        super.new(name);
    endfunction

    `uvm_declare_p_sequencer(virtual_sequencer)

    bnr_base_seq           seq_normal;

    task body();

      seq_normal = bnr_base_seq::type_id::create("bnr_seq");
      seq_normal.start(p_sequencer.bnr_seqr);

    endtask
endclass

class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    bnr_sequencer bnr_seqr;
endclass
