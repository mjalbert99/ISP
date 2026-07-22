`timescale 1ns/1ps
module fifo_tb();

    localparam DATA_W = 10;
    localparam FIFO_D = 8;

    reg clk, resetn;
    reg rd_en, wr_en;
    reg  [DATA_W-1:0] data_in;
    wire [DATA_W-1:0] data_out;
    wire FULL, EMPTY;

    reg [DATA_W-1:0] exp [0:FIFO_D-1];
    integer err_cnt;
    integer i;

    fifo DUT (
        .clk     (clk),
        .resetn  (resetn),
        .rd_en   (rd_en),
        .wr_en   (wr_en),
        .data_in (data_in),
        .data_out(data_out),
        .FULL    (FULL),
        .EMPTY   (EMPTY)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        resetn  = 1;
        rd_en   = 0;
        wr_en   = 0;
        data_in = 0;
        err_cnt = 0;


        exp[0] = 10'h0AA; exp[1] = 10'h0BB;
        exp[2] = 10'h0CC; exp[3] = 10'h0DD;
        exp[4] = 10'h0EE; exp[5] = 10'h0FF;
        exp[6] = 10'h111; exp[7] = 10'h222;

        @(posedge clk);
        #2;
        resetn = 0;
        repeat(2) @(posedge clk);
        #2;
        resetn = 1;
        repeat(2) @(posedge clk);


        #2;
        rd_en = 1;
        @(posedge clk);
        #2;
        rd_en = 0;
        if(EMPTY !== 1'b1) begin
            $display("ERROR [TEST1]: EMPTY should be 1 after read attempt, got %b", EMPTY);
            err_cnt = err_cnt + 1;
        end

        if(data_out !== {DATA_W{1'b0}}) begin
            $display("ERROR [TEST1]: data_out should be 0x000 after read attempt, got 0x%03X", data_out);
            err_cnt = err_cnt + 1;
        end
        repeat(2) @(posedge clk);


        #2;
        wr_en   = 1;
        data_in = 10'h0AA;
        @(posedge clk); #2;
        if(EMPTY !== 1'b0) begin
            $display("ERROR [TEST2]: EMPTY should be 0 after first write, got %b", EMPTY);
            err_cnt = err_cnt + 1;
        end

        if(FULL !== 1'b0) begin
            $display("ERROR [TEST2]: FULL should be 0 after write 1/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end

        data_in = 10'h0BB;
        @(posedge clk); #2;
        if(FULL !== 1'b0) begin
            $display("ERROR [TEST2]: FULL should be 0 after write 2/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end

        data_in = 10'h0CC;
        @(posedge clk); #2;
        if(FULL !== 1'b0) begin
            $display("ERROR [TEST2]: FULL should be 0 after write 3/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end

        data_in = 10'h0DD;
        @(posedge clk); #2;
        wr_en = 0;
        if(EMPTY !== 1'b0 || FULL !== 1'b0) begin
            $display("ERROR [TEST2]: EMPTY=%b FULL=%b after write 4/8, expected EMPTY=0 FULL=0",
                     EMPTY, FULL);
            err_cnt = err_cnt + 1;
        end
        repeat(2) @(posedge clk);


        #2;
        wr_en   = 1;
        data_in = 10'h0EE;
        @(posedge clk); #2;
        if(FULL !== 1'b0) begin
            $display("ERROR [TEST3]: FULL should be 0 after write 5/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end

        data_in = 10'h0FF;
        @(posedge clk); #2;
        if(FULL !== 1'b0) begin
            $display("ERROR [TEST3]: FULL should be 0 after write 6/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end

        data_in = 10'h111;
        @(posedge clk); #2;
        if(FULL !== 1'b0) begin
            $display("ERROR [TEST3]: FULL should be 0 after write 7/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end

        data_in = 10'h222;
        @(posedge clk); #2;
        wr_en = 0;
        if (FULL !== 1'b1) begin
            $display("ERROR [TEST3]: FULL should be 1 after write 8/8, got %b", FULL);
            err_cnt = err_cnt + 1;
        end
        repeat(2) @(posedge clk);


        #2;
        wr_en   = 1;
        data_in = 10'h3FF;
        @(posedge clk);
        #2;
        wr_en = 0;
        if(FULL !== 1'b1) begin
            $display("ERROR [TEST4]: FULL should remain 1 after write attempt, got %b", FULL);
            err_cnt = err_cnt + 1;
        end
        repeat(2) @(posedge clk);

        #2;
        rd_en = 1;
        for(i = 0; i < FIFO_D; i = i + 1) begin
            @(posedge clk); #2;
            if(data_out !== exp[i]) begin
                $display("ERROR [TEST5]: read[%0d] got 0x%03X, expected 0x%03X",
                         i, data_out, exp[i]);
                err_cnt = err_cnt + 1;
            end

            if(i < FIFO_D - 1 && EMPTY !== 1'b0) begin
                $display("ERROR [TEST5]: EMPTY should be 0 after read %0d/%0d, got %b",
                         i + 1, FIFO_D, EMPTY);
                err_cnt = err_cnt + 1;
            end

            if(i == FIFO_D - 1 && EMPTY !== 1'b1) begin
                $display("ERROR [TEST5]: EMPTY should be 1 after last read, got %b", EMPTY);
                err_cnt = err_cnt + 1;
            end
        end
        rd_en = 0;
        repeat(2) @(posedge clk);

        if(err_cnt == 0) 
            $display("ALL TESTS PASSED");
        else 
            $display("%0d ERROR(S) FOUND", err_cnt);

        $finish;
    end

endmodule