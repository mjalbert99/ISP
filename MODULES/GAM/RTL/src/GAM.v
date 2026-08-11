module GAM #(
    parameter PIXEL_W = 10,
    parameter LINE_W = 2048,
    parameter FRAME_W = 1080,
    parameter GAM_W   = 1024
)(
    input clk, resetn,
    input valid_in, h_sync, v_sync,
    input[PIXEL_W-1:0] red_in, green_in, blue_in,
    input[PIXEL_W-1:0] gam_red_in, gam_green_in, gam_blue_in,
    output reg valid_out, h_sync_out, v_sync_out,
    output reg[PIXEL_W-1:0] red_out, green_out, blue_out
);
    localparam LINE_CNT  = $clog2(LINE_W);
    localparam FRAME_CNT = $clog2(FRAME_W+2);

    reg[LINE_CNT-1:0] wr_addr, rd_addr;
    reg[FRAME_CNT-1:0] line_count;
    reg[FRAME_CNT+LINE_CNT-1:0] pixel_cnt; 
    
    reg[PIXEL_W-1:0] red_pipe, green_pipe, blue_pipe;
    reg[PIXEL_W-1:0] red_gamma_pipe, green_gamma_pipe, blue_gamma_pipe;
    
    reg valid_pipe, h_sync_pipe, v_sync_pipe;
    reg[1:0] val_shift, h_shift, v_shift;

    wire rd_en = ~valid_in;
    wire wr_en = ~valid_pipe;
    
    wire rd_en_gamma = ~valid_pipe; 
    wire wr_en_gamma = ~(valid_pipe && (line_count == 0) && (wr_addr < GAM_W));

    wire[PIXEL_W-1:0] red_addr, green_addr, blue_addr;
    wire[PIXEL_W-1:0] red_gamma_out, green_gamma_out, blue_gamma_out;

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            wr_addr <= 0;
            rd_addr <= 0;
            line_count <= 0;
            pixel_cnt <= 0;
            
            red_pipe <= 0;
            green_pipe <= 0;
            blue_pipe <= 0;
            red_gamma_pipe <= 0;
            green_gamma_pipe <= 0;
            blue_gamma_pipe <= 0;
            
            valid_pipe <= 0;
            h_sync_pipe <= 0;
            v_sync_pipe <= 0;
        end 
        else begin
            valid_pipe <= valid_in;
            h_sync_pipe <= h_sync;
            v_sync_pipe <= v_sync;

            if(valid_in) begin
                if(v_sync) begin
                    rd_addr <= 1; 
                    pixel_cnt <= 1;
                end 
                else begin
                    rd_addr <= (rd_addr == LINE_W-1) ? 0 : rd_addr + 1'b1;
                    pixel_cnt <= pixel_cnt + 1;
                end

                red_pipe <= red_in;
                green_pipe <= green_in;
                blue_pipe <= blue_in;
                red_gamma_pipe <= gam_red_in;
                green_gamma_pipe <= gam_green_in;
                blue_gamma_pipe <= gam_blue_in;
            end 

            if(valid_pipe) begin
                if(v_sync_pipe) begin
                    wr_addr <= 1;
                    line_count <= 0;
                end 
                else begin
                    wr_addr <= (wr_addr == LINE_W-1) ? 0 : wr_addr + 1'b1;
                    if (wr_addr == LINE_W-1) 
                        line_count <= line_count + 1'b1;
                end
            end
        end
    end

    wire read_trigger = valid_in && (pixel_cnt >= LINE_W);

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            val_shift <= 0;
            h_shift <= 0;
            v_shift <= 0;
            valid_out <= 0;
            h_sync_out <= 0;
            v_sync_out <= 0;
            red_out <= 0;
            green_out <= 0;
            blue_out <= 0;
        end 
        else begin
            val_shift <= {val_shift[0], read_trigger};
            h_shift   <= {h_shift[0], h_sync};
            v_shift   <= {v_shift[0], v_sync};

            valid_out  <= val_shift[1];
            h_sync_out <= h_shift[1];
            v_sync_out <= v_shift[1];
            
            red_out   <= red_gamma_out;
            green_out <= green_gamma_out;
            blue_out  <= blue_gamma_out;
        end
    end

    SRAM10x2048 red_gamma (
        .clk0(clk), 
        .csb0(wr_en_gamma), 
        .addr0(wr_addr), 
        .din0(red_gamma_pipe),
        .clk1(clk), 
        .csb1(rd_en_gamma), 
        .addr1(red_addr), 
        .dout1(red_gamma_out)
    );

    SRAM10x2048 green_gamma (
        .clk0(clk), 
        .csb0(wr_en_gamma), 
        .addr0(wr_addr), 
        .din0(green_gamma_pipe),
        .clk1(clk), 
        .csb1(rd_en_gamma), 
        .addr1(green_addr), 
        .dout1(green_gamma_out)
    );

    SRAM10x2048 blue_gamma (
        .clk0(clk), 
        .csb0(wr_en_gamma), 
        .addr0(wr_addr), 
        .din0(blue_gamma_pipe),
        .clk1(clk), 
        .csb1(rd_en_gamma), 
        .addr1(blue_addr), 
        .dout1(blue_gamma_out)
    );

    SRAM10x2048 red_channel (
        .clk0(clk), 
        .csb0(wr_en), 
        .addr0(wr_addr), 
        .din0(red_pipe),
        .clk1(clk), 
        .csb1(rd_en), 
        .addr1(rd_addr), 
        .dout1(red_addr)
    );

    SRAM10x2048 green_channel (
        .clk0(clk), 
        .csb0(wr_en), 
        .addr0(wr_addr), 
        .din0(green_pipe),
        .clk1(clk), 
        .csb1(rd_en), 
        .addr1(rd_addr), 
        .dout1(green_addr)
    );

    SRAM10x2048 blue_channel (
        .clk0(clk), 
        .csb0(wr_en), .addr0(wr_addr), 
        .din0(blue_pipe),
        .clk1(clk), 
        .csb1(rd_en), 
        .addr1(rd_addr), 
        .dout1(blue_addr)
    );

endmodule