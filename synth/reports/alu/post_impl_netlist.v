// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Wed Mar 11 01:02:28 2026
// Host        : Gaurav running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -force
//               C:/Users/gt111/Desktop/Self-Healing_Digital_Circuit/synth/reports/alu/post_impl_netlist.v
// Design      : alu
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* ECO_CHECKSUM = "aad06db7" *) (* OP_ADD = "3'b000" *) (* OP_AND = "3'b010" *) 
(* OP_NOT = "3'b101" *) (* OP_OR = "3'b011" *) (* OP_SHL = "3'b110" *) 
(* OP_SHR = "3'b111" *) (* OP_SUB = "3'b001" *) (* OP_XOR = "3'b100" *) 
(* NotValidForBitStream *)
module alu
   (clk,
    rst,
    a,
    b,
    op,
    result,
    carry_out,
    zero);
  input clk;
  input rst;
  input [7:0]a;
  input [7:0]b;
  input [2:0]op;
  output [7:0]result;
  output carry_out;
  output zero;

  wire [7:0]a;
  wire [7:0]b;
  wire carry_out;
  wire carry_out_i_1_n_0;
  wire carry_out_i_2_n_0;
  wire clk;
  wire data0;
  wire data1;
  wire [2:0]op;
  wire [7:0]result;
  wire \result[0]_i_2_n_0 ;
  wire \result[0]_i_3_n_0 ;
  wire \result[1]_i_2_n_0 ;
  wire \result[1]_i_3_n_0 ;
  wire \result[2]_i_2_n_0 ;
  wire \result[2]_i_3_n_0 ;
  wire \result[3]_i_10_n_0 ;
  wire \result[3]_i_11_n_0 ;
  wire \result[3]_i_12_n_0 ;
  wire \result[3]_i_13_n_0 ;
  wire \result[3]_i_2_n_0 ;
  wire \result[3]_i_3_n_0 ;
  wire \result[3]_i_6_n_0 ;
  wire \result[3]_i_7_n_0 ;
  wire \result[3]_i_8_n_0 ;
  wire \result[3]_i_9_n_0 ;
  wire \result[4]_i_2_n_0 ;
  wire \result[4]_i_3_n_0 ;
  wire \result[5]_i_2_n_0 ;
  wire \result[5]_i_3_n_0 ;
  wire \result[6]_i_2_n_0 ;
  wire \result[6]_i_3_n_0 ;
  wire \result[7]_i_10_n_0 ;
  wire \result[7]_i_11_n_0 ;
  wire \result[7]_i_12_n_0 ;
  wire \result[7]_i_13_n_0 ;
  wire \result[7]_i_2_n_0 ;
  wire \result[7]_i_3_n_0 ;
  wire \result[7]_i_6_n_0 ;
  wire \result[7]_i_7_n_0 ;
  wire \result[7]_i_8_n_0 ;
  wire \result[7]_i_9_n_0 ;
  wire \result_reg[0]_i_1_n_0 ;
  wire \result_reg[1]_i_1_n_0 ;
  wire \result_reg[2]_i_1_n_0 ;
  wire \result_reg[3]_i_1_n_0 ;
  wire \result_reg[3]_i_4_n_0 ;
  wire \result_reg[3]_i_4_n_4 ;
  wire \result_reg[3]_i_4_n_5 ;
  wire \result_reg[3]_i_4_n_6 ;
  wire \result_reg[3]_i_4_n_7 ;
  wire \result_reg[3]_i_5_n_0 ;
  wire \result_reg[3]_i_5_n_4 ;
  wire \result_reg[3]_i_5_n_5 ;
  wire \result_reg[3]_i_5_n_6 ;
  wire \result_reg[3]_i_5_n_7 ;
  wire \result_reg[4]_i_1_n_0 ;
  wire \result_reg[5]_i_1_n_0 ;
  wire \result_reg[6]_i_1_n_0 ;
  wire \result_reg[7]_i_1_n_0 ;
  wire \result_reg[7]_i_4_n_0 ;
  wire \result_reg[7]_i_4_n_4 ;
  wire \result_reg[7]_i_4_n_5 ;
  wire \result_reg[7]_i_4_n_6 ;
  wire \result_reg[7]_i_4_n_7 ;
  wire \result_reg[7]_i_5_n_0 ;
  wire \result_reg[7]_i_5_n_4 ;
  wire \result_reg[7]_i_5_n_5 ;
  wire \result_reg[7]_i_5_n_6 ;
  wire \result_reg[7]_i_5_n_7 ;
  wire rst;
  wire zero;
  wire zero_INST_0_i_1_n_0;
  wire [3:1]NLW_carry_out_reg_i_3_CO_UNCONNECTED;
  wire [3:0]NLW_carry_out_reg_i_3_O_UNCONNECTED;
  wire [3:0]NLW_carry_out_reg_i_4_CO_UNCONNECTED;
  wire [3:1]NLW_carry_out_reg_i_4_O_UNCONNECTED;
  wire [2:0]\NLW_result_reg[3]_i_4_CO_UNCONNECTED ;
  wire [2:0]\NLW_result_reg[3]_i_5_CO_UNCONNECTED ;
  wire [2:0]\NLW_result_reg[7]_i_4_CO_UNCONNECTED ;
  wire [2:0]\NLW_result_reg[7]_i_5_CO_UNCONNECTED ;

  LUT6 #(
    .INIT(64'h88888888BBB888B8)) 
    carry_out_i_1
       (.I0(carry_out_i_2_n_0),
        .I1(op[2]),
        .I2(data0),
        .I3(op[0]),
        .I4(data1),
        .I5(op[1]),
        .O(carry_out_i_1_n_0));
  LUT4 #(
    .INIT(16'hA808)) 
    carry_out_i_2
       (.I0(op[1]),
        .I1(a[7]),
        .I2(op[0]),
        .I3(a[0]),
        .O(carry_out_i_2_n_0));
  FDRE carry_out_reg
       (.C(clk),
        .CE(1'b1),
        .D(carry_out_i_1_n_0),
        .Q(carry_out),
        .R(rst));
  CARRY4 carry_out_reg_i_3
       (.CI(\result_reg[7]_i_5_n_0 ),
        .CO({NLW_carry_out_reg_i_3_CO_UNCONNECTED[3:1],data0}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_carry_out_reg_i_3_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,1'b1}));
  CARRY4 carry_out_reg_i_4
       (.CI(\result_reg[7]_i_4_n_0 ),
        .CO(NLW_carry_out_reg_i_4_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({NLW_carry_out_reg_i_4_O_UNCONNECTED[3:1],data1}),
        .S({1'b0,1'b0,1'b0,1'b1}));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[0]_i_2 
       (.I0(a[0]),
        .I1(b[0]),
        .I2(op[1]),
        .I3(\result_reg[3]_i_4_n_7 ),
        .I4(op[0]),
        .I5(\result_reg[3]_i_5_n_7 ),
        .O(\result[0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h8083B3B0)) 
    \result[0]_i_3 
       (.I0(a[1]),
        .I1(op[1]),
        .I2(op[0]),
        .I3(b[0]),
        .I4(a[0]),
        .O(\result[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[1]_i_2 
       (.I0(a[1]),
        .I1(b[1]),
        .I2(op[1]),
        .I3(\result_reg[3]_i_4_n_6 ),
        .I4(op[0]),
        .I5(\result_reg[3]_i_5_n_6 ),
        .O(\result[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA0C0A0CFAFCFAFC0)) 
    \result[1]_i_3 
       (.I0(a[2]),
        .I1(a[0]),
        .I2(op[1]),
        .I3(op[0]),
        .I4(b[1]),
        .I5(a[1]),
        .O(\result[1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[2]_i_2 
       (.I0(a[2]),
        .I1(b[2]),
        .I2(op[1]),
        .I3(\result_reg[3]_i_4_n_5 ),
        .I4(op[0]),
        .I5(\result_reg[3]_i_5_n_5 ),
        .O(\result[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA0C0A0CFAFCFAFC0)) 
    \result[2]_i_3 
       (.I0(a[3]),
        .I1(a[1]),
        .I2(op[1]),
        .I3(op[0]),
        .I4(b[2]),
        .I5(a[2]),
        .O(\result[2]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_10 
       (.I0(a[3]),
        .I1(b[3]),
        .O(\result[3]_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_11 
       (.I0(a[2]),
        .I1(b[2]),
        .O(\result[3]_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_12 
       (.I0(a[1]),
        .I1(b[1]),
        .O(\result[3]_i_12_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_13 
       (.I0(a[0]),
        .I1(b[0]),
        .O(\result[3]_i_13_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[3]_i_2 
       (.I0(a[3]),
        .I1(b[3]),
        .I2(op[1]),
        .I3(\result_reg[3]_i_4_n_4 ),
        .I4(op[0]),
        .I5(\result_reg[3]_i_5_n_4 ),
        .O(\result[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA0C0A0CFAFCFAFC0)) 
    \result[3]_i_3 
       (.I0(a[4]),
        .I1(a[2]),
        .I2(op[1]),
        .I3(op[0]),
        .I4(b[3]),
        .I5(a[3]),
        .O(\result[3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[3]_i_6 
       (.I0(a[3]),
        .I1(b[3]),
        .O(\result[3]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[3]_i_7 
       (.I0(a[2]),
        .I1(b[2]),
        .O(\result[3]_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[3]_i_8 
       (.I0(a[1]),
        .I1(b[1]),
        .O(\result[3]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[3]_i_9 
       (.I0(a[0]),
        .I1(b[0]),
        .O(\result[3]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[4]_i_2 
       (.I0(a[4]),
        .I1(b[4]),
        .I2(op[1]),
        .I3(\result_reg[7]_i_4_n_7 ),
        .I4(op[0]),
        .I5(\result_reg[7]_i_5_n_7 ),
        .O(\result[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA0C0A0CFAFCFAFC0)) 
    \result[4]_i_3 
       (.I0(a[5]),
        .I1(a[3]),
        .I2(op[1]),
        .I3(op[0]),
        .I4(b[4]),
        .I5(a[4]),
        .O(\result[4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[5]_i_2 
       (.I0(a[5]),
        .I1(b[5]),
        .I2(op[1]),
        .I3(\result_reg[7]_i_4_n_6 ),
        .I4(op[0]),
        .I5(\result_reg[7]_i_5_n_6 ),
        .O(\result[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA0C0A0CFAFCFAFC0)) 
    \result[5]_i_3 
       (.I0(a[6]),
        .I1(a[4]),
        .I2(op[1]),
        .I3(op[0]),
        .I4(b[5]),
        .I5(a[5]),
        .O(\result[5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[6]_i_2 
       (.I0(a[6]),
        .I1(b[6]),
        .I2(op[1]),
        .I3(\result_reg[7]_i_4_n_5 ),
        .I4(op[0]),
        .I5(\result_reg[7]_i_5_n_5 ),
        .O(\result[6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA0C0A0CFAFCFAFC0)) 
    \result[6]_i_3 
       (.I0(a[7]),
        .I1(a[5]),
        .I2(op[1]),
        .I3(op[0]),
        .I4(b[6]),
        .I5(a[6]),
        .O(\result[6]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[7]_i_10 
       (.I0(a[7]),
        .I1(b[7]),
        .O(\result[7]_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[7]_i_11 
       (.I0(a[6]),
        .I1(b[6]),
        .O(\result[7]_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[7]_i_12 
       (.I0(a[5]),
        .I1(b[5]),
        .O(\result[7]_i_12_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[7]_i_13 
       (.I0(a[4]),
        .I1(b[4]),
        .O(\result[7]_i_13_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[7]_i_2 
       (.I0(a[7]),
        .I1(b[7]),
        .I2(op[1]),
        .I3(\result_reg[7]_i_4_n_4 ),
        .I4(op[0]),
        .I5(\result_reg[7]_i_5_n_4 ),
        .O(\result[7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h080B3B38)) 
    \result[7]_i_3 
       (.I0(a[6]),
        .I1(op[1]),
        .I2(op[0]),
        .I3(b[7]),
        .I4(a[7]),
        .O(\result[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[7]_i_6 
       (.I0(a[7]),
        .I1(b[7]),
        .O(\result[7]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[7]_i_7 
       (.I0(a[6]),
        .I1(b[6]),
        .O(\result[7]_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[7]_i_8 
       (.I0(a[5]),
        .I1(b[5]),
        .O(\result[7]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \result[7]_i_9 
       (.I0(a[4]),
        .I1(b[4]),
        .O(\result[7]_i_9_n_0 ));
  FDRE \result_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[0]_i_1_n_0 ),
        .Q(result[0]),
        .R(rst));
  MUXF7 \result_reg[0]_i_1 
       (.I0(\result[0]_i_2_n_0 ),
        .I1(\result[0]_i_3_n_0 ),
        .O(\result_reg[0]_i_1_n_0 ),
        .S(op[2]));
  FDRE \result_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[1]_i_1_n_0 ),
        .Q(result[1]),
        .R(rst));
  MUXF7 \result_reg[1]_i_1 
       (.I0(\result[1]_i_2_n_0 ),
        .I1(\result[1]_i_3_n_0 ),
        .O(\result_reg[1]_i_1_n_0 ),
        .S(op[2]));
  FDRE \result_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[2]_i_1_n_0 ),
        .Q(result[2]),
        .R(rst));
  MUXF7 \result_reg[2]_i_1 
       (.I0(\result[2]_i_2_n_0 ),
        .I1(\result[2]_i_3_n_0 ),
        .O(\result_reg[2]_i_1_n_0 ),
        .S(op[2]));
  FDRE \result_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[3]_i_1_n_0 ),
        .Q(result[3]),
        .R(rst));
  MUXF7 \result_reg[3]_i_1 
       (.I0(\result[3]_i_2_n_0 ),
        .I1(\result[3]_i_3_n_0 ),
        .O(\result_reg[3]_i_1_n_0 ),
        .S(op[2]));
  CARRY4 \result_reg[3]_i_4 
       (.CI(1'b0),
        .CO({\result_reg[3]_i_4_n_0 ,\NLW_result_reg[3]_i_4_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b1),
        .DI(a[3:0]),
        .O({\result_reg[3]_i_4_n_4 ,\result_reg[3]_i_4_n_5 ,\result_reg[3]_i_4_n_6 ,\result_reg[3]_i_4_n_7 }),
        .S({\result[3]_i_6_n_0 ,\result[3]_i_7_n_0 ,\result[3]_i_8_n_0 ,\result[3]_i_9_n_0 }));
  CARRY4 \result_reg[3]_i_5 
       (.CI(1'b0),
        .CO({\result_reg[3]_i_5_n_0 ,\NLW_result_reg[3]_i_5_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI(a[3:0]),
        .O({\result_reg[3]_i_5_n_4 ,\result_reg[3]_i_5_n_5 ,\result_reg[3]_i_5_n_6 ,\result_reg[3]_i_5_n_7 }),
        .S({\result[3]_i_10_n_0 ,\result[3]_i_11_n_0 ,\result[3]_i_12_n_0 ,\result[3]_i_13_n_0 }));
  FDRE \result_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[4]_i_1_n_0 ),
        .Q(result[4]),
        .R(rst));
  MUXF7 \result_reg[4]_i_1 
       (.I0(\result[4]_i_2_n_0 ),
        .I1(\result[4]_i_3_n_0 ),
        .O(\result_reg[4]_i_1_n_0 ),
        .S(op[2]));
  FDRE \result_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[5]_i_1_n_0 ),
        .Q(result[5]),
        .R(rst));
  MUXF7 \result_reg[5]_i_1 
       (.I0(\result[5]_i_2_n_0 ),
        .I1(\result[5]_i_3_n_0 ),
        .O(\result_reg[5]_i_1_n_0 ),
        .S(op[2]));
  FDRE \result_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[6]_i_1_n_0 ),
        .Q(result[6]),
        .R(rst));
  MUXF7 \result_reg[6]_i_1 
       (.I0(\result[6]_i_2_n_0 ),
        .I1(\result[6]_i_3_n_0 ),
        .O(\result_reg[6]_i_1_n_0 ),
        .S(op[2]));
  FDRE \result_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\result_reg[7]_i_1_n_0 ),
        .Q(result[7]),
        .R(rst));
  MUXF7 \result_reg[7]_i_1 
       (.I0(\result[7]_i_2_n_0 ),
        .I1(\result[7]_i_3_n_0 ),
        .O(\result_reg[7]_i_1_n_0 ),
        .S(op[2]));
  CARRY4 \result_reg[7]_i_4 
       (.CI(\result_reg[3]_i_4_n_0 ),
        .CO({\result_reg[7]_i_4_n_0 ,\NLW_result_reg[7]_i_4_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI(a[7:4]),
        .O({\result_reg[7]_i_4_n_4 ,\result_reg[7]_i_4_n_5 ,\result_reg[7]_i_4_n_6 ,\result_reg[7]_i_4_n_7 }),
        .S({\result[7]_i_6_n_0 ,\result[7]_i_7_n_0 ,\result[7]_i_8_n_0 ,\result[7]_i_9_n_0 }));
  CARRY4 \result_reg[7]_i_5 
       (.CI(\result_reg[3]_i_5_n_0 ),
        .CO({\result_reg[7]_i_5_n_0 ,\NLW_result_reg[7]_i_5_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI(a[7:4]),
        .O({\result_reg[7]_i_5_n_4 ,\result_reg[7]_i_5_n_5 ,\result_reg[7]_i_5_n_6 ,\result_reg[7]_i_5_n_7 }),
        .S({\result[7]_i_10_n_0 ,\result[7]_i_11_n_0 ,\result[7]_i_12_n_0 ,\result[7]_i_13_n_0 }));
  LUT5 #(
    .INIT(32'h00000001)) 
    zero_INST_0
       (.I0(result[4]),
        .I1(result[5]),
        .I2(result[7]),
        .I3(result[6]),
        .I4(zero_INST_0_i_1_n_0),
        .O(zero));
  LUT4 #(
    .INIT(16'hFFFE)) 
    zero_INST_0_i_1
       (.I0(result[1]),
        .I1(result[0]),
        .I2(result[3]),
        .I3(result[2]),
        .O(zero_INST_0_i_1_n_0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
