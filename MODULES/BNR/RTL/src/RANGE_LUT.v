module RANGE_LUT #(
    parameter DIFF_W   = 10,
    parameter WEIGHT_W = 3
)(
    input[DIFF_W-1:0]   neigh_diff,
    output reg[WEIGHT_W-1:0] range_weight
);
    always @(*) begin
        if      (neigh_diff <= 15)  range_weight = 3'd4;
        else if (neigh_diff <= 31)  range_weight = 3'd3;
        else if (neigh_diff <= 63)  range_weight = 3'd2;
        else if (neigh_diff <= 127) range_weight = 3'd1;
        else                        range_weight = 3'd0;
    end

endmodule