`timescale 1ns/1ps
module lsc_tb();
    localparam PIXEL_W = 10;
    localparam LINE_W  = 1024;
    localparam FRAME_W = 4;
    localparam C2_R    = 2; 
    localparam C2_Gr   = 2;
    localparam C2_Gb   = 2;
    localparam C2_B    = 2;

    reg clk, resetn;
    reg valid_in, h_sync, v_sync;
    reg[PIXEL_W-1:0] pixel_in;
    wire valid_out, h_sync_out, v_sync_out;
    wire[PIXEL_W-1:0] pixel_out;

    LSC #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W),
        .C2_R(C2_R),
        .C2_Gr(C2_Gr),
        .C2_Gb(C2_Gb),
        .C2_B(C2_B)
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

    task send_pixel;
        input [PIXEL_W-1:0] data;
        input [31:0] count_h;
        begin
            pixel_in = data;
            valid_in = 1;
            h_sync   = (count_h < LINE_W-1) ? 1 : 0; 
        end
    endtask

    reg[31:0] tb_x, tb_y;
    reg[PIXEL_W-1:0] exp_p0, exp_p1, exp_p2, exp_p3, exp_p4, exp_p5, exp_p6;
    
    integer match_count;
    integer error_count;
    integer i, j;
    reg[PIXEL_W-1:0] data;

    reg[31:0] mx, my, dx, dy;
    reg[63:0] r2_val;
    reg[1:0]  sel;
    reg[31:0] c2_val;
    reg[63:0] g_val;
    reg[63:0] prod_val;
    reg[63:0] shift_val;
    reg[PIXEL_W-1:0] clamp_val;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tb_x   <= 0;
            tb_y   <= 0;
            exp_p0 <= 0;
            exp_p1 <= 0;
            exp_p2 <= 0;
            exp_p3 <= 0;
            exp_p4 <= 0;
            exp_p5 <= 0;
            exp_p6 <= 0;
        end 
        else if (v_sync) begin
            tb_x   <= 0;
            tb_y   <= 0;
        end 
        else begin
            exp_p1 <= exp_p0;
            exp_p2 <= exp_p1;
            exp_p3 <= exp_p2;
            exp_p4 <= exp_p3;
            exp_p5 <= exp_p4;
            exp_p6 <= exp_p5;
            
            if(valid_in) begin
                mx = LINE_W / 2;
                my = FRAME_W / 2;
                dx = (tb_x <= mx) ? (mx - tb_x) : (tb_x - mx);
                dy = (tb_y <= my) ? (my - tb_y) : (tb_y - my);
                r2_val = (dx * dx) + (dy * dy);
                sel = {tb_y[0], tb_x[0]};
                
                if(sel == 2'b00)       
                    c2_val = C2_R;
                else if(sel == 2'b01)  
                    c2_val = C2_Gr;
                else if(sel == 2'b10)  
                    c2_val = C2_Gb;
                else                   
                    c2_val = C2_B;
                
                g_val = (1'b1 << 24) + (c2_val * r2_val);
                prod_val = g_val * pixel_in;
                shift_val = prod_val >> 24;
                
                if(shift_val > ((1 << PIXEL_W) - 1)) begin
                    clamp_val = ((1 << PIXEL_W) - 1);
                end 
                else begin
                    clamp_val = shift_val[PIXEL_W-1:0];
                end
                
                exp_p0 <= clamp_val;

                if(tb_x == LINE_W - 1) begin
                    tb_x <= 0;
                    tb_y <= tb_y + 1;
                end 
                else begin
                    tb_x <= tb_x + 1;
                end
            end
        end
    end

    always@(posedge clk) begin
        if(resetn && valid_out) begin
            if(pixel_out === exp_p6) begin
                match_count = match_count + 1;
            end 
            else begin
                $display("[MISMATCH] Time: %0t | Expected: %d, Got: %d", $time, exp_p6, pixel_out);
                error_count = error_count + 1;
            end
        end
    end

    initial begin
        match_count = 0;
        error_count = 0;
        resetn      = 0;
        pixel_in    = 0;
        valid_in    = 0;
        h_sync      = 0;
        v_sync      = 0;
        data        = 0;
        repeat(2)@(posedge clk);
        
        resetn = 1;
        repeat(2)@(posedge clk);
        
        v_sync = 1;
        @(posedge clk);
        v_sync = 0;
        
        for(i = 0; i < FRAME_W; i = i + 1) begin
            for(j = 0; j < LINE_W; j = j + 1) begin
                data = $random & {PIXEL_W{1'b1}};
                send_pixel(data, j);
                @(posedge clk);
            end
            valid_in = 0;
            h_sync   = 0;
            repeat(5)@(posedge clk); 
        end

        valid_in = 0;
        h_sync   = 0;
        repeat(10)@(posedge clk); 

        $display("\n--- SIMULATION REPORT ---");
        $display("Matches: %0d", match_count);
        $display("Errors:  %0d", error_count);
        if(error_count == 0 && match_count > 0) begin
            $display("STATUS:  PASSED");
        end 
        else begin
            $display("STATUS:  FAILED");
        end
        $display("-------------------------\n");

        $finish;
    end
    
    initial begin
        $dumpfile("lsc_trace.vcd");
        $dumpvars(0, lsc_tb);
    end
endmodule