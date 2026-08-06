class ccm_pkt extends uvm_sequence_item;
    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;
    localparam COEF_W  = 10;

    rand logic resetn, coef_in;
    rand logic valid_in, h_sync, v_sync;
    rand logic[PIXEL_W-1:0] red_in, green_in, blue_in;
    rand logic[COEF_W-1:0] row0[3], row1[3], row2[3];
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] red_out, green_out, blue_out;

    `uvm_object_utils_begin(ccm_pkt)
        `uvm_field_int(resetn, UVM_ALL_ON)
        `uvm_field_int(coef_in, UVM_ALL_ON)
        `uvm_field_int(valid_in, UVM_ALL_ON)
        `uvm_field_int(h_sync, UVM_ALL_ON)
        `uvm_field_int(v_sync, UVM_ALL_ON)
        `uvm_field_int(red_in, UVM_ALL_ON)
        `uvm_field_int(green_in, UVM_ALL_ON)
        `uvm_field_int(blue_in, UVM_ALL_ON)
        `uvm_field_sarray_int(row0, UVM_ALL_ON)
        `uvm_field_sarray_int(row1, UVM_ALL_ON)
        `uvm_field_sarray_int(row2, UVM_ALL_ON)
        `uvm_field_int(valid_out, UVM_ALL_ON)
        `uvm_field_int(h_sync_out, UVM_ALL_ON)
        `uvm_field_int(v_sync_out, UVM_ALL_ON)
        `uvm_field_int(red_out, UVM_ALL_ON)
        `uvm_field_int(blue_out, UVM_ALL_ON)
        `uvm_field_int(green_out, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pkt");
        super.new(name);
    endfunction

    constraint resetn_sys {(resetn == 0) -> (valid_in == 0);}
endclass

class ccm_base_seq extends uvm_sequence#(ccm_pkt);
    `uvm_object_utils(ccm_base_seq)
  
    localparam LINE_W = 16;
    localparam FRAME_W = 16;

    function new(string name = "ccm_base_seq");
        super.new(name);
    endfunction

    task do_reset();
        repeat(2) begin
            req = ccm_pkt::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 0;})
                `uvm_error("BASE_SEQ", "Randomize failed")
            finish_item(req);
        end
        repeat(2) begin
            req = ccm_pkt::type_id::create("req");
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
                req = ccm_pkt::type_id::create("req");
                start_item(req);
                if (!req.randomize() with {resetn == 1; valid_in == 1;})
                    `uvm_error("BASE_SEQ", "Randomize failed")
                req.v_sync = (i == 0 && j == 0);
                req.h_sync = (j == 0);
                req.coef_in = (i == 0 && j == 0);

                if(i%2 == 1)
                    req.valid_in = 0;
            
                finish_item(req);
          end
         end
    endtask
endclass


class ccm_sequencer extends uvm_sequencer#(ccm_pkt);
    `uvm_component_utils(ccm_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass