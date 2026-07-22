module SRAM10x2048#(
  parameter DATA_WIDTH = 10,
  parameter ADDR_WIDTH = 11,
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

  wire csb0_0 = addr0[10] ? 1'b1 : csb0;
  wire csb0_1 = addr0[10] ? csb0 : 1'b1;

  wire csb1_0 = addr1[10] ? 1'b1 : csb1;
  wire csb1_1 = addr1[10] ? csb1 : 1'b1;

  wire [DATA_WIDTH-1:0] dout1_0;
  wire [DATA_WIDTH-1:0] dout1_1;

  reg dout_sel;
  always @(posedge clk1) begin
    if (!csb1) dout_sel <= addr1[10];
  end

  assign dout1 = dout_sel ? dout1_1 : dout1_0;

  SRAM sram0 (
    .clk0(clk0),
    .csb0(csb0_0),
    .addr0(addr0[9:0]),
    .din0(din0),
    .clk1(clk1),
    .csb1(csb1_0),
    .addr1(addr1[9:0]),
    .dout1(dout1_0)
  );

  SRAM sram1 (
    .clk0(clk0),
    .csb0(csb0_1),
    .addr0(addr0[9:0]),
    .din0(din0),
    .clk1(clk1),
    .csb1(csb1_1),
    .addr1(addr1[9:0]),
    .dout1(dout1_1)
  );

endmodule