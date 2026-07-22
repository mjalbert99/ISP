`timescale 1ns/1ps

module blc_tb();
    localparam PIXEL_W = 10;
    localparam OFFSET_W = 8;
    localparam SCALE_INT = 2;
    localparam FRAC_BITS = 16;
    localparam LINE_W = 16;
    localparam FRAME_W = 16;

    localparam OFFSET_R = 65;
    localparam OFFSET_Gr = 64;
    localparam OFFSET_Gb = 63;
    localparam OFFSET_B = 62;
    
    localparam SAT_LEVEL   = (1 << PIXEL_W) - 1;
    localparam SCALE_FACTOR_R = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_R);
    localparam SCALE_FACTOR_Gr = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_Gr);
    localparam SCALE_FACTOR_Gb = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_Gb);
    localparam SCALE_FACTOR_B = (1 << PIXEL_W) * (1 << FRAC_BITS)/ (SAT_LEVEL - OFFSET_B);

    reg clk, resetn;
    reg valid_in, h_sync, v_sync;
    reg[PIXEL_W-1:0] pixel_in;
    
    wire valid_out, h_sync_out, v_sync_out;
    wire[PIXEL_W-1:0] pixel_out;

    BLC #(
        .PIXEL_W(PIXEL_W),
        .OFFSET_W(OFFSET_W),
        .SCALE_INT(SCALE_INT),
        .FRAC_BITS(FRAC_BITS),
        .OFFSET_R(OFFSET_R),
        .OFFSET_Gr(OFFSET_Gr),
        .OFFSET_Gb(OFFSET_Gb),
        .OFFSET_B(OFFSET_B)
    ) DUT (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .pixel_in(pixel_in),
        .valid_out(valid_out),
        .h_sync_out(h_sync_out),
        .v_sync_out(v_sync_out),
        .pixel_out(pixel_out)
    );

    initial clk = 0;
    always #1.5 clk = ~clk;
    
    reg[PIXEL_W-1:0] data;
    reg row, col;
    integer active_offset, active_scale, exp;

    reg [PIXEL_W-1:0] exp_mem [0:1023]; 
    integer wr_ptr = 0;
    integer rd_ptr = 0;
    integer err_count = 0;

    task send_pixel;
        input[PIXEL_W-1:0] data;
        integer sub_val, mult_val;
        begin
            pixel_in = data;
            valid_in = 1;
            row = DUT.row;
            col = DUT.col;

            case({row, col})
                2'b00: begin
                    active_offset = OFFSET_R;
                    active_scale  = SCALE_FACTOR_R;
                end
                2'b01: begin
                    active_offset = OFFSET_Gr;
                    active_scale  = SCALE_FACTOR_Gr;
                end
                2'b10: begin
                    active_offset = OFFSET_Gb;
                    active_scale  = SCALE_FACTOR_Gb;
                end
                2'b11: begin
                    active_offset = OFFSET_B;
                    active_scale  = SCALE_FACTOR_B;
                end
            endcase

            sub_val = data - active_offset;
            if (sub_val < 0) begin
                exp = 0;
            end else begin
                mult_val = sub_val * active_scale;
                exp = mult_val >> FRAC_BITS;
                if (exp > SAT_LEVEL) begin
                    exp = SAT_LEVEL;
                end
            end
            
            exp_mem[wr_ptr] = exp;
            wr_ptr = wr_ptr + 1;
        end
    endtask

    integer i, j;
    initial begin
        resetn       = 0;
        pixel_in     = 0; 
        valid_in     = 0;
        h_sync       = 0; 
        v_sync       = 0;

        repeat(2)@(posedge clk);
        resetn = 1;
        repeat(2)@(posedge clk);
        
        for(i = 0; i < FRAME_W; i++) begin
            for(j = 0; j < LINE_W; j++) begin
                v_sync = (i == 0 && j == 0);
                h_sync = (j == 0);
                
                if(j % 10 == 0)      data = $urandom_range(0, 63);
                else if(j % 10 == 1) data = SAT_LEVEL;
                else                  data = $random & {PIXEL_W{1'b1}};
                
                send_pixel(data);
                @(posedge clk);
            end
        end
        valid_in = 0;
        
        repeat(10)@(posedge clk);

        if (err_count == 0) 
            $display("SUCCESS: All %0d checks passed!", rd_ptr);
        else 
            $display("FAILED: Found %0d errors.", err_count);

        $finish;
    end

    always @(posedge clk) begin
        if(valid_out) begin
            if(pixel_out !== exp_mem[rd_ptr]) begin
                $display("ERROR at %0t | Expected: %0d | Got: %0d", $time, exp_mem[rd_ptr], pixel_out);
                err_count = err_count + 1;
            end
            rd_ptr = rd_ptr + 1;
        end
    end
    
    initial begin
        $dumpfile("blc_trace.vcd");
        $dumpvars(0, blc_tb);
    end
endmodule