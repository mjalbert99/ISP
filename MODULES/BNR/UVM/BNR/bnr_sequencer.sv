class bnr_pkt extends uvm_sequence_item;
    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;

    rand logic resetn;
    rand logic valid_in, h_sync, v_sync;
    rand logic[PIXEL_W-1:0] pixel_in;
    logic valid_out, h_sync_out, v_sync_out;
    logic[PIXEL_W-1:0] pixel_out;

    logic[4:0] wr_addr, rd_addr, x_count, y_count;
    logic is_green, is_edge;   

    `uvm_object_utils_begin(bnr_pkt)
        `uvm_field_int(resetn, UVM_ALL_ON)
        `uvm_field_int(valid_in, UVM_ALL_ON)
        `uvm_field_int(h_sync, UVM_ALL_ON)
        `uvm_field_int(v_sync, UVM_ALL_ON)
        `uvm_field_int(pixel_in, UVM_ALL_ON)
        `uvm_field_int(valid_out, UVM_ALL_ON)
        `uvm_field_int(h_sync_out, UVM_ALL_ON)
        `uvm_field_int(v_sync_out, UVM_ALL_ON)
        `uvm_field_int(pixel_out, UVM_ALL_ON)
        `uvm_field_int(wr_addr, UVM_ALL_ON)
        `uvm_field_int(rd_addr, UVM_ALL_ON)
        `uvm_field_int(x_count, UVM_ALL_ON)
        `uvm_field_int(y_count, UVM_ALL_ON)
        `uvm_field_int(is_green, UVM_ALL_ON)
        `uvm_field_int(is_edge, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pkt");
        super.new(name);
    endfunction

    constraint resetn_sys {(resetn == 0) -> (valid_in == 0);}
endclass

class bnr_base_seq extends uvm_sequence#(bnr_pkt);
    `uvm_object_utils(bnr_base_seq)
    
    localparam PIXEL_W = 10;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;
    localparam MAX = {PIXEL_W{1'b1}};

    function new(string name = "bnr_base_seq");
        super.new(name);
    endfunction

    task do_reset();
        repeat(2) begin
            req = bnr_pkt::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 0;})
                `uvm_error("BASE_SEQ", "Randomize failed")
            finish_item(req);
        end
        repeat(2) begin
            req = bnr_pkt::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 1; valid_in == 0;})
                `uvm_error("BASE_SEQ", "Randomize failed")
            finish_item(req);
        end
    endtask


    virtual task body();
        integer count = 0;
        do_reset();
        for(int i = 0; i < (FRAME_W); i++) begin
          for(int j = 0; j < LINE_W; j++) begin
                req = bnr_pkt::type_id::create("req");
                start_item(req);
                if (!req.randomize() with {resetn == 1; valid_in == 1;})
                    `uvm_error("BASE_SEQ", "Randomize failed")
                  req.v_sync = (i == 0 && j == 0);
                  req.h_sync = (j == 0);
            
            
                if(count % 4)
                    req.pixel_in = MAX;
                
                else if(count % 6)
                    req.pixel_in = 0;

                finish_item(req);
                count++;
          end
         end
    endtask
endclass


class bnr_sequencer extends uvm_sequencer#(bnr_pkt);
    `uvm_component_utils(bnr_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass