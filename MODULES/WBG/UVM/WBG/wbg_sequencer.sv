class wbg_pkt extends uvm_sequence_item;
    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;

    rand logic resetn;
    rand logic valid_in, h_sync, v_sync;
    rand logic[PIXEL_W-1:0] pixel_in;
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] pixel_out;

    logic row_phase, col_phase;

    `uvm_object_utils_begin(wbg_pkt)
        `uvm_field_int(resetn, UVM_ALL_ON)
        `uvm_field_int(valid_in, UVM_ALL_ON)
        `uvm_field_int(h_sync, UVM_ALL_ON)
        `uvm_field_int(v_sync, UVM_ALL_ON)
        `uvm_field_int(pixel_in, UVM_ALL_ON)
        `uvm_field_int(valid_out, UVM_ALL_ON)
        `uvm_field_int(h_sync_out, UVM_ALL_ON)
        `uvm_field_int(v_sync_out, UVM_ALL_ON)
        `uvm_field_int(pixel_out, UVM_ALL_ON)
        `uvm_field_int(row_phase, UVM_ALL_ON)
        `uvm_field_int(col_phase, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pkt");
        super.new(name);
    endfunction

    constraint resetn_sys {(resetn == 0) -> (valid_in == 0);}
endclass

class wbg_base_seq extends uvm_sequence#(wbg_pkt);
    `uvm_object_utils(wbg_base_seq)
  
    localparam LINE_W = 16;
    localparam FRAME_W = 16;

    function new(string name = "wbg_base_seq");
        super.new(name);
    endfunction

    task do_reset();
        repeat(2) begin
            req = wbg_pkt::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 0;})
                `uvm_error("BASE_SEQ", "Randomize failed")
            finish_item(req);
        end
        repeat(2) begin
            req = wbg_pkt::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 1; valid_in == 0;})
                `uvm_error("BASE_SEQ", "Randomize failed")
            finish_item(req);
        end
    endtask


    virtual task body();
        do_reset();
        for(int i = 0; i < (FRAME_W); i++) begin
          for(int j = 0; j < LINE_W; j++) begin
                req = wbg_pkt::type_id::create("req");
                start_item(req);
                if (!req.randomize() with {resetn == 1; valid_in == 1;})
                    `uvm_error("BASE_SEQ", "Randomize failed")
                req.v_sync = (i == 0 && j == 0);
                req.h_sync = (j == 0);

                if(i%2 == 1)
                    req.valid_in = 0;
            
                finish_item(req);
          end
         end
    endtask
endclass


class wbg_sequencer extends uvm_sequencer#(wbg_pkt);
    `uvm_component_utils(wbg_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass