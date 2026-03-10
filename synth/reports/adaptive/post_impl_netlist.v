// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Wed Mar 11 01:04:43 2026
// Host        : Gaurav running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -force
//               C:/Users/gt111/Desktop/Self-Healing_Digital_Circuit/synth/reports/adaptive/post_impl_netlist.v
// Design      : top_adaptive
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module alu
   (carry_flag,
    faulty_module,
    zero_flag,
    final_result,
    fault_detected,
    fault_detect_gated0,
    \result_reg[7]_0 ,
    E,
    rst,
    clk,
    zero_flag_0,
    Q,
    fi0_mask,
    fi0_type,
    fi0_en,
    fi1_mask,
    fi1_type,
    fi1_en,
    fi2_mask,
    fi2_type,
    fi2_en,
    \toggle_count_reg[7] ,
    a,
    b,
    op);
  output carry_flag;
  output [2:0]faulty_module;
  output zero_flag;
  output [7:0]final_result;
  output fault_detected;
  output fault_detect_gated0;
  output [7:0]\result_reg[7]_0 ;
  output [0:0]E;
  input rst;
  input clk;
  input zero_flag_0;
  input [1:0]Q;
  input [7:0]fi0_mask;
  input [1:0]fi0_type;
  input fi0_en;
  input [7:0]fi1_mask;
  input [1:0]fi1_type;
  input fi1_en;
  input [7:0]fi2_mask;
  input [1:0]fi2_type;
  input fi2_en;
  input [7:0]\toggle_count_reg[7] ;
  input [7:0]a;
  input [7:0]b;
  input [2:0]op;

  wire [0:0]E;
  wire [1:0]Q;
  wire [7:0]a;
  wire [7:0]alu0_fi;
  wire [7:0]alu1_fi;
  wire [7:0]alu2_fi;
  wire [7:0]b;
  wire carry_flag;
  wire carry_out;
  wire carry_out_i_2_n_0;
  wire carry_out_i_5_n_0;
  wire carry_out_i_6_n_0;
  wire carry_out_i_7_n_0;
  wire carry_out_i_8_n_0;
  wire carry_out_reg_i_4_n_0;
  wire carry_out_reg_i_4_n_4;
  wire carry_out_reg_i_4_n_5;
  wire carry_out_reg_i_4_n_6;
  wire carry_out_reg_i_4_n_7;
  wire clk;
  wire data0;
  wire data1;
  wire fault_detect_gated0;
  wire fault_detected;
  wire fault_detected_INST_0_i_4_n_0;
  wire fault_detected_INST_0_i_5_n_0;
  wire fault_detected_INST_0_i_6_n_0;
  wire fault_detected_INST_0_i_7_n_0;
  wire fault_detected_INST_0_i_8_n_0;
  wire fault_detected_INST_0_i_9_n_0;
  wire [2:0]faulty_module;
  wire \faulty_module[0]_INST_0_i_1_n_0 ;
  wire \faulty_module[0]_INST_0_i_2_n_0 ;
  wire \faulty_module[1]_INST_0_i_3_n_0 ;
  wire \faulty_module[1]_INST_0_i_4_n_0 ;
  wire \faulty_module[2]_INST_0_i_3_n_0 ;
  wire \faulty_module[2]_INST_0_i_4_n_0 ;
  wire fi0_en;
  wire [7:0]fi0_mask;
  wire [1:0]fi0_type;
  wire fi1_en;
  wire [7:0]fi1_mask;
  wire [1:0]fi1_type;
  wire fi2_en;
  wire [7:0]fi2_mask;
  wire [1:0]fi2_type;
  wire [7:0]final_result;
  wire [2:0]op;
  wire [7:0]result;
  wire \result[0]_i_2_n_0 ;
  wire \result[0]_i_3_n_0 ;
  wire \result[1]_i_2_n_0 ;
  wire \result[1]_i_3_n_0 ;
  wire \result[2]_i_2_n_0 ;
  wire \result[2]_i_3_n_0 ;
  wire \result[3]_i_2_n_0 ;
  wire \result[3]_i_3_n_0 ;
  wire \result[3]_i_5_n_0 ;
  wire \result[3]_i_6_n_0 ;
  wire \result[3]_i_7_n_0 ;
  wire \result[3]_i_8_n_0 ;
  wire \result[4]_i_2_n_0 ;
  wire \result[4]_i_3_n_0 ;
  wire \result[5]_i_2_n_0 ;
  wire \result[5]_i_3_n_0 ;
  wire \result[6]_i_2_n_0 ;
  wire \result[6]_i_3_n_0 ;
  wire \result[7]_i_2_n_0 ;
  wire \result[7]_i_3_n_0 ;
  wire \result_reg[3]_i_4_n_0 ;
  wire \result_reg[3]_i_4_n_4 ;
  wire \result_reg[3]_i_4_n_5 ;
  wire \result_reg[3]_i_4_n_6 ;
  wire \result_reg[3]_i_4_n_7 ;
  wire [7:0]\result_reg[7]_0 ;
  wire rst;
  wire sub_result_carry__0_n_0;
  wire sub_result_carry__0_n_4;
  wire sub_result_carry__0_n_5;
  wire sub_result_carry__0_n_6;
  wire sub_result_carry__0_n_7;
  wire sub_result_carry_i_1__0_n_0;
  wire sub_result_carry_i_1_n_0;
  wire sub_result_carry_i_2__0_n_0;
  wire sub_result_carry_i_2_n_0;
  wire sub_result_carry_i_3__0_n_0;
  wire sub_result_carry_i_3_n_0;
  wire sub_result_carry_i_4__0_n_0;
  wire sub_result_carry_i_4_n_0;
  wire sub_result_carry_n_0;
  wire sub_result_carry_n_4;
  wire sub_result_carry_n_5;
  wire sub_result_carry_n_6;
  wire sub_result_carry_n_7;
  wire \toggle_count[7]_i_3_n_0 ;
  wire \toggle_count[7]_i_4_n_0 ;
  wire [7:0]\toggle_count_reg[7] ;
  wire \u_voter/fault_detect0__14 ;
  wire \u_voter/fault_detect1__14 ;
  wire [7:0]voted_result;
  wire zero_flag;
  wire zero_flag_0;
  wire zero_flag_INST_0_i_1_n_0;
  wire [3:1]NLW_carry_out_reg_i_3_CO_UNCONNECTED;
  wire [3:0]NLW_carry_out_reg_i_3_O_UNCONNECTED;
  wire [2:0]NLW_carry_out_reg_i_4_CO_UNCONNECTED;
  wire [2:0]\NLW_result_reg[3]_i_4_CO_UNCONNECTED ;
  wire [2:0]NLW_sub_result_carry_CO_UNCONNECTED;
  wire [2:0]NLW_sub_result_carry__0_CO_UNCONNECTED;
  wire [3:0]NLW_sub_result_carry__1_CO_UNCONNECTED;
  wire [3:1]NLW_sub_result_carry__1_O_UNCONNECTED;

  LUT6 #(
    .INIT(64'h88888888BBB888B8)) 
    carry_out_i_1
       (.I0(carry_out_i_2_n_0),
        .I1(op[2]),
        .I2(data0),
        .I3(op[0]),
        .I4(data1),
        .I5(op[1]),
        .O(carry_out));
  LUT4 #(
    .INIT(16'hA808)) 
    carry_out_i_2
       (.I0(op[1]),
        .I1(a[7]),
        .I2(op[0]),
        .I3(a[0]),
        .O(carry_out_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    carry_out_i_5
       (.I0(a[7]),
        .I1(b[7]),
        .O(carry_out_i_5_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    carry_out_i_6
       (.I0(a[6]),
        .I1(b[6]),
        .O(carry_out_i_6_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    carry_out_i_7
       (.I0(a[5]),
        .I1(b[5]),
        .O(carry_out_i_7_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    carry_out_i_8
       (.I0(a[4]),
        .I1(b[4]),
        .O(carry_out_i_8_n_0));
  FDRE carry_out_reg
       (.C(clk),
        .CE(1'b1),
        .D(carry_out),
        .Q(carry_flag),
        .R(rst));
  CARRY4 carry_out_reg_i_3
       (.CI(carry_out_reg_i_4_n_0),
        .CO({NLW_carry_out_reg_i_3_CO_UNCONNECTED[3:1],data0}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_carry_out_reg_i_3_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,1'b1}));
  CARRY4 carry_out_reg_i_4
       (.CI(\result_reg[3]_i_4_n_0 ),
        .CO({carry_out_reg_i_4_n_0,NLW_carry_out_reg_i_4_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(a[7:4]),
        .O({carry_out_reg_i_4_n_4,carry_out_reg_i_4_n_5,carry_out_reg_i_4_n_6,carry_out_reg_i_4_n_7}),
        .S({carry_out_i_5_n_0,carry_out_i_6_n_0,carry_out_i_7_n_0,carry_out_i_8_n_0}));
  LUT5 #(
    .INIT(32'h5554AA00)) 
    fault_detected_INST_0
       (.I0(Q[0]),
        .I1(\u_voter/fault_detect0__14 ),
        .I2(\u_voter/fault_detect1__14 ),
        .I3(fault_detect_gated0),
        .I4(Q[1]),
        .O(fault_detected));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    fault_detected_INST_0_i_1
       (.I0(alu2_fi[7]),
        .I1(alu0_fi[7]),
        .I2(alu2_fi[6]),
        .I3(alu0_fi[6]),
        .I4(fault_detected_INST_0_i_4_n_0),
        .I5(fault_detected_INST_0_i_5_n_0),
        .O(\u_voter/fault_detect0__14 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    fault_detected_INST_0_i_2
       (.I0(alu2_fi[7]),
        .I1(alu1_fi[7]),
        .I2(alu2_fi[6]),
        .I3(alu1_fi[6]),
        .I4(fault_detected_INST_0_i_6_n_0),
        .I5(fault_detected_INST_0_i_7_n_0),
        .O(\u_voter/fault_detect1__14 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    fault_detected_INST_0_i_3
       (.I0(alu1_fi[7]),
        .I1(alu0_fi[7]),
        .I2(alu1_fi[6]),
        .I3(alu0_fi[6]),
        .I4(fault_detected_INST_0_i_8_n_0),
        .I5(fault_detected_INST_0_i_9_n_0),
        .O(fault_detect_gated0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_4
       (.I0(alu0_fi[3]),
        .I1(alu2_fi[3]),
        .I2(alu2_fi[5]),
        .I3(alu0_fi[5]),
        .I4(alu2_fi[4]),
        .I5(alu0_fi[4]),
        .O(fault_detected_INST_0_i_4_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_5
       (.I0(alu0_fi[0]),
        .I1(alu2_fi[0]),
        .I2(alu2_fi[2]),
        .I3(alu0_fi[2]),
        .I4(alu2_fi[1]),
        .I5(alu0_fi[1]),
        .O(fault_detected_INST_0_i_5_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_6
       (.I0(alu1_fi[3]),
        .I1(alu2_fi[3]),
        .I2(alu2_fi[5]),
        .I3(alu1_fi[5]),
        .I4(alu2_fi[4]),
        .I5(alu1_fi[4]),
        .O(fault_detected_INST_0_i_6_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_7
       (.I0(alu1_fi[0]),
        .I1(alu2_fi[0]),
        .I2(alu2_fi[2]),
        .I3(alu1_fi[2]),
        .I4(alu2_fi[1]),
        .I5(alu1_fi[1]),
        .O(fault_detected_INST_0_i_7_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_8
       (.I0(alu0_fi[3]),
        .I1(alu1_fi[3]),
        .I2(alu1_fi[5]),
        .I3(alu0_fi[5]),
        .I4(alu1_fi[4]),
        .I5(alu0_fi[4]),
        .O(fault_detected_INST_0_i_8_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_9
       (.I0(alu0_fi[0]),
        .I1(alu1_fi[0]),
        .I2(alu1_fi[2]),
        .I3(alu0_fi[2]),
        .I4(alu1_fi[1]),
        .I5(alu0_fi[1]),
        .O(fault_detected_INST_0_i_9_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \faulty_module[0]_INST_0 
       (.I0(voted_result[7]),
        .I1(alu0_fi[7]),
        .I2(voted_result[6]),
        .I3(alu0_fi[6]),
        .I4(\faulty_module[0]_INST_0_i_1_n_0 ),
        .I5(\faulty_module[0]_INST_0_i_2_n_0 ),
        .O(faulty_module[0]));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[0]_INST_0_i_1 
       (.I0(alu0_fi[3]),
        .I1(voted_result[3]),
        .I2(voted_result[5]),
        .I3(alu0_fi[5]),
        .I4(voted_result[4]),
        .I5(alu0_fi[4]),
        .O(\faulty_module[0]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[0]_INST_0_i_2 
       (.I0(alu0_fi[0]),
        .I1(voted_result[0]),
        .I2(voted_result[2]),
        .I3(alu0_fi[2]),
        .I4(voted_result[1]),
        .I5(alu0_fi[1]),
        .O(\faulty_module[0]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \faulty_module[1]_INST_0 
       (.I0(voted_result[7]),
        .I1(alu1_fi[7]),
        .I2(voted_result[6]),
        .I3(alu1_fi[6]),
        .I4(\faulty_module[1]_INST_0_i_3_n_0 ),
        .I5(\faulty_module[1]_INST_0_i_4_n_0 ),
        .O(faulty_module[1]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \faulty_module[1]_INST_0_i_1 
       (.I0(fi1_mask[7]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [7]),
        .O(alu1_fi[7]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \faulty_module[1]_INST_0_i_2 
       (.I0(fi1_mask[6]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [6]),
        .O(alu1_fi[6]));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[1]_INST_0_i_3 
       (.I0(alu1_fi[3]),
        .I1(voted_result[3]),
        .I2(voted_result[5]),
        .I3(alu1_fi[5]),
        .I4(voted_result[4]),
        .I5(alu1_fi[4]),
        .O(\faulty_module[1]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[1]_INST_0_i_4 
       (.I0(alu1_fi[0]),
        .I1(voted_result[0]),
        .I2(voted_result[2]),
        .I3(alu1_fi[2]),
        .I4(voted_result[1]),
        .I5(alu1_fi[1]),
        .O(\faulty_module[1]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \faulty_module[2]_INST_0 
       (.I0(voted_result[7]),
        .I1(alu2_fi[7]),
        .I2(voted_result[6]),
        .I3(alu2_fi[6]),
        .I4(\faulty_module[2]_INST_0_i_3_n_0 ),
        .I5(\faulty_module[2]_INST_0_i_4_n_0 ),
        .O(faulty_module[2]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \faulty_module[2]_INST_0_i_1 
       (.I0(fi2_mask[7]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [7]),
        .O(alu2_fi[7]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \faulty_module[2]_INST_0_i_2 
       (.I0(fi2_mask[6]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [6]),
        .O(alu2_fi[6]));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[2]_INST_0_i_3 
       (.I0(alu2_fi[3]),
        .I1(voted_result[3]),
        .I2(voted_result[5]),
        .I3(alu2_fi[5]),
        .I4(voted_result[4]),
        .I5(alu2_fi[4]),
        .O(\faulty_module[2]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[2]_INST_0_i_4 
       (.I0(alu2_fi[0]),
        .I1(voted_result[0]),
        .I2(voted_result[2]),
        .I3(alu2_fi[2]),
        .I4(voted_result[1]),
        .I5(alu2_fi[1]),
        .O(\faulty_module[2]_INST_0_i_4_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \faulty_module[2]_INST_0_i_5 
       (.I0(alu1_fi[3]),
        .I1(alu2_fi[3]),
        .I2(alu0_fi[3]),
        .O(voted_result[3]));
  LUT3 #(
    .INIT(8'hE8)) 
    \faulty_module[2]_INST_0_i_6 
       (.I0(alu1_fi[2]),
        .I1(alu2_fi[2]),
        .I2(alu0_fi[2]),
        .O(voted_result[2]));
  LUT3 #(
    .INIT(8'hE8)) 
    \faulty_module[2]_INST_0_i_7 
       (.I0(alu1_fi[1]),
        .I1(alu2_fi[1]),
        .I2(alu0_fi[1]),
        .O(voted_result[1]));
  LUT4 #(
    .INIT(16'hFB08)) 
    \final_result[0]_INST_0 
       (.I0(voted_result[0]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(alu0_fi[0]),
        .O(final_result[0]));
  LUT3 #(
    .INIT(8'hE8)) 
    \final_result[0]_INST_0_i_1 
       (.I0(alu1_fi[0]),
        .I1(alu2_fi[0]),
        .I2(alu0_fi[0]),
        .O(voted_result[0]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[0]_INST_0_i_2 
       (.I0(fi0_mask[0]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [0]),
        .O(alu0_fi[0]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[0]_INST_0_i_3 
       (.I0(fi1_mask[0]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [0]),
        .O(alu1_fi[0]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[0]_INST_0_i_4 
       (.I0(fi2_mask[0]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [0]),
        .O(alu2_fi[0]));
  LUT5 #(
    .INIT(32'hFFEF0080)) 
    \final_result[1]_INST_0 
       (.I0(alu1_fi[1]),
        .I1(alu2_fi[1]),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(alu0_fi[1]),
        .O(final_result[1]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[1]_INST_0_i_1 
       (.I0(fi1_mask[1]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [1]),
        .O(alu1_fi[1]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[1]_INST_0_i_2 
       (.I0(fi2_mask[1]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [1]),
        .O(alu2_fi[1]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[1]_INST_0_i_3 
       (.I0(fi0_mask[1]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [1]),
        .O(alu0_fi[1]));
  LUT5 #(
    .INIT(32'hFFEF0080)) 
    \final_result[2]_INST_0 
       (.I0(alu1_fi[2]),
        .I1(alu2_fi[2]),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(alu0_fi[2]),
        .O(final_result[2]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[2]_INST_0_i_1 
       (.I0(fi1_mask[2]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [2]),
        .O(alu1_fi[2]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[2]_INST_0_i_2 
       (.I0(fi2_mask[2]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [2]),
        .O(alu2_fi[2]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[2]_INST_0_i_3 
       (.I0(fi0_mask[2]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [2]),
        .O(alu0_fi[2]));
  LUT5 #(
    .INIT(32'hFFEF0080)) 
    \final_result[3]_INST_0 
       (.I0(alu1_fi[3]),
        .I1(alu2_fi[3]),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(alu0_fi[3]),
        .O(final_result[3]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[3]_INST_0_i_1 
       (.I0(fi1_mask[3]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [3]),
        .O(alu1_fi[3]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[3]_INST_0_i_2 
       (.I0(fi2_mask[3]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [3]),
        .O(alu2_fi[3]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[3]_INST_0_i_3 
       (.I0(fi0_mask[3]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [3]),
        .O(alu0_fi[3]));
  LUT4 #(
    .INIT(16'hFB08)) 
    \final_result[4]_INST_0 
       (.I0(voted_result[4]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(alu0_fi[4]),
        .O(final_result[4]));
  LUT3 #(
    .INIT(8'hE8)) 
    \final_result[4]_INST_0_i_1 
       (.I0(alu1_fi[4]),
        .I1(alu2_fi[4]),
        .I2(alu0_fi[4]),
        .O(voted_result[4]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[4]_INST_0_i_2 
       (.I0(fi0_mask[4]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [4]),
        .O(alu0_fi[4]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[4]_INST_0_i_3 
       (.I0(fi1_mask[4]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [4]),
        .O(alu1_fi[4]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[4]_INST_0_i_4 
       (.I0(fi2_mask[4]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [4]),
        .O(alu2_fi[4]));
  LUT4 #(
    .INIT(16'hFB08)) 
    \final_result[5]_INST_0 
       (.I0(voted_result[5]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(alu0_fi[5]),
        .O(final_result[5]));
  LUT3 #(
    .INIT(8'hE8)) 
    \final_result[5]_INST_0_i_1 
       (.I0(alu1_fi[5]),
        .I1(alu2_fi[5]),
        .I2(alu0_fi[5]),
        .O(voted_result[5]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[5]_INST_0_i_2 
       (.I0(fi0_mask[5]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [5]),
        .O(alu0_fi[5]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[5]_INST_0_i_3 
       (.I0(fi1_mask[5]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(\result_reg[7]_0 [5]),
        .O(alu1_fi[5]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[5]_INST_0_i_4 
       (.I0(fi2_mask[5]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(\result_reg[7]_0 [5]),
        .O(alu2_fi[5]));
  LUT4 #(
    .INIT(16'hFB08)) 
    \final_result[6]_INST_0 
       (.I0(voted_result[6]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(alu0_fi[6]),
        .O(final_result[6]));
  LUT3 #(
    .INIT(8'hE8)) 
    \final_result[6]_INST_0_i_1 
       (.I0(alu1_fi[6]),
        .I1(alu2_fi[6]),
        .I2(alu0_fi[6]),
        .O(voted_result[6]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[6]_INST_0_i_2 
       (.I0(fi0_mask[6]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [6]),
        .O(alu0_fi[6]));
  LUT4 #(
    .INIT(16'hFB08)) 
    \final_result[7]_INST_0 
       (.I0(voted_result[7]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(alu0_fi[7]),
        .O(final_result[7]));
  LUT3 #(
    .INIT(8'hE8)) 
    \final_result[7]_INST_0_i_1 
       (.I0(alu1_fi[7]),
        .I1(alu2_fi[7]),
        .I2(alu0_fi[7]),
        .O(voted_result[7]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \final_result[7]_INST_0_i_2 
       (.I0(fi0_mask[7]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(\result_reg[7]_0 [7]),
        .O(alu0_fi[7]));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[0]_i_2 
       (.I0(a[0]),
        .I1(b[0]),
        .I2(op[1]),
        .I3(sub_result_carry_n_7),
        .I4(op[0]),
        .I5(\result_reg[3]_i_4_n_7 ),
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
        .I3(sub_result_carry_n_6),
        .I4(op[0]),
        .I5(\result_reg[3]_i_4_n_6 ),
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
        .I3(sub_result_carry_n_5),
        .I4(op[0]),
        .I5(\result_reg[3]_i_4_n_5 ),
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
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[3]_i_2 
       (.I0(a[3]),
        .I1(b[3]),
        .I2(op[1]),
        .I3(sub_result_carry_n_4),
        .I4(op[0]),
        .I5(\result_reg[3]_i_4_n_4 ),
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
    .INIT(4'h6)) 
    \result[3]_i_5 
       (.I0(a[3]),
        .I1(b[3]),
        .O(\result[3]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_6 
       (.I0(a[2]),
        .I1(b[2]),
        .O(\result[3]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_7 
       (.I0(a[1]),
        .I1(b[1]),
        .O(\result[3]_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \result[3]_i_8 
       (.I0(a[0]),
        .I1(b[0]),
        .O(\result[3]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[4]_i_2 
       (.I0(a[4]),
        .I1(b[4]),
        .I2(op[1]),
        .I3(sub_result_carry__0_n_7),
        .I4(op[0]),
        .I5(carry_out_reg_i_4_n_7),
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
        .I3(sub_result_carry__0_n_6),
        .I4(op[0]),
        .I5(carry_out_reg_i_4_n_6),
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
        .I3(sub_result_carry__0_n_5),
        .I4(op[0]),
        .I5(carry_out_reg_i_4_n_5),
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
  LUT6 #(
    .INIT(64'hEFE08F8FEFE08080)) 
    \result[7]_i_2 
       (.I0(a[7]),
        .I1(b[7]),
        .I2(op[1]),
        .I3(sub_result_carry__0_n_4),
        .I4(op[0]),
        .I5(carry_out_reg_i_4_n_4),
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
  FDRE \result_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(result[0]),
        .Q(\result_reg[7]_0 [0]),
        .R(rst));
  MUXF7 \result_reg[0]_i_1 
       (.I0(\result[0]_i_2_n_0 ),
        .I1(\result[0]_i_3_n_0 ),
        .O(result[0]),
        .S(op[2]));
  FDRE \result_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(result[1]),
        .Q(\result_reg[7]_0 [1]),
        .R(rst));
  MUXF7 \result_reg[1]_i_1 
       (.I0(\result[1]_i_2_n_0 ),
        .I1(\result[1]_i_3_n_0 ),
        .O(result[1]),
        .S(op[2]));
  FDRE \result_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(result[2]),
        .Q(\result_reg[7]_0 [2]),
        .R(rst));
  MUXF7 \result_reg[2]_i_1 
       (.I0(\result[2]_i_2_n_0 ),
        .I1(\result[2]_i_3_n_0 ),
        .O(result[2]),
        .S(op[2]));
  FDRE \result_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(result[3]),
        .Q(\result_reg[7]_0 [3]),
        .R(rst));
  MUXF7 \result_reg[3]_i_1 
       (.I0(\result[3]_i_2_n_0 ),
        .I1(\result[3]_i_3_n_0 ),
        .O(result[3]),
        .S(op[2]));
  CARRY4 \result_reg[3]_i_4 
       (.CI(1'b0),
        .CO({\result_reg[3]_i_4_n_0 ,\NLW_result_reg[3]_i_4_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI(a[3:0]),
        .O({\result_reg[3]_i_4_n_4 ,\result_reg[3]_i_4_n_5 ,\result_reg[3]_i_4_n_6 ,\result_reg[3]_i_4_n_7 }),
        .S({\result[3]_i_5_n_0 ,\result[3]_i_6_n_0 ,\result[3]_i_7_n_0 ,\result[3]_i_8_n_0 }));
  FDRE \result_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(result[4]),
        .Q(\result_reg[7]_0 [4]),
        .R(rst));
  MUXF7 \result_reg[4]_i_1 
       (.I0(\result[4]_i_2_n_0 ),
        .I1(\result[4]_i_3_n_0 ),
        .O(result[4]),
        .S(op[2]));
  FDRE \result_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(result[5]),
        .Q(\result_reg[7]_0 [5]),
        .R(rst));
  MUXF7 \result_reg[5]_i_1 
       (.I0(\result[5]_i_2_n_0 ),
        .I1(\result[5]_i_3_n_0 ),
        .O(result[5]),
        .S(op[2]));
  FDRE \result_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(result[6]),
        .Q(\result_reg[7]_0 [6]),
        .R(rst));
  MUXF7 \result_reg[6]_i_1 
       (.I0(\result[6]_i_2_n_0 ),
        .I1(\result[6]_i_3_n_0 ),
        .O(result[6]),
        .S(op[2]));
  FDRE \result_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(result[7]),
        .Q(\result_reg[7]_0 [7]),
        .R(rst));
  MUXF7 \result_reg[7]_i_1 
       (.I0(\result[7]_i_2_n_0 ),
        .I1(\result[7]_i_3_n_0 ),
        .O(result[7]),
        .S(op[2]));
  CARRY4 sub_result_carry
       (.CI(1'b0),
        .CO({sub_result_carry_n_0,NLW_sub_result_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b1),
        .DI(a[3:0]),
        .O({sub_result_carry_n_4,sub_result_carry_n_5,sub_result_carry_n_6,sub_result_carry_n_7}),
        .S({sub_result_carry_i_1_n_0,sub_result_carry_i_2_n_0,sub_result_carry_i_3_n_0,sub_result_carry_i_4_n_0}));
  CARRY4 sub_result_carry__0
       (.CI(sub_result_carry_n_0),
        .CO({sub_result_carry__0_n_0,NLW_sub_result_carry__0_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI(a[7:4]),
        .O({sub_result_carry__0_n_4,sub_result_carry__0_n_5,sub_result_carry__0_n_6,sub_result_carry__0_n_7}),
        .S({sub_result_carry_i_1__0_n_0,sub_result_carry_i_2__0_n_0,sub_result_carry_i_3__0_n_0,sub_result_carry_i_4__0_n_0}));
  CARRY4 sub_result_carry__1
       (.CI(sub_result_carry__0_n_0),
        .CO(NLW_sub_result_carry__1_CO_UNCONNECTED[3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({NLW_sub_result_carry__1_O_UNCONNECTED[3:1],data1}),
        .S({1'b0,1'b0,1'b0,1'b1}));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_1
       (.I0(a[3]),
        .I1(b[3]),
        .O(sub_result_carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_1__0
       (.I0(a[7]),
        .I1(b[7]),
        .O(sub_result_carry_i_1__0_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_2
       (.I0(a[2]),
        .I1(b[2]),
        .O(sub_result_carry_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_2__0
       (.I0(a[6]),
        .I1(b[6]),
        .O(sub_result_carry_i_2__0_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_3
       (.I0(a[1]),
        .I1(b[1]),
        .O(sub_result_carry_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_3__0
       (.I0(a[5]),
        .I1(b[5]),
        .O(sub_result_carry_i_3__0_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_4
       (.I0(a[0]),
        .I1(b[0]),
        .O(sub_result_carry_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sub_result_carry_i_4__0
       (.I0(a[4]),
        .I1(b[4]),
        .O(sub_result_carry_i_4__0_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \toggle_count[7]_i_1 
       (.I0(\toggle_count_reg[7] [7]),
        .I1(\result_reg[7]_0 [7]),
        .I2(\toggle_count_reg[7] [6]),
        .I3(\result_reg[7]_0 [6]),
        .I4(\toggle_count[7]_i_3_n_0 ),
        .I5(\toggle_count[7]_i_4_n_0 ),
        .O(E));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \toggle_count[7]_i_3 
       (.I0(\result_reg[7]_0 [3]),
        .I1(\toggle_count_reg[7] [3]),
        .I2(\toggle_count_reg[7] [5]),
        .I3(\result_reg[7]_0 [5]),
        .I4(\toggle_count_reg[7] [4]),
        .I5(\result_reg[7]_0 [4]),
        .O(\toggle_count[7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \toggle_count[7]_i_4 
       (.I0(\result_reg[7]_0 [0]),
        .I1(\toggle_count_reg[7] [0]),
        .I2(\toggle_count_reg[7] [2]),
        .I3(\result_reg[7]_0 [2]),
        .I4(\toggle_count_reg[7] [1]),
        .I5(\result_reg[7]_0 [1]),
        .O(\toggle_count[7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'h00000001)) 
    zero_flag_INST_0
       (.I0(final_result[4]),
        .I1(final_result[5]),
        .I2(final_result[7]),
        .I3(final_result[6]),
        .I4(zero_flag_INST_0_i_1_n_0),
        .O(zero_flag));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFEFEA)) 
    zero_flag_INST_0_i_1
       (.I0(final_result[1]),
        .I1(voted_result[0]),
        .I2(zero_flag_0),
        .I3(alu0_fi[0]),
        .I4(final_result[3]),
        .I5(final_result[2]),
        .O(zero_flag_INST_0_i_1_n_0));
endmodule

module redundancy_controller
   (dmr_error,
    Q,
    \mode_reg[1]_0 ,
    fault_detect_gated0,
    rst,
    D,
    clk);
  output dmr_error;
  output [1:0]Q;
  output \mode_reg[1]_0 ;
  input fault_detect_gated0;
  input rst;
  input [1:0]D;
  input clk;

  wire [1:0]D;
  wire [1:0]Q;
  wire clk;
  wire dmr_error;
  wire fault_detect_gated0;
  wire \mode_reg[1]_0 ;
  wire rst;

  LUT3 #(
    .INIT(8'h40)) 
    dmr_error_INST_0
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(fault_detect_gated0),
        .O(dmr_error));
  FDRE \mode_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(D[0]),
        .Q(Q[0]),
        .R(rst));
  FDRE \mode_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(D[1]),
        .Q(Q[1]),
        .R(rst));
  LUT2 #(
    .INIT(4'h2)) 
    zero_flag_INST_0_i_2
       (.I0(Q[1]),
        .I1(Q[0]),
        .O(\mode_reg[1]_0 ));
endmodule

module risk_estimator
   (D,
    risk_score,
    Q,
    rst,
    clk,
    \prev_signal_reg[7]_0 ,
    fault_detected,
    E);
  output [1:0]D;
  output [0:0]risk_score;
  output [7:0]Q;
  input rst;
  input clk;
  input [7:0]\prev_signal_reg[7]_0 ;
  input fault_detected;
  input [0:0]E;

  wire [1:0]D;
  wire [0:0]E;
  wire [7:0]Q;
  wire clk;
  wire \error_count[7]_i_2_n_0 ;
  wire [7:1]error_count_reg;
  wire \error_count_reg_n_0_[0] ;
  wire fault_detected;
  wire [7:0]p_0_in;
  wire [7:0]p_0_in__0;
  wire [7:0]\prev_signal_reg[7]_0 ;
  wire [0:0]risk_score;
  wire risk_score2;
  wire risk_score31_in;
  wire risk_score4;
  wire \risk_score[0]_i_1_n_0 ;
  wire \risk_score[0]_i_3_n_0 ;
  wire \risk_score[0]_i_4_n_0 ;
  wire \risk_score[0]_i_5_n_0 ;
  wire \risk_score[0]_i_6_n_0 ;
  wire \risk_score[1]_i_1_n_0 ;
  wire \risk_score[1]_i_4_n_0 ;
  wire rst;
  wire toggle_count;
  wire \toggle_count[7]_i_5_n_0 ;
  wire [7:1]toggle_count_reg;
  wire \toggle_count_reg_n_0_[0] ;
  wire \window_timer[0]_i_1_n_0 ;
  wire \window_timer[1]_i_1_n_0 ;
  wire \window_timer[2]_i_1_n_0 ;
  wire \window_timer[3]_i_1_n_0 ;
  wire \window_timer[4]_i_1_n_0 ;
  wire \window_timer[5]_i_1_n_0 ;
  wire \window_timer[6]_i_1_n_0 ;
  wire \window_timer[6]_i_2_n_0 ;
  wire \window_timer[6]_i_3_n_0 ;
  wire [6:0]window_timer_reg;

  LUT1 #(
    .INIT(2'h1)) 
    \error_count[0]_i_1 
       (.I0(\error_count_reg_n_0_[0] ),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \error_count[1]_i_1 
       (.I0(\error_count_reg_n_0_[0] ),
        .I1(error_count_reg[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \error_count[2]_i_1 
       (.I0(\error_count_reg_n_0_[0] ),
        .I1(error_count_reg[1]),
        .I2(error_count_reg[2]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \error_count[3]_i_1 
       (.I0(error_count_reg[1]),
        .I1(\error_count_reg_n_0_[0] ),
        .I2(error_count_reg[2]),
        .I3(error_count_reg[3]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \error_count[4]_i_1 
       (.I0(error_count_reg[2]),
        .I1(\error_count_reg_n_0_[0] ),
        .I2(error_count_reg[1]),
        .I3(error_count_reg[3]),
        .I4(error_count_reg[4]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \error_count[5]_i_1 
       (.I0(error_count_reg[3]),
        .I1(error_count_reg[1]),
        .I2(\error_count_reg_n_0_[0] ),
        .I3(error_count_reg[2]),
        .I4(error_count_reg[4]),
        .I5(error_count_reg[5]),
        .O(p_0_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \error_count[6]_i_1 
       (.I0(\error_count[7]_i_2_n_0 ),
        .I1(error_count_reg[6]),
        .O(p_0_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \error_count[7]_i_1 
       (.I0(\error_count[7]_i_2_n_0 ),
        .I1(error_count_reg[6]),
        .I2(error_count_reg[7]),
        .O(p_0_in[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \error_count[7]_i_2 
       (.I0(error_count_reg[5]),
        .I1(error_count_reg[3]),
        .I2(error_count_reg[1]),
        .I3(\error_count_reg_n_0_[0] ),
        .I4(error_count_reg[2]),
        .I5(error_count_reg[4]),
        .O(\error_count[7]_i_2_n_0 ));
  FDRE \error_count_reg[0] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[0]),
        .Q(\error_count_reg_n_0_[0] ),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[1] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[1]),
        .Q(error_count_reg[1]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[2] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[2]),
        .Q(error_count_reg[2]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[3] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[3]),
        .Q(error_count_reg[3]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[4] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[4]),
        .Q(error_count_reg[4]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[5] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[5]),
        .Q(error_count_reg[5]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[6] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[6]),
        .Q(error_count_reg[6]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \error_count_reg[7] 
       (.C(clk),
        .CE(fault_detected),
        .D(p_0_in[7]),
        .Q(error_count_reg[7]),
        .R(\window_timer[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \mode[0]_i_1 
       (.I0(risk_score),
        .I1(D[1]),
        .O(D[0]));
  FDRE \prev_signal_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [0]),
        .Q(Q[0]),
        .R(rst));
  FDRE \prev_signal_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [1]),
        .Q(Q[1]),
        .R(rst));
  FDRE \prev_signal_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [2]),
        .Q(Q[2]),
        .R(rst));
  FDRE \prev_signal_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [3]),
        .Q(Q[3]),
        .R(rst));
  FDRE \prev_signal_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [4]),
        .Q(Q[4]),
        .R(rst));
  FDRE \prev_signal_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [5]),
        .Q(Q[5]),
        .R(rst));
  FDRE \prev_signal_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [6]),
        .Q(Q[6]),
        .R(rst));
  FDRE \prev_signal_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\prev_signal_reg[7]_0 [7]),
        .Q(Q[7]),
        .R(rst));
  LUT6 #(
    .INIT(64'h00000000EEEEEEE2)) 
    \risk_score[0]_i_1 
       (.I0(risk_score),
        .I1(toggle_count),
        .I2(risk_score4),
        .I3(toggle_count_reg[4]),
        .I4(\risk_score[0]_i_3_n_0 ),
        .I5(\risk_score[0]_i_4_n_0 ),
        .O(\risk_score[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \risk_score[0]_i_2 
       (.I0(error_count_reg[3]),
        .I1(error_count_reg[4]),
        .I2(error_count_reg[2]),
        .I3(error_count_reg[7]),
        .I4(error_count_reg[1]),
        .I5(\risk_score[0]_i_5_n_0 ),
        .O(risk_score4));
  LUT6 #(
    .INIT(64'hFFFFFFFFFEFEFEEE)) 
    \risk_score[0]_i_3 
       (.I0(toggle_count_reg[6]),
        .I1(toggle_count_reg[5]),
        .I2(toggle_count_reg[3]),
        .I3(toggle_count_reg[1]),
        .I4(toggle_count_reg[2]),
        .I5(toggle_count_reg[7]),
        .O(\risk_score[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAABAAAAAAAAAAAAA)) 
    \risk_score[0]_i_4 
       (.I0(rst),
        .I1(\risk_score[0]_i_6_n_0 ),
        .I2(risk_score2),
        .I3(window_timer_reg[6]),
        .I4(window_timer_reg[4]),
        .I5(window_timer_reg[5]),
        .O(\risk_score[0]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \risk_score[0]_i_5 
       (.I0(error_count_reg[5]),
        .I1(error_count_reg[6]),
        .O(\risk_score[0]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'h7FFF)) 
    \risk_score[0]_i_6 
       (.I0(window_timer_reg[2]),
        .I1(window_timer_reg[3]),
        .I2(window_timer_reg[0]),
        .I3(window_timer_reg[1]),
        .O(\risk_score[0]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \risk_score[1]_i_1 
       (.I0(risk_score2),
        .I1(toggle_count),
        .I2(D[1]),
        .O(\risk_score[1]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \risk_score[1]_i_2 
       (.I0(\risk_score[1]_i_4_n_0 ),
        .I1(toggle_count_reg[5]),
        .I2(toggle_count_reg[6]),
        .I3(risk_score31_in),
        .O(risk_score2));
  LUT6 #(
    .INIT(64'h0008000000000000)) 
    \risk_score[1]_i_3 
       (.I0(window_timer_reg[5]),
        .I1(window_timer_reg[4]),
        .I2(window_timer_reg[6]),
        .I3(\window_timer[6]_i_3_n_0 ),
        .I4(window_timer_reg[3]),
        .I5(window_timer_reg[2]),
        .O(toggle_count));
  LUT5 #(
    .INIT(32'hEAAAAAAA)) 
    \risk_score[1]_i_4 
       (.I0(toggle_count_reg[7]),
        .I1(toggle_count_reg[3]),
        .I2(toggle_count_reg[4]),
        .I3(toggle_count_reg[1]),
        .I4(toggle_count_reg[2]),
        .O(\risk_score[1]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \risk_score[1]_i_5 
       (.I0(error_count_reg[4]),
        .I1(error_count_reg[3]),
        .I2(error_count_reg[7]),
        .I3(error_count_reg[2]),
        .I4(error_count_reg[5]),
        .I5(error_count_reg[6]),
        .O(risk_score31_in));
  FDRE \risk_score_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\risk_score[0]_i_1_n_0 ),
        .Q(risk_score),
        .R(1'b0));
  FDRE \risk_score_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\risk_score[1]_i_1_n_0 ),
        .Q(D[1]),
        .R(rst));
  LUT1 #(
    .INIT(2'h1)) 
    \toggle_count[0]_i_1 
       (.I0(\toggle_count_reg_n_0_[0] ),
        .O(p_0_in__0[0]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \toggle_count[1]_i_1 
       (.I0(\toggle_count_reg_n_0_[0] ),
        .I1(toggle_count_reg[1]),
        .O(p_0_in__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \toggle_count[2]_i_1 
       (.I0(\toggle_count_reg_n_0_[0] ),
        .I1(toggle_count_reg[1]),
        .I2(toggle_count_reg[2]),
        .O(p_0_in__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \toggle_count[3]_i_1 
       (.I0(toggle_count_reg[1]),
        .I1(\toggle_count_reg_n_0_[0] ),
        .I2(toggle_count_reg[2]),
        .I3(toggle_count_reg[3]),
        .O(p_0_in__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \toggle_count[4]_i_1 
       (.I0(toggle_count_reg[2]),
        .I1(\toggle_count_reg_n_0_[0] ),
        .I2(toggle_count_reg[1]),
        .I3(toggle_count_reg[3]),
        .I4(toggle_count_reg[4]),
        .O(p_0_in__0[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \toggle_count[5]_i_1 
       (.I0(toggle_count_reg[3]),
        .I1(toggle_count_reg[1]),
        .I2(\toggle_count_reg_n_0_[0] ),
        .I3(toggle_count_reg[2]),
        .I4(toggle_count_reg[4]),
        .I5(toggle_count_reg[5]),
        .O(p_0_in__0[5]));
  LUT2 #(
    .INIT(4'h6)) 
    \toggle_count[6]_i_1 
       (.I0(\toggle_count[7]_i_5_n_0 ),
        .I1(toggle_count_reg[6]),
        .O(p_0_in__0[6]));
  LUT3 #(
    .INIT(8'h78)) 
    \toggle_count[7]_i_2 
       (.I0(\toggle_count[7]_i_5_n_0 ),
        .I1(toggle_count_reg[6]),
        .I2(toggle_count_reg[7]),
        .O(p_0_in__0[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \toggle_count[7]_i_5 
       (.I0(toggle_count_reg[5]),
        .I1(toggle_count_reg[3]),
        .I2(toggle_count_reg[1]),
        .I3(\toggle_count_reg_n_0_[0] ),
        .I4(toggle_count_reg[2]),
        .I5(toggle_count_reg[4]),
        .O(\toggle_count[7]_i_5_n_0 ));
  FDRE \toggle_count_reg[0] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[0]),
        .Q(\toggle_count_reg_n_0_[0] ),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[1] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[1]),
        .Q(toggle_count_reg[1]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[2] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[2]),
        .Q(toggle_count_reg[2]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[3] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[3]),
        .Q(toggle_count_reg[3]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[4] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[4]),
        .Q(toggle_count_reg[4]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[5] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[5]),
        .Q(toggle_count_reg[5]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[6] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[6]),
        .Q(toggle_count_reg[6]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \toggle_count_reg[7] 
       (.C(clk),
        .CE(E),
        .D(p_0_in__0[7]),
        .Q(toggle_count_reg[7]),
        .R(\window_timer[6]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \window_timer[0]_i_1 
       (.I0(window_timer_reg[0]),
        .O(\window_timer[0]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \window_timer[1]_i_1 
       (.I0(window_timer_reg[0]),
        .I1(window_timer_reg[1]),
        .O(\window_timer[1]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h78)) 
    \window_timer[2]_i_1 
       (.I0(window_timer_reg[0]),
        .I1(window_timer_reg[1]),
        .I2(window_timer_reg[2]),
        .O(\window_timer[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \window_timer[3]_i_1 
       (.I0(window_timer_reg[1]),
        .I1(window_timer_reg[0]),
        .I2(window_timer_reg[2]),
        .I3(window_timer_reg[3]),
        .O(\window_timer[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \window_timer[4]_i_1 
       (.I0(window_timer_reg[2]),
        .I1(window_timer_reg[0]),
        .I2(window_timer_reg[1]),
        .I3(window_timer_reg[3]),
        .I4(window_timer_reg[4]),
        .O(\window_timer[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \window_timer[5]_i_1 
       (.I0(window_timer_reg[3]),
        .I1(window_timer_reg[1]),
        .I2(window_timer_reg[0]),
        .I3(window_timer_reg[2]),
        .I4(window_timer_reg[4]),
        .I5(window_timer_reg[5]),
        .O(\window_timer[5]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \window_timer[6]_i_1 
       (.I0(rst),
        .I1(toggle_count),
        .O(\window_timer[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF7FFFFFF08000000)) 
    \window_timer[6]_i_2 
       (.I0(window_timer_reg[4]),
        .I1(window_timer_reg[2]),
        .I2(\window_timer[6]_i_3_n_0 ),
        .I3(window_timer_reg[3]),
        .I4(window_timer_reg[5]),
        .I5(window_timer_reg[6]),
        .O(\window_timer[6]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \window_timer[6]_i_3 
       (.I0(window_timer_reg[1]),
        .I1(window_timer_reg[0]),
        .O(\window_timer[6]_i_3_n_0 ));
  FDRE \window_timer_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[0]_i_1_n_0 ),
        .Q(window_timer_reg[0]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \window_timer_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[1]_i_1_n_0 ),
        .Q(window_timer_reg[1]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \window_timer_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[2]_i_1_n_0 ),
        .Q(window_timer_reg[2]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \window_timer_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[3]_i_1_n_0 ),
        .Q(window_timer_reg[3]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \window_timer_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[4]_i_1_n_0 ),
        .Q(window_timer_reg[4]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \window_timer_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[5]_i_1_n_0 ),
        .Q(window_timer_reg[5]),
        .R(\window_timer[6]_i_1_n_0 ));
  FDRE \window_timer_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\window_timer[6]_i_2_n_0 ),
        .Q(window_timer_reg[6]),
        .R(\window_timer[6]_i_1_n_0 ));
endmodule

(* ECO_CHECKSUM = "1898c681" *) 
(* NotValidForBitStream *)
module top_adaptive
   (clk,
    rst,
    a,
    b,
    op,
    fi0_en,
    fi0_type,
    fi0_mask,
    fi1_en,
    fi1_type,
    fi1_mask,
    fi2_en,
    fi2_type,
    fi2_mask,
    final_result,
    zero_flag,
    carry_flag,
    risk_score,
    redundancy_mode,
    fault_detected,
    dmr_error,
    faulty_module);
  input clk;
  input rst;
  input [7:0]a;
  input [7:0]b;
  input [2:0]op;
  input fi0_en;
  input [1:0]fi0_type;
  input [7:0]fi0_mask;
  input fi1_en;
  input [1:0]fi1_type;
  input [7:0]fi1_mask;
  input fi2_en;
  input [1:0]fi2_type;
  input [7:0]fi2_mask;
  output [7:0]final_result;
  output zero_flag;
  output carry_flag;
  output [1:0]risk_score;
  output [1:0]redundancy_mode;
  output fault_detected;
  output dmr_error;
  output [2:0]faulty_module;

  wire [7:0]a;
  wire [7:0]alu0_raw;
  wire [7:0]b;
  wire carry_flag;
  wire clk;
  wire dmr_error;
  wire fault_detect_gated0;
  wire fault_detected;
  wire [2:0]faulty_module;
  wire fi0_en;
  wire [7:0]fi0_mask;
  wire [1:0]fi0_type;
  wire fi1_en;
  wire [7:0]fi1_mask;
  wire [1:0]fi1_type;
  wire fi2_en;
  wire [7:0]fi2_mask;
  wire [1:0]fi2_type;
  wire [7:0]final_result;
  wire [2:0]op;
  wire [7:0]prev_signal;
  wire [1:0]redundancy_mode;
  wire [1:0]risk_score;
  wire rst;
  wire sel;
  wire u_ctrl_n_3;
  wire u_risk_n_1;
  wire zero_flag;

  alu u_alu0
       (.E(sel),
        .Q(redundancy_mode),
        .a(a),
        .b(b),
        .carry_flag(carry_flag),
        .clk(clk),
        .fault_detect_gated0(fault_detect_gated0),
        .fault_detected(fault_detected),
        .faulty_module(faulty_module),
        .fi0_en(fi0_en),
        .fi0_mask(fi0_mask),
        .fi0_type(fi0_type),
        .fi1_en(fi1_en),
        .fi1_mask(fi1_mask),
        .fi1_type(fi1_type),
        .fi2_en(fi2_en),
        .fi2_mask(fi2_mask),
        .fi2_type(fi2_type),
        .final_result(final_result),
        .op(op),
        .\result_reg[7]_0 (alu0_raw),
        .rst(rst),
        .\toggle_count_reg[7] (prev_signal),
        .zero_flag(zero_flag),
        .zero_flag_0(u_ctrl_n_3));
  redundancy_controller u_ctrl
       (.D({risk_score[1],u_risk_n_1}),
        .Q(redundancy_mode),
        .clk(clk),
        .dmr_error(dmr_error),
        .fault_detect_gated0(fault_detect_gated0),
        .\mode_reg[1]_0 (u_ctrl_n_3),
        .rst(rst));
  risk_estimator u_risk
       (.D({risk_score[1],u_risk_n_1}),
        .E(sel),
        .Q(prev_signal),
        .clk(clk),
        .fault_detected(fault_detected),
        .\prev_signal_reg[7]_0 (alu0_raw),
        .risk_score(risk_score[0]),
        .rst(rst));
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
