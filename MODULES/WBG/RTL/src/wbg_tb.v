`timescale 1ns/1ps

module wbg_tb();
    localparam PIXEL_W   = 10;
    localparam FRAME_W   = 16;
    localparam LINE_W    = 16;
    localparam FRAC_BITS = 8;
    localparam R_GAIN    = 384;
    localparam GR_GAIN   = 256;
    localparam GB_GAIN   = 256;
    localparam B_GAIN    = 512;
    localparam MAX_VAL   = (1 << PIXEL_W) - 1;

    reg clk, resetn;
    reg valid_in, h_sync, v_sync;
    reg [PIXEL_W-1:0] pixel_in;
    
    wire valid_out, h_sync_out, v_sync_out;
    wire [PIXEL_W-1:0] pixel_out;

    WBG #(
        .PIXEL_W(PIXEL_W),
        .FRAME_W(FRAME_W),
        .LINE_W(LINE_W),
        .FRAC_BITS(FRAC_BITS),
        .R_GAIN(R_GAIN),
        .GR_GAIN(GR_GAIN),
        .GB_GAIN(GB_GAIN),
        .B_GAIN(B_GAIN)
    ) DUT (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_in),
        .v_sync(v_sync),
        .h_sync(h_sync),
        .pixel_in(pixel_in),
        .valid_out(valid_out),
        .v_sync_out(v_sync_out),
        .h_sync_out(h_sync_out),
        .pixel_out(pixel_out)
    );

    initial clk = 0;
    always #1.5 clk = ~clk;
    
    reg [PIXEL_W-1:0] data;
    reg row, col;
    integer active_gain, exp;
    reg [PIXEL_W-1:0] exp_mem [0:1023]; 
    integer wr_ptr = 0;
    integer rd_ptr = 0;
    integer err_count = 0;

    task send_pixel;
        input [PIXEL_W-1:0] data;
        integer mult_val;
        begin
            pixel_in = data;
            valid_in = 1;
            
            row = DUT.row;
            col = DUT.col;

            case({row, col})
                2'b00: active_gain = R_GAIN;
                2'b01: active_gain = GR_GAIN;
                2'b10: active_gain = GB_GAIN;
                2'b11: active_gain = B_GAIN;
            endcase

            mult_val = data * active_gain;
            exp = mult_val >> FRAC_BITS;
            
            if (exp > MAX_VAL) begin
                exp = MAX_VAL;
            end
            
            exp_mem[wr_ptr] = exp;
            wr_ptr = wr_ptr + 1;
        end
    endtask

    integer i, j;
    initial begin
        resetn   = 0;
        pixel_in = 0; 
        valid_in = 0;
        h_sync   = 0; 
        v_sync   = 0;

        repeat(2) @(posedge clk);
        resetn = 1;
        repeat(2) @(posedge clk);
        
        for(i = 0; i < FRAME_W; i = i + 1) begin
            for(j = 0; j < LINE_W; j = j + 1) begin
                v_sync = (i == 0 && j == 0);
                h_sync = (j == 0);
                
                if(j % 10 == 0)      data = $urandom_range(0, 63);
                else if(j % 10 == 1) data = MAX_VAL;
                else                 data = $random & {PIXEL_W{1'b1}};
                
                send_pixel(data);
                @(posedge clk);
            end
        end
        valid_in = 0;
        repeat(10) @(posedge clk);

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
        $dumpfile("wbg_trace.vcd");
        $dumpvars(0, wbg_tb);
    end
endmodule