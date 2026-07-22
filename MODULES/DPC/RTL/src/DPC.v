// 5x5 sliding window algorithm that takes the 8 nearest neighboring pixels
// and uses the average is the pixel is hot, cold, or past a threshold
// 2 row blanking and only corrects internal cells
module DPC#(
    parameter PIXEL_W   = 10,
    parameter LINE_W    = 2048,
    parameter FRAME_W   = 1080,
    parameter THRESHOLD = 70
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] pixel_in,
    output valid_out, h_sync_out, v_sync_out,
    output[PIXEL_W-1:0] pixel_out
);
    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W+2);


// sram 
    reg[LINE_CNT-1:0] wr_addr, rd_addr;
    reg[FRAME_CNT-1:0] line_count;
    reg[PIXEL_W-1:0] pixel_pipe;
    reg valid_pipe, h_pipe, v_pipe;

    wire[PIXEL_W-1:0] dout[3:0];
    wire rd_en = ~valid_in;
    wire wr_en = ~valid_pipe;


    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            wr_addr     <= 0;
            rd_addr     <= 0;
            line_count  <= 0;
            pixel_pipe  <= 0;
            valid_pipe  <= 0;
            h_pipe      <= 0;
            v_pipe      <= 0;
        end
        
        else begin
            valid_pipe <= valid_in;
            h_pipe     <= h_sync;
            v_pipe     <= v_sync;

            if(v_sync) begin
                rd_addr  <= {LINE_CNT{1'b0}};
                wr_addr  <= {LINE_CNT{1'b0}};

            end 
            
            if(valid_in) begin
                rd_addr    <= (rd_addr == LINE_W-1) ? 1'b0 : rd_addr + 1'b1;
                pixel_pipe <= pixel_in;
            end

            if(valid_pipe) begin
                wr_addr    <= (wr_addr == LINE_W-1) ? 1'b0 : wr_addr + 1'b1;
                line_count <= (wr_addr == LINE_W-1) ? line_count + 1'b1 : line_count; 
            end
        end
    end

    SRAM10x2048 sram0 (
        .clk0(clk),
        .csb0(wr_en),
        .addr0(wr_addr),
        .din0(pixel_pipe),
        .clk1(clk),
        .csb1(rd_en),
        .addr1(rd_addr),
        .dout1(dout[0])
    );

    SRAM10x2048 sram1 (
        .clk0(clk),
        .csb0(wr_en),
        .addr0(wr_addr),
        .din0(dout[0]),
        .clk1(clk),
        .csb1(rd_en),
        .addr1(rd_addr),
        .dout1(dout[1])
    );

    SRAM10x2048 sram2 (
        .clk0(clk),
        .csb0(wr_en),
        .addr0(wr_addr),
        .din0(dout[1]),
        .clk1(clk),
        .csb1(rd_en),
        .addr1(rd_addr),
        .dout1(dout[2])
    );

    SRAM10x2048 sram3 (
        .clk0(clk),
        .csb0(wr_en),
        .addr0(wr_addr),
        .din0(dout[2]),
        .clk1(clk),
        .csb1(rd_en),
        .addr1(rd_addr),
        .dout1(dout[3])
    );

    // generate
    //     genvar g;
    //     for(g = 0; g < 3; g = g+1) begin: sram_gen
    //         SRAM10x2048 srams(
    //             .clk0(clk),
    //             .csb0(wr_en),
    //             .addr0(wr_addr),
    //             .din0(dout[g]),
    //             .clk1(clk),
    //             .csb1(rd_en),
    //             .addr1(rd_addr),
    //             .dout1(dout[g+1])
    //         );
    //     end
    // endgenerate

// core
    DPC_CORE #(
        .PIXEL_W(PIXEL_W),
        .LINE_W(LINE_W),
        .FRAME_W(FRAME_W),
        .THRESHOLD(THRESHOLD) 
    ) core (
        .clk(clk),
        .resetn(resetn),
        .valid_in(valid_pipe),
        .h_sync(h_pipe),
        .v_sync(v_pipe),
        .pixel_in(pixel_pipe),
        .sram_in0(dout[0][PIXEL_W-1:0]),
        .sram_in1(dout[1][PIXEL_W-1:0]),
        .sram_in2(dout[2][PIXEL_W-1:0]),
        .sram_in3(dout[3][PIXEL_W-1:0]),
        .valid_out(valid_out),
        .h_sync_out(h_sync_out),
        .v_sync_out(v_sync_out),
        .pixel_out(pixel_out)
    );


endmodule