module SRAM#(
  parameter DATA_WIDTH = 10,
  parameter ADDR_WIDTH = 10,
  parameter DELAY = 1,
  parameter VERBOSE = 0,
  parameter T_HOLD = 1
)(
  input clk0,
  input csb0,
  input [ADDR_WIDTH-1:0]  addr0,
  input [DATA_WIDTH-1:0]  din0,
  input clk1,
  input csb1,
  input [ADDR_WIDTH-1:0]  addr1,
  output[DATA_WIDTH-1:0] dout1
);

    sram_10x1024  sram (
        .clk0(clk0),
        .csb0(csb0),
        .addr0(addr0),
        .din0(din0),
        .clk1(clk1),
        .csb1(csb1),
        .addr1(addr1),
        .dout1(dout1)
    );

endmodule