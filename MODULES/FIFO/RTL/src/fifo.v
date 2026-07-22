module fifo#(parameter DATA_W = 10, parameter FIFO_D = 8)(
    input clk, resetn,
    input rd_en, wr_en,
    input[DATA_W-1:0] data_in,
    output reg[DATA_W-1:0] data_out,
    output FULL, EMPTY
);
    localparam FIFO_CNT = $clog2(FIFO_D);

    reg[FIFO_CNT:0] rd_ptr;
    reg[FIFO_CNT:0] wr_ptr;

    reg[DATA_W-1:0] data[FIFO_D-1:0];

    assign EMPTY = (rd_ptr == wr_ptr);
    assign FULL  = (rd_ptr[FIFO_CNT] != wr_ptr[FIFO_CNT]) && 
                   (rd_ptr[FIFO_CNT-1:0] == wr_ptr[FIFO_CNT-1:0]);

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            rd_ptr   <= {(FIFO_CNT+1){1'b0}};
            data_out <= {DATA_W{1'b0}};
        end
        else begin
            if(rd_en && !EMPTY) begin
                data_out <= data[rd_ptr[FIFO_CNT-1:0]];
                rd_ptr   <= rd_ptr + 1'b1;
            end
        end
    end
    
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            wr_ptr <= {(FIFO_CNT+1){1'b0}};
        end
        else begin 
            if(wr_en && !FULL) begin
                data[wr_ptr[FIFO_CNT-1:0]] <= data_in;
                wr_ptr                     <= wr_ptr + 1'b1;
            end
        end
    end

endmodule