module WBG (clk,
    h_sync,
    h_sync_out,
    resetn,
    v_sync,
    v_sync_out,
    valid_in,
    valid_out,
    pixel_in,
    pixel_out,
    VSS,
    VDD);
 input clk;
 input h_sync;
 output h_sync_out;
 input resetn;
 input v_sync;
 output v_sync_out;
 input valid_in;
 output valid_out;
 input [9:0] pixel_in;
 output [9:0] pixel_out;
 inout VSS;
 inout VDD;

 wire _106_;
 wire _107_;
 wire _108_;
 wire _109_;
 wire _110_;
 wire _111_;
 wire _112_;
 wire _113_;
 wire _114_;
 wire _115_;
 wire _116_;
 wire _117_;
 wire _118_;
 wire _119_;
 wire _120_;
 wire _121_;
 wire _122_;
 wire _123_;
 wire _124_;
 wire _125_;
 wire _126_;
 wire _127_;
 wire _128_;
 wire _131_;
 wire _132_;
 wire _133_;
 wire _134_;
 wire _135_;
 wire _136_;
 wire _137_;
 wire _138_;
 wire _139_;
 wire _140_;
 wire _141_;
 wire _142_;
 wire _143_;
 wire _144_;
 wire _145_;
 wire _146_;
 wire _147_;
 wire _148_;
 wire _149_;
 wire _150_;
 wire _151_;
 wire _152_;
 wire _153_;
 wire _154_;
 wire _155_;
 wire _156_;
 wire _157_;
 wire _158_;
 wire _159_;
 wire _160_;
 wire _161_;
 wire _162_;
 wire _163_;
 wire _164_;
 wire _165_;
 wire _166_;
 wire _167_;
 wire _168_;
 wire _169_;
 wire _170_;
 wire _171_;
 wire _172_;
 wire _173_;
 wire _174_;
 wire _175_;
 wire _176_;
 wire _177_;
 wire _178_;
 wire _179_;
 wire _180_;
 wire _181_;
 wire _182_;
 wire _183_;
 wire _184_;
 wire _185_;
 wire _186_;
 wire _187_;
 wire _188_;
 wire _189_;
 wire _190_;
 wire _191_;
 wire _192_;
 wire _193_;
 wire _194_;
 wire _195_;
 wire _196_;
 wire _197_;
 wire _198_;
 wire _199_;
 wire _200_;
 wire _201_;
 wire _202_;
 wire _203_;
 wire _204_;
 wire _205_;
 wire _206_;
 wire _207_;
 wire _208_;
 wire _209_;
 wire _210_;
 wire _211_;
 wire _212_;
 wire _213_;
 wire _214_;
 wire _215_;
 wire _216_;
 wire _217_;
 wire _218_;
 wire _219_;
 wire _220_;
 wire _221_;
 wire _222_;
 wire _223_;
 wire _224_;
 wire _260_;
 wire _261_;
 wire _262_;
 wire _263_;
 wire _264_;
 wire _265_;
 wire _266_;
 wire _267_;
 wire _268_;
 wire _269_;
 wire _270_;
 wire _271_;
 wire _272_;
 wire _273_;
 wire _274_;
 wire _275_;
 wire _276_;
 wire _277_;
 wire _278_;
 wire _279_;
 wire _280_;
 wire _281_;
 wire _282_;
 wire _283_;
 wire _284_;
 wire _285_;
 wire _286_;
 wire _287_;
 wire _288_;
 wire _289_;
 wire _290_;
 wire _291_;
 wire _292_;
 wire _293_;
 wire _294_;
 wire _295_;
 wire _296_;
 wire _297_;
 wire _298_;
 wire col;
 wire row;
 wire net1;
 wire net2;
 wire clknet_0_clk;
 wire clknet_2_0__leaf_clk;
 wire clknet_2_1__leaf_clk;
 wire clknet_2_2__leaf_clk;
 wire clknet_2_3__leaf_clk;
 wire net3;
 wire net4;
 wire [0:0] h_pipe;
 wire [18:0] res_pipe;
 wire [0:0] v_pipe;
 wire [0:0] valid_pipe;

 FILLCELL_X32 FILLER_0_0 ();
 FILLCELL_X8 FILLER_0_117 ();
 FILLCELL_X8 FILLER_0_129 ();
 FILLCELL_X1 FILLER_0_137 ();
 FILLCELL_X1 FILLER_0_138 ();
 FILLCELL_X1 FILLER_0_139 ();
 FILLCELL_X32 FILLER_0_32 ();
 FILLCELL_X16 FILLER_0_64 ();
 FILLCELL_X1 FILLER_0_80 ();
 FILLCELL_X1 FILLER_0_81 ();
 FILLCELL_X32 FILLER_0_85 ();
 FILLCELL_X1 FILLER_10_0 ();
 FILLCELL_X1 FILLER_10_1 ();
 FILLCELL_X1 FILLER_10_107 ();
 FILLCELL_X1 FILLER_10_116 ();
 FILLCELL_X1 FILLER_10_137 ();
 FILLCELL_X1 FILLER_10_138 ();
 FILLCELL_X1 FILLER_10_139 ();
 FILLCELL_X1 FILLER_10_15 ();
 FILLCELL_X4 FILLER_10_40 ();
 FILLCELL_X1 FILLER_10_44 ();
 FILLCELL_X8 FILLER_10_53 ();
 FILLCELL_X4 FILLER_10_61 ();
 FILLCELL_X1 FILLER_10_65 ();
 FILLCELL_X1 FILLER_10_66 ();
 FILLCELL_X16 FILLER_10_91 ();
 FILLCELL_X8 FILLER_11_0 ();
 FILLCELL_X1 FILLER_11_107 ();
 FILLCELL_X1 FILLER_11_108 ();
 FILLCELL_X1 FILLER_11_109 ();
 FILLCELL_X8 FILLER_11_132 ();
 FILLCELL_X16 FILLER_11_24 ();
 FILLCELL_X8 FILLER_11_59 ();
 FILLCELL_X1 FILLER_11_8 ();
 FILLCELL_X1 FILLER_11_9 ();
 FILLCELL_X16 FILLER_11_91 ();
 FILLCELL_X32 FILLER_12_0 ();
 FILLCELL_X4 FILLER_12_104 ();
 FILLCELL_X1 FILLER_12_108 ();
 FILLCELL_X1 FILLER_12_109 ();
 FILLCELL_X4 FILLER_12_135 ();
 FILLCELL_X1 FILLER_12_139 ();
 FILLCELL_X8 FILLER_12_32 ();
 FILLCELL_X4 FILLER_12_40 ();
 FILLCELL_X1 FILLER_12_44 ();
 FILLCELL_X1 FILLER_12_45 ();
 FILLCELL_X16 FILLER_12_58 ();
 FILLCELL_X1 FILLER_12_74 ();
 FILLCELL_X1 FILLER_12_75 ();
 FILLCELL_X1 FILLER_12_76 ();
 FILLCELL_X8 FILLER_13_0 ();
 FILLCELL_X1 FILLER_13_100 ();
 FILLCELL_X1 FILLER_13_101 ();
 FILLCELL_X4 FILLER_13_109 ();
 FILLCELL_X1 FILLER_13_113 ();
 FILLCELL_X1 FILLER_13_114 ();
 FILLCELL_X1 FILLER_13_115 ();
 FILLCELL_X16 FILLER_13_118 ();
 FILLCELL_X1 FILLER_13_12 ();
 FILLCELL_X1 FILLER_13_13 ();
 FILLCELL_X4 FILLER_13_134 ();
 FILLCELL_X1 FILLER_13_138 ();
 FILLCELL_X1 FILLER_13_139 ();
 FILLCELL_X1 FILLER_13_20 ();
 FILLCELL_X1 FILLER_13_21 ();
 FILLCELL_X16 FILLER_13_33 ();
 FILLCELL_X4 FILLER_13_49 ();
 FILLCELL_X1 FILLER_13_53 ();
 FILLCELL_X32 FILLER_13_59 ();
 FILLCELL_X4 FILLER_13_8 ();
 FILLCELL_X8 FILLER_13_91 ();
 FILLCELL_X1 FILLER_13_99 ();
 FILLCELL_X8 FILLER_14_0 ();
 FILLCELL_X8 FILLER_14_100 ();
 FILLCELL_X1 FILLER_14_108 ();
 FILLCELL_X1 FILLER_14_109 ();
 FILLCELL_X4 FILLER_14_135 ();
 FILLCELL_X1 FILLER_14_139 ();
 FILLCELL_X16 FILLER_14_30 ();
 FILLCELL_X4 FILLER_14_46 ();
 FILLCELL_X1 FILLER_14_50 ();
 FILLCELL_X4 FILLER_14_73 ();
 FILLCELL_X1 FILLER_14_77 ();
 FILLCELL_X1 FILLER_14_78 ();
 FILLCELL_X1 FILLER_14_79 ();
 FILLCELL_X1 FILLER_14_8 ();
 FILLCELL_X1 FILLER_14_9 ();
 FILLCELL_X4 FILLER_15_0 ();
 FILLCELL_X4 FILLER_15_103 ();
 FILLCELL_X1 FILLER_15_114 ();
 FILLCELL_X1 FILLER_15_115 ();
 FILLCELL_X1 FILLER_15_138 ();
 FILLCELL_X1 FILLER_15_139 ();
 FILLCELL_X4 FILLER_15_27 ();
 FILLCELL_X1 FILLER_15_31 ();
 FILLCELL_X1 FILLER_15_32 ();
 FILLCELL_X4 FILLER_15_58 ();
 FILLCELL_X1 FILLER_15_62 ();
 FILLCELL_X4 FILLER_16_0 ();
 FILLCELL_X1 FILLER_16_106 ();
 FILLCELL_X1 FILLER_16_107 ();
 FILLCELL_X8 FILLER_16_132 ();
 FILLCELL_X16 FILLER_16_23 ();
 FILLCELL_X4 FILLER_16_39 ();
 FILLCELL_X1 FILLER_16_4 ();
 FILLCELL_X1 FILLER_16_43 ();
 FILLCELL_X1 FILLER_16_64 ();
 FILLCELL_X1 FILLER_16_68 ();
 FILLCELL_X1 FILLER_16_69 ();
 FILLCELL_X4 FILLER_16_73 ();
 FILLCELL_X1 FILLER_16_84 ();
 FILLCELL_X1 FILLER_16_85 ();
 FILLCELL_X1 FILLER_16_86 ();
 FILLCELL_X16 FILLER_16_90 ();
 FILLCELL_X32 FILLER_17_0 ();
 FILLCELL_X8 FILLER_17_128 ();
 FILLCELL_X4 FILLER_17_136 ();
 FILLCELL_X32 FILLER_17_32 ();
 FILLCELL_X32 FILLER_17_64 ();
 FILLCELL_X32 FILLER_17_96 ();
 FILLCELL_X8 FILLER_1_0 ();
 FILLCELL_X4 FILLER_1_110 ();
 FILLCELL_X1 FILLER_1_12 ();
 FILLCELL_X1 FILLER_1_13 ();
 FILLCELL_X1 FILLER_1_138 ();
 FILLCELL_X1 FILLER_1_139 ();
 FILLCELL_X8 FILLER_1_32 ();
 FILLCELL_X4 FILLER_1_40 ();
 FILLCELL_X1 FILLER_1_44 ();
 FILLCELL_X1 FILLER_1_52 ();
 FILLCELL_X1 FILLER_1_53 ();
 FILLCELL_X1 FILLER_1_54 ();
 FILLCELL_X16 FILLER_1_58 ();
 FILLCELL_X4 FILLER_1_8 ();
 FILLCELL_X16 FILLER_1_94 ();
 FILLCELL_X8 FILLER_2_0 ();
 FILLCELL_X4 FILLER_2_101 ();
 FILLCELL_X1 FILLER_2_105 ();
 FILLCELL_X8 FILLER_2_130 ();
 FILLCELL_X1 FILLER_2_138 ();
 FILLCELL_X1 FILLER_2_139 ();
 FILLCELL_X4 FILLER_2_35 ();
 FILLCELL_X1 FILLER_2_75 ();
 FILLCELL_X4 FILLER_2_8 ();
 FILLCELL_X8 FILLER_3_0 ();
 FILLCELL_X4 FILLER_3_103 ();
 FILLCELL_X1 FILLER_3_107 ();
 FILLCELL_X1 FILLER_3_12 ();
 FILLCELL_X1 FILLER_3_13 ();
 FILLCELL_X1 FILLER_3_138 ();
 FILLCELL_X1 FILLER_3_139 ();
 FILLCELL_X1 FILLER_3_14 ();
 FILLCELL_X16 FILLER_3_18 ();
 FILLCELL_X8 FILLER_3_34 ();
 FILLCELL_X4 FILLER_3_42 ();
 FILLCELL_X8 FILLER_3_62 ();
 FILLCELL_X4 FILLER_3_70 ();
 FILLCELL_X1 FILLER_3_74 ();
 FILLCELL_X4 FILLER_3_8 ();
 FILLCELL_X8 FILLER_4_0 ();
 FILLCELL_X8 FILLER_4_127 ();
 FILLCELL_X4 FILLER_4_135 ();
 FILLCELL_X1 FILLER_4_139 ();
 FILLCELL_X1 FILLER_4_19 ();
 FILLCELL_X32 FILLER_4_24 ();
 FILLCELL_X32 FILLER_4_56 ();
 FILLCELL_X1 FILLER_4_8 ();
 FILLCELL_X4 FILLER_4_88 ();
 FILLCELL_X1 FILLER_4_9 ();
 FILLCELL_X1 FILLER_4_92 ();
 FILLCELL_X32 FILLER_4_95 ();
 FILLCELL_X8 FILLER_5_0 ();
 FILLCELL_X1 FILLER_5_100 ();
 FILLCELL_X32 FILLER_5_106 ();
 FILLCELL_X1 FILLER_5_138 ();
 FILLCELL_X1 FILLER_5_139 ();
 FILLCELL_X8 FILLER_5_33 ();
 FILLCELL_X4 FILLER_5_41 ();
 FILLCELL_X1 FILLER_5_45 ();
 FILLCELL_X1 FILLER_5_46 ();
 FILLCELL_X16 FILLER_5_50 ();
 FILLCELL_X8 FILLER_5_66 ();
 FILLCELL_X1 FILLER_5_74 ();
 FILLCELL_X1 FILLER_5_75 ();
 FILLCELL_X1 FILLER_5_76 ();
 FILLCELL_X1 FILLER_5_8 ();
 FILLCELL_X16 FILLER_5_80 ();
 FILLCELL_X1 FILLER_5_9 ();
 FILLCELL_X4 FILLER_5_96 ();
 FILLCELL_X8 FILLER_6_0 ();
 FILLCELL_X1 FILLER_6_138 ();
 FILLCELL_X1 FILLER_6_139 ();
 FILLCELL_X1 FILLER_6_18 ();
 FILLCELL_X1 FILLER_6_19 ();
 FILLCELL_X8 FILLER_6_30 ();
 FILLCELL_X4 FILLER_6_38 ();
 FILLCELL_X1 FILLER_6_42 ();
 FILLCELL_X4 FILLER_6_52 ();
 FILLCELL_X1 FILLER_6_56 ();
 FILLCELL_X1 FILLER_6_57 ();
 FILLCELL_X1 FILLER_6_58 ();
 FILLCELL_X1 FILLER_6_65 ();
 FILLCELL_X1 FILLER_6_66 ();
 FILLCELL_X1 FILLER_6_8 ();
 FILLCELL_X8 FILLER_6_87 ();
 FILLCELL_X1 FILLER_6_9 ();
 FILLCELL_X1 FILLER_6_95 ();
 FILLCELL_X8 FILLER_7_0 ();
 FILLCELL_X4 FILLER_7_105 ();
 FILLCELL_X1 FILLER_7_109 ();
 FILLCELL_X1 FILLER_7_110 ();
 FILLCELL_X1 FILLER_7_138 ();
 FILLCELL_X1 FILLER_7_139 ();
 FILLCELL_X1 FILLER_7_17 ();
 FILLCELL_X8 FILLER_7_21 ();
 FILLCELL_X1 FILLER_7_29 ();
 FILLCELL_X1 FILLER_7_30 ();
 FILLCELL_X8 FILLER_7_36 ();
 FILLCELL_X4 FILLER_7_44 ();
 FILLCELL_X1 FILLER_7_48 ();
 FILLCELL_X1 FILLER_7_49 ();
 FILLCELL_X1 FILLER_7_56 ();
 FILLCELL_X1 FILLER_7_8 ();
 FILLCELL_X16 FILLER_7_81 ();
 FILLCELL_X1 FILLER_7_9 ();
 FILLCELL_X8 FILLER_7_97 ();
 FILLCELL_X8 FILLER_8_0 ();
 FILLCELL_X1 FILLER_8_108 ();
 FILLCELL_X1 FILLER_8_12 ();
 FILLCELL_X16 FILLER_8_124 ();
 FILLCELL_X1 FILLER_8_13 ();
 FILLCELL_X8 FILLER_8_20 ();
 FILLCELL_X1 FILLER_8_28 ();
 FILLCELL_X1 FILLER_8_29 ();
 FILLCELL_X1 FILLER_8_30 ();
 FILLCELL_X32 FILLER_8_35 ();
 FILLCELL_X1 FILLER_8_67 ();
 FILLCELL_X1 FILLER_8_68 ();
 FILLCELL_X1 FILLER_8_69 ();
 FILLCELL_X8 FILLER_8_73 ();
 FILLCELL_X4 FILLER_8_8 ();
 FILLCELL_X8 FILLER_9_0 ();
 FILLCELL_X1 FILLER_9_110 ();
 FILLCELL_X16 FILLER_9_118 ();
 FILLCELL_X4 FILLER_9_134 ();
 FILLCELL_X1 FILLER_9_138 ();
 FILLCELL_X1 FILLER_9_139 ();
 FILLCELL_X32 FILLER_9_25 ();
 FILLCELL_X4 FILLER_9_57 ();
 FILLCELL_X1 FILLER_9_61 ();
 FILLCELL_X1 FILLER_9_62 ();
 FILLCELL_X1 FILLER_9_63 ();
 FILLCELL_X1 FILLER_9_69 ();
 FILLCELL_X1 FILLER_9_70 ();
 FILLCELL_X1 FILLER_9_71 ();
 FILLCELL_X32 FILLER_9_78 ();
 FILLCELL_X4 FILLER_9_8 ();
 INV_X1 _323_ (.A(pixel_in[0]),
    .ZN(_187_));
 INV_X1 _324_ (.A(pixel_in[8]),
    .ZN(_188_));
 INV_X1 _325_ (.A(pixel_in[7]),
    .ZN(_189_));
 INV_X1 _326_ (.A(pixel_in[3]),
    .ZN(_190_));
 INV_X1 _327_ (.A(res_pipe[18]),
    .ZN(_191_));
 INV_X1 _328_ (.A(valid_in),
    .ZN(_192_));
 NAND2_X1 _329_ (.A1(_191_),
    .A2(valid_pipe[0]),
    .ZN(_193_));
 OAI22_X1 _330_ (.A1(pixel_out[6]),
    .A2(valid_pipe[0]),
    .B1(_193_),
    .B2(res_pipe[14]),
    .ZN(_194_));
 INV_X1 _331_ (.A(_194_),
    .ZN(_106_));
 AND2_X1 _332_ (.A1(row),
    .A2(col),
    .ZN(_195_));
 NOR2_X1 _333_ (.A1(pixel_in[8]),
    .A2(pixel_in[9]),
    .ZN(_196_));
 NAND2_X1 _334_ (.A1(pixel_in[8]),
    .A2(pixel_in[7]),
    .ZN(_197_));
 XNOR2_X1 _335_ (.A(pixel_in[8]),
    .B(pixel_in[7]),
    .ZN(_198_));
 AND2_X1 _336_ (.A1(pixel_in[7]),
    .A2(pixel_in[6]),
    .ZN(_199_));
 NOR2_X1 _337_ (.A1(pixel_in[7]),
    .A2(pixel_in[6]),
    .ZN(_200_));
 AND2_X1 _338_ (.A1(pixel_in[6]),
    .A2(pixel_in[5]),
    .ZN(_201_));
 NAND2_X1 _339_ (.A1(pixel_in[6]),
    .A2(pixel_in[5]),
    .ZN(_202_));
 OR2_X1 _340_ (.A1(pixel_in[6]),
    .A2(pixel_in[5]),
    .ZN(_203_));
 NAND2_X1 _341_ (.A1(_202_),
    .A2(_203_),
    .ZN(_204_));
 AND2_X1 _342_ (.A1(pixel_in[5]),
    .A2(pixel_in[4]),
    .ZN(_205_));
 NOR2_X1 _343_ (.A1(pixel_in[5]),
    .A2(pixel_in[4]),
    .ZN(_206_));
 NAND2_X1 _344_ (.A1(pixel_in[3]),
    .A2(pixel_in[4]),
    .ZN(_207_));
 XNOR2_X1 _345_ (.A(pixel_in[3]),
    .B(pixel_in[4]),
    .ZN(_208_));
 AOI21_X1 _346_ (.A(pixel_in[2]),
    .B1(pixel_in[1]),
    .B2(pixel_in[0]),
    .ZN(_209_));
 AOI21_X1 _347_ (.A(pixel_in[3]),
    .B1(pixel_in[2]),
    .B2(pixel_in[1]),
    .ZN(_210_));
 NOR2_X1 _348_ (.A1(_209_),
    .A2(_210_),
    .ZN(_211_));
 OR3_X1 _349_ (.A1(_208_),
    .A2(_209_),
    .A3(_210_),
    .ZN(_212_));
 NAND2_X1 _350_ (.A1(_207_),
    .A2(_212_),
    .ZN(_213_));
 AOI21_X1 _351_ (.A(_206_),
    .B1(_207_),
    .B2(_212_),
    .ZN(_214_));
 NOR2_X1 _352_ (.A1(_205_),
    .A2(_214_),
    .ZN(_215_));
 OR2_X1 _353_ (.A1(_205_),
    .A2(_214_),
    .ZN(_216_));
 OAI21_X1 _354_ (.A(_202_),
    .B1(_204_),
    .B2(_215_),
    .ZN(_217_));
 AOI211_X1 _355_ (.A(_199_),
    .B(_201_),
    .C1(_203_),
    .C2(_216_),
    .ZN(_218_));
 OR3_X1 _356_ (.A1(_198_),
    .A2(_200_),
    .A3(_218_),
    .ZN(_219_));
 OAI21_X1 _357_ (.A(pixel_in[8]),
    .B1(pixel_in[9]),
    .B2(pixel_in[7]),
    .ZN(_220_));
 OAI21_X1 _358_ (.A(_220_),
    .B1(_219_),
    .B2(_196_),
    .ZN(_221_));
 NOR2_X1 _359_ (.A1(_195_),
    .A2(_221_),
    .ZN(_222_));
 NOR2_X1 _360_ (.A1(row),
    .A2(col),
    .ZN(_223_));
 OR2_X1 _361_ (.A1(row),
    .A2(col),
    .ZN(_224_));
 NOR2_X1 _362_ (.A1(_195_),
    .A2(_223_),
    .ZN(_131_));
 OAI211_X1 _363_ (.A(pixel_in[9]),
    .B(valid_in),
    .C1(_195_),
    .C2(_223_),
    .ZN(_132_));
 OAI22_X1 _364_ (.A1(_191_),
    .A2(valid_in),
    .B1(_222_),
    .B2(_132_),
    .ZN(_107_));
 OAI22_X1 _365_ (.A1(valid_pipe[0]),
    .A2(pixel_out[9]),
    .B1(_193_),
    .B2(res_pipe[17]),
    .ZN(_133_));
 INV_X1 _366_ (.A(_133_),
    .ZN(_108_));
 OAI22_X1 _367_ (.A1(valid_pipe[0]),
    .A2(pixel_out[5]),
    .B1(_193_),
    .B2(res_pipe[13]),
    .ZN(_134_));
 INV_X1 _368_ (.A(_134_),
    .ZN(_109_));
 OAI22_X1 _369_ (.A1(valid_pipe[0]),
    .A2(pixel_out[4]),
    .B1(_193_),
    .B2(res_pipe[12]),
    .ZN(_135_));
 INV_X1 _370_ (.A(_135_),
    .ZN(_110_));
 OAI22_X1 _371_ (.A1(valid_pipe[0]),
    .A2(pixel_out[3]),
    .B1(_193_),
    .B2(res_pipe[11]),
    .ZN(_136_));
 INV_X1 _372_ (.A(_136_),
    .ZN(_111_));
 OAI22_X1 _373_ (.A1(valid_pipe[0]),
    .A2(pixel_out[2]),
    .B1(_193_),
    .B2(res_pipe[10]),
    .ZN(_137_));
 INV_X1 _374_ (.A(_137_),
    .ZN(_112_));
 OAI22_X1 _375_ (.A1(valid_pipe[0]),
    .A2(pixel_out[1]),
    .B1(_193_),
    .B2(res_pipe[9]),
    .ZN(_138_));
 INV_X1 _376_ (.A(_138_),
    .ZN(_113_));
 OAI22_X1 _377_ (.A1(valid_pipe[0]),
    .A2(pixel_out[0]),
    .B1(_193_),
    .B2(res_pipe[8]),
    .ZN(_139_));
 INV_X1 _378_ (.A(_139_),
    .ZN(_114_));
 OAI22_X1 _379_ (.A1(valid_pipe[0]),
    .A2(pixel_out[8]),
    .B1(_193_),
    .B2(res_pipe[16]),
    .ZN(_140_));
 INV_X1 _380_ (.A(_140_),
    .ZN(_115_));
 OAI22_X1 _381_ (.A1(valid_pipe[0]),
    .A2(pixel_out[7]),
    .B1(_193_),
    .B2(res_pipe[15]),
    .ZN(_141_));
 INV_X1 _382_ (.A(_141_),
    .ZN(_116_));
 NOR2_X1 _383_ (.A1(valid_in),
    .A2(res_pipe[17]),
    .ZN(_142_));
 AOI211_X1 _384_ (.A(_188_),
    .B(pixel_in[9]),
    .C1(_189_),
    .C2(_219_),
    .ZN(_143_));
 AND3_X1 _385_ (.A1(_188_),
    .A2(pixel_in[9]),
    .A3(_219_),
    .ZN(_144_));
 OAI21_X1 _386_ (.A(_223_),
    .B1(_143_),
    .B2(_144_),
    .ZN(_145_));
 AOI221_X1 _387_ (.A(_192_),
    .B1(_195_),
    .B2(pixel_in[8]),
    .C1(_131_),
    .C2(pixel_in[9]),
    .ZN(_146_));
 AOI21_X1 _388_ (.A(_142_),
    .B1(_145_),
    .B2(_146_),
    .ZN(_117_));
 NOR2_X1 _389_ (.A1(res_pipe[16]),
    .A2(valid_in),
    .ZN(_147_));
 XOR2_X1 _390_ (.A(pixel_in[8]),
    .B(pixel_in[9]),
    .Z(_148_));
 AND3_X1 _391_ (.A1(_197_),
    .A2(_219_),
    .A3(_148_),
    .ZN(_149_));
 AOI21_X1 _392_ (.A(_148_),
    .B1(_219_),
    .B2(_197_),
    .ZN(_150_));
 OAI21_X1 _393_ (.A(_223_),
    .B1(_149_),
    .B2(_150_),
    .ZN(_151_));
 AOI221_X1 _394_ (.A(_192_),
    .B1(_195_),
    .B2(pixel_in[7]),
    .C1(_131_),
    .C2(pixel_in[8]),
    .ZN(_152_));
 AOI21_X1 _395_ (.A(_147_),
    .B1(_151_),
    .B2(_152_),
    .ZN(_118_));
 NOR2_X1 _396_ (.A1(res_pipe[15]),
    .A2(valid_in),
    .ZN(_153_));
 OAI21_X1 _397_ (.A(_198_),
    .B1(_200_),
    .B2(_218_),
    .ZN(_154_));
 NAND3_X1 _398_ (.A1(_219_),
    .A2(_223_),
    .A3(_154_),
    .ZN(_155_));
 AOI221_X1 _399_ (.A(_192_),
    .B1(_195_),
    .B2(pixel_in[6]),
    .C1(_131_),
    .C2(pixel_in[7]),
    .ZN(_156_));
 AOI21_X1 _400_ (.A(_153_),
    .B1(_155_),
    .B2(_156_),
    .ZN(_119_));
 NOR2_X1 _401_ (.A1(res_pipe[14]),
    .A2(valid_in),
    .ZN(_157_));
 OR2_X1 _402_ (.A1(_199_),
    .A2(_200_),
    .ZN(_158_));
 XNOR2_X1 _403_ (.A(_217_),
    .B(_158_),
    .ZN(_159_));
 NAND2_X1 _404_ (.A1(_223_),
    .A2(_159_),
    .ZN(_160_));
 AOI221_X1 _405_ (.A(_192_),
    .B1(_195_),
    .B2(pixel_in[5]),
    .C1(_131_),
    .C2(pixel_in[6]),
    .ZN(_161_));
 AOI21_X1 _406_ (.A(_157_),
    .B1(_160_),
    .B2(_161_),
    .ZN(_120_));
 XNOR2_X1 _407_ (.A(_204_),
    .B(_215_),
    .ZN(_162_));
 AOI22_X1 _408_ (.A1(pixel_in[4]),
    .A2(_195_),
    .B1(_131_),
    .B2(pixel_in[5]),
    .ZN(_163_));
 OAI21_X1 _409_ (.A(_163_),
    .B1(_162_),
    .B2(_224_),
    .ZN(_164_));
 MUX2_X1 _410_ (.A(res_pipe[13]),
    .B(_164_),
    .S(valid_in),
    .Z(_121_));
 NOR2_X1 _411_ (.A1(_205_),
    .A2(_206_),
    .ZN(_165_));
 XNOR2_X1 _412_ (.A(_213_),
    .B(_165_),
    .ZN(_166_));
 AOI22_X1 _413_ (.A1(pixel_in[3]),
    .A2(_195_),
    .B1(_131_),
    .B2(pixel_in[4]),
    .ZN(_167_));
 OAI21_X1 _414_ (.A(_167_),
    .B1(_166_),
    .B2(_224_),
    .ZN(_168_));
 MUX2_X1 _415_ (.A(res_pipe[12]),
    .B(_168_),
    .S(valid_in),
    .Z(_122_));
 XNOR2_X1 _416_ (.A(row),
    .B(h_sync),
    .ZN(_169_));
 NOR2_X1 _417_ (.A1(v_sync),
    .A2(_169_),
    .ZN(_123_));
 XNOR2_X1 _418_ (.A(col),
    .B(valid_in),
    .ZN(_170_));
 NOR3_X1 _419_ (.A1(v_sync),
    .A2(h_sync),
    .A3(_170_),
    .ZN(_124_));
 XOR2_X1 _420_ (.A(_208_),
    .B(_211_),
    .Z(_171_));
 AOI22_X1 _421_ (.A1(pixel_in[2]),
    .A2(_195_),
    .B1(_131_),
    .B2(pixel_in[3]),
    .ZN(_172_));
 OAI21_X1 _422_ (.A(_172_),
    .B1(_171_),
    .B2(_224_),
    .ZN(_173_));
 MUX2_X1 _423_ (.A(res_pipe[11]),
    .B(_173_),
    .S(valid_in),
    .Z(_125_));
 NAND3_X1 _424_ (.A1(pixel_in[1]),
    .A2(pixel_in[2]),
    .A3(pixel_in[3]),
    .ZN(_174_));
 AOI221_X1 _425_ (.A(_224_),
    .B1(_174_),
    .B2(_211_),
    .C1(_209_),
    .C2(_190_),
    .ZN(_175_));
 AOI221_X1 _426_ (.A(_175_),
    .B1(_131_),
    .B2(pixel_in[2]),
    .C1(pixel_in[1]),
    .C2(_195_),
    .ZN(_176_));
 NAND2_X1 _427_ (.A1(res_pipe[10]),
    .A2(_192_),
    .ZN(_177_));
 OAI21_X1 _428_ (.A(_177_),
    .B1(_176_),
    .B2(_192_),
    .ZN(_126_));
 NAND3_X1 _429_ (.A1(_187_),
    .A2(pixel_in[1]),
    .A3(pixel_in[2]),
    .ZN(_178_));
 NAND2_X1 _430_ (.A1(pixel_in[1]),
    .A2(_223_),
    .ZN(_179_));
 NAND2_X1 _431_ (.A1(pixel_in[2]),
    .A2(_223_),
    .ZN(_180_));
 OAI21_X1 _432_ (.A(_180_),
    .B1(_179_),
    .B2(pixel_in[0]),
    .ZN(_181_));
 AOI222_X1 _433_ (.A1(pixel_in[0]),
    .A2(_195_),
    .B1(_178_),
    .B2(_181_),
    .C1(_131_),
    .C2(pixel_in[1]),
    .ZN(_182_));
 NAND2_X1 _434_ (.A1(res_pipe[9]),
    .A2(_192_),
    .ZN(_183_));
 OAI21_X1 _435_ (.A(_183_),
    .B1(_182_),
    .B2(_192_),
    .ZN(_127_));
 AOI211_X1 _436_ (.A(_187_),
    .B(_195_),
    .C1(_223_),
    .C2(pixel_in[1]),
    .ZN(_184_));
 OAI21_X1 _437_ (.A(valid_in),
    .B1(_179_),
    .B2(pixel_in[0]),
    .ZN(_185_));
 OAI22_X1 _438_ (.A1(res_pipe[8]),
    .A2(valid_in),
    .B1(_184_),
    .B2(_185_),
    .ZN(_186_));
 INV_X1 _439_ (.A(_186_),
    .ZN(_128_));
 DFFR_X1 _440_ (.D(_128_),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(res_pipe[8]),
    .QN(_288_));
 DFFR_X1 _441_ (.D(_127_),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(res_pipe[9]),
    .QN(_261_));
 DFFR_X1 _442_ (.D(_126_),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(res_pipe[10]),
    .QN(_287_));
 DFFR_X1 _443_ (.D(_125_),
    .RN(resetn),
    .CK(clknet_2_3__leaf_clk),
    .Q(res_pipe[11]),
    .QN(_263_));
 DFFR_X1 _444_ (.D(_122_),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(res_pipe[12]),
    .QN(_266_));
 DFFR_X1 _445_ (.D(_121_),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(res_pipe[13]),
    .QN(_267_));
 DFFR_X1 _446_ (.D(_120_),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(res_pipe[14]),
    .QN(_268_));
 DFFR_X1 _447_ (.D(_119_),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(res_pipe[15]),
    .QN(_269_));
 DFFR_X1 _448_ (.D(_118_),
    .RN(resetn),
    .CK(clknet_2_3__leaf_clk),
    .Q(res_pipe[16]),
    .QN(_270_));
 DFFR_X1 _449_ (.D(_117_),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(res_pipe[17]),
    .QN(_271_));
 DFFR_X1 _450_ (.D(_107_),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(res_pipe[18]),
    .QN(_281_));
 DFFR_X1 _451_ (.D(_114_),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(pixel_out[0]),
    .QN(_274_));
 DFFR_X1 _452_ (.D(_113_),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(pixel_out[1]),
    .QN(_275_));
 DFFR_X1 _453_ (.D(_112_),
    .RN(resetn),
    .CK(clknet_2_3__leaf_clk),
    .Q(pixel_out[2]),
    .QN(_276_));
 DFFR_X1 _454_ (.D(_111_),
    .RN(resetn),
    .CK(clknet_2_3__leaf_clk),
    .Q(pixel_out[3]),
    .QN(_277_));
 DFFR_X1 _455_ (.D(_110_),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(pixel_out[4]),
    .QN(_278_));
 DFFR_X1 _456_ (.D(_109_),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(pixel_out[5]),
    .QN(_279_));
 DFFR_X1 _457_ (.D(_106_),
    .RN(resetn),
    .CK(clknet_2_3__leaf_clk),
    .Q(pixel_out[6]),
    .QN(_282_));
 DFFR_X1 _458_ (.D(_116_),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(pixel_out[7]),
    .QN(_272_));
 DFFR_X1 _459_ (.D(_115_),
    .RN(resetn),
    .CK(clknet_2_3__leaf_clk),
    .Q(pixel_out[8]),
    .QN(_273_));
 DFFR_X1 _460_ (.D(_108_),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(pixel_out[9]),
    .QN(_283_));
 DFFR_X1 _461_ (.D(_123_),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(row),
    .QN(_265_));
 DFFR_X1 _462_ (.D(_124_),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(col),
    .QN(_286_));
 DFFR_X1 _463_ (.D(net4),
    .RN(resetn),
    .CK(clknet_2_2__leaf_clk),
    .Q(valid_out),
    .QN(_284_));
 DFFR_X1 _464_ (.D(net1),
    .RN(resetn),
    .CK(clknet_2_0__leaf_clk),
    .Q(v_sync_out),
    .QN(_260_));
 DFFR_X1 _465_ (.D(net2),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(h_sync_out),
    .QN(_280_));
 DFFR_X1 _466_ (.D(valid_in),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(valid_pipe[0]),
    .QN(_262_));
 DFFR_X1 _467_ (.D(h_sync),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(h_pipe[0]),
    .QN(_264_));
 DFFR_X1 _468_ (.D(v_sync),
    .RN(resetn),
    .CK(clknet_2_1__leaf_clk),
    .Q(v_pipe[0]),
    .QN(_285_));
 LOGIC0_X1 _469_ (.Z(_289_));
 LOGIC0_X1 _470_ (.Z(_290_));
 LOGIC0_X1 _471_ (.Z(_291_));
 LOGIC0_X1 _472_ (.Z(_292_));
 LOGIC0_X1 _473_ (.Z(_293_));
 LOGIC0_X1 _474_ (.Z(_294_));
 LOGIC0_X1 _475_ (.Z(_295_));
 LOGIC0_X1 _476_ (.Z(_296_));
 LOGIC0_X1 _477_ (.Z(_297_));
 LOGIC0_X1 _478_ (.Z(_298_));
 CLKBUF_X3 clkbuf_0_clk (.A(clk),
    .Z(clknet_0_clk));
 CLKBUF_X3 clkbuf_2_0__f_clk (.A(clknet_0_clk),
    .Z(clknet_2_0__leaf_clk));
 CLKBUF_X3 clkbuf_2_1__f_clk (.A(clknet_0_clk),
    .Z(clknet_2_1__leaf_clk));
 CLKBUF_X3 clkbuf_2_2__f_clk (.A(clknet_0_clk),
    .Z(clknet_2_2__leaf_clk));
 CLKBUF_X3 clkbuf_2_3__f_clk (.A(clknet_0_clk),
    .Z(clknet_2_3__leaf_clk));
 INV_X1 clkload0 (.A(clknet_2_0__leaf_clk));
 INV_X1 clkload1 (.A(clknet_2_2__leaf_clk));
 INV_X2 clkload2 (.A(clknet_2_3__leaf_clk));
 CLKBUF_X1 hold1 (.A(net3),
    .Z(net1));
 CLKBUF_X1 hold2 (.A(h_pipe[0]),
    .Z(net2));
 CLKBUF_X1 hold3 (.A(v_pipe[0]),
    .Z(net3));
 CLKBUF_X1 hold4 (.A(valid_pipe[0]),
    .Z(net4));
endmodule
