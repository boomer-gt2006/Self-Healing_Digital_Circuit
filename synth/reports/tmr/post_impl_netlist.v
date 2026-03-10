// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Wed Mar 11 01:03:53 2026
// Host        : Gaurav running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -force
//               C:/Users/gt111/Desktop/Self-Healing_Digital_Circuit/synth/reports/tmr/post_impl_netlist.v
// Design      : top_tmr
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module alu
   (carry_out,
    faulty_module,
    fi1_mask_7_sp_1,
    fi1_mask_6_sp_1,
    fi1_mask_0_sp_1,
    fi1_mask_2_sp_1,
    fi1_mask_1_sp_1,
    fault_detected,
    zero,
    fi1_mask_4_sp_1,
    fi1_mask_5_sp_1,
    fi1_mask_3_sp_1,
    rst,
    clk,
    a,
    b,
    fi0_mask,
    fi0_type,
    fi0_en,
    fi1_mask,
    fi1_type,
    fi1_en,
    fi2_mask,
    fi2_type,
    fi2_en,
    op);
  output carry_out;
  output [2:0]faulty_module;
  output fi1_mask_7_sp_1;
  output fi1_mask_6_sp_1;
  output fi1_mask_0_sp_1;
  output fi1_mask_2_sp_1;
  output fi1_mask_1_sp_1;
  output fault_detected;
  output zero;
  output fi1_mask_4_sp_1;
  output fi1_mask_5_sp_1;
  output fi1_mask_3_sp_1;
  input rst;
  input clk;
  input [7:0]a;
  input [7:0]b;
  input [7:0]fi0_mask;
  input [1:0]fi0_type;
  input fi0_en;
  input [7:0]fi1_mask;
  input [1:0]fi1_type;
  input fi1_en;
  input [7:0]fi2_mask;
  input [1:0]fi2_type;
  input fi2_en;
  input [2:0]op;

  wire [7:0]a;
  wire [7:0]alu0_fi;
  wire [7:0]alu0_raw;
  wire [7:0]alu1_fi;
  wire [7:0]alu2_fi;
  wire [7:0]b;
  wire carry_out;
  wire carry_out_0;
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
  wire \faulty_module[1]_INST_0_i_1_n_0 ;
  wire \faulty_module[1]_INST_0_i_2_n_0 ;
  wire \faulty_module[2]_INST_0_i_1_n_0 ;
  wire \faulty_module[2]_INST_0_i_2_n_0 ;
  wire fi0_en;
  wire [7:0]fi0_mask;
  wire [1:0]fi0_type;
  wire fi1_en;
  wire [7:0]fi1_mask;
  wire fi1_mask_0_sn_1;
  wire fi1_mask_1_sn_1;
  wire fi1_mask_2_sn_1;
  wire fi1_mask_3_sn_1;
  wire fi1_mask_4_sn_1;
  wire fi1_mask_5_sn_1;
  wire fi1_mask_6_sn_1;
  wire fi1_mask_7_sn_1;
  wire [1:0]fi1_type;
  wire fi2_en;
  wire [7:0]fi2_mask;
  wire [1:0]fi2_type;
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
  wire \u_voter/fault_detect0__14 ;
  wire \u_voter/fault_detect10_out ;
  wire \u_voter/fault_detect1__14 ;
  wire zero;
  wire zero_INST_0_i_1_n_0;
  wire [3:1]NLW_carry_out_reg_i_3_CO_UNCONNECTED;
  wire [3:0]NLW_carry_out_reg_i_3_O_UNCONNECTED;
  wire [2:0]NLW_carry_out_reg_i_4_CO_UNCONNECTED;
  wire [2:0]\NLW_result_reg[3]_i_4_CO_UNCONNECTED ;
  wire [2:0]NLW_sub_result_carry_CO_UNCONNECTED;
  wire [2:0]NLW_sub_result_carry__0_CO_UNCONNECTED;
  wire [3:0]NLW_sub_result_carry__1_CO_UNCONNECTED;
  wire [3:1]NLW_sub_result_carry__1_O_UNCONNECTED;

  assign fi1_mask_0_sp_1 = fi1_mask_0_sn_1;
  assign fi1_mask_1_sp_1 = fi1_mask_1_sn_1;
  assign fi1_mask_2_sp_1 = fi1_mask_2_sn_1;
  assign fi1_mask_3_sp_1 = fi1_mask_3_sn_1;
  assign fi1_mask_4_sp_1 = fi1_mask_4_sn_1;
  assign fi1_mask_5_sp_1 = fi1_mask_5_sn_1;
  assign fi1_mask_6_sp_1 = fi1_mask_6_sn_1;
  assign fi1_mask_7_sp_1 = fi1_mask_7_sn_1;
  LUT6 #(
    .INIT(64'h88888888BBB888B8)) 
    carry_out_i_1
       (.I0(carry_out_i_2_n_0),
        .I1(op[2]),
        .I2(data0),
        .I3(op[0]),
        .I4(data1),
        .I5(op[1]),
        .O(carry_out_0));
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
        .D(carry_out_0),
        .Q(carry_out),
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
  LUT3 #(
    .INIT(8'hFE)) 
    fault_detected_INST_0
       (.I0(\u_voter/fault_detect10_out ),
        .I1(\u_voter/fault_detect1__14 ),
        .I2(\u_voter/fault_detect0__14 ),
        .O(fault_detected));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    fault_detected_INST_0_i_1
       (.I0(alu1_fi[7]),
        .I1(alu0_fi[7]),
        .I2(alu1_fi[6]),
        .I3(alu0_fi[6]),
        .I4(fault_detected_INST_0_i_4_n_0),
        .I5(fault_detected_INST_0_i_5_n_0),
        .O(\u_voter/fault_detect10_out ));
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
       (.I0(alu2_fi[7]),
        .I1(alu0_fi[7]),
        .I2(alu2_fi[6]),
        .I3(alu0_fi[6]),
        .I4(fault_detected_INST_0_i_8_n_0),
        .I5(fault_detected_INST_0_i_9_n_0),
        .O(\u_voter/fault_detect0__14 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_4
       (.I0(alu0_fi[3]),
        .I1(alu1_fi[3]),
        .I2(alu1_fi[5]),
        .I3(alu0_fi[5]),
        .I4(alu1_fi[4]),
        .I5(alu0_fi[4]),
        .O(fault_detected_INST_0_i_4_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_5
       (.I0(alu0_fi[0]),
        .I1(alu1_fi[0]),
        .I2(alu1_fi[2]),
        .I3(alu0_fi[2]),
        .I4(alu1_fi[1]),
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
        .I1(alu2_fi[3]),
        .I2(alu2_fi[5]),
        .I3(alu0_fi[5]),
        .I4(alu2_fi[4]),
        .I5(alu0_fi[4]),
        .O(fault_detected_INST_0_i_8_n_0));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    fault_detected_INST_0_i_9
       (.I0(alu0_fi[0]),
        .I1(alu2_fi[0]),
        .I2(alu2_fi[2]),
        .I3(alu0_fi[2]),
        .I4(alu2_fi[1]),
        .I5(alu0_fi[1]),
        .O(fault_detected_INST_0_i_9_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \faulty_module[0]_INST_0 
       (.I0(fi1_mask_7_sn_1),
        .I1(alu0_fi[7]),
        .I2(fi1_mask_6_sn_1),
        .I3(alu0_fi[6]),
        .I4(\faulty_module[0]_INST_0_i_1_n_0 ),
        .I5(\faulty_module[0]_INST_0_i_2_n_0 ),
        .O(faulty_module[0]));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[0]_INST_0_i_1 
       (.I0(alu0_fi[3]),
        .I1(fi1_mask_3_sn_1),
        .I2(fi1_mask_5_sn_1),
        .I3(alu0_fi[5]),
        .I4(fi1_mask_4_sn_1),
        .I5(alu0_fi[4]),
        .O(\faulty_module[0]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[0]_INST_0_i_2 
       (.I0(alu0_fi[0]),
        .I1(fi1_mask_0_sn_1),
        .I2(fi1_mask_2_sn_1),
        .I3(alu0_fi[2]),
        .I4(fi1_mask_1_sn_1),
        .I5(alu0_fi[1]),
        .O(\faulty_module[0]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \faulty_module[1]_INST_0 
       (.I0(fi1_mask_7_sn_1),
        .I1(alu1_fi[7]),
        .I2(fi1_mask_6_sn_1),
        .I3(alu1_fi[6]),
        .I4(\faulty_module[1]_INST_0_i_1_n_0 ),
        .I5(\faulty_module[1]_INST_0_i_2_n_0 ),
        .O(faulty_module[1]));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[1]_INST_0_i_1 
       (.I0(alu1_fi[3]),
        .I1(fi1_mask_3_sn_1),
        .I2(fi1_mask_5_sn_1),
        .I3(alu1_fi[5]),
        .I4(fi1_mask_4_sn_1),
        .I5(alu1_fi[4]),
        .O(\faulty_module[1]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[1]_INST_0_i_2 
       (.I0(alu1_fi[0]),
        .I1(fi1_mask_0_sn_1),
        .I2(fi1_mask_2_sn_1),
        .I3(alu1_fi[2]),
        .I4(fi1_mask_1_sn_1),
        .I5(alu1_fi[1]),
        .O(\faulty_module[1]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF6FF6)) 
    \faulty_module[2]_INST_0 
       (.I0(fi1_mask_7_sn_1),
        .I1(alu2_fi[7]),
        .I2(fi1_mask_6_sn_1),
        .I3(alu2_fi[6]),
        .I4(\faulty_module[2]_INST_0_i_1_n_0 ),
        .I5(\faulty_module[2]_INST_0_i_2_n_0 ),
        .O(faulty_module[2]));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[2]_INST_0_i_1 
       (.I0(alu2_fi[3]),
        .I1(fi1_mask_3_sn_1),
        .I2(fi1_mask_5_sn_1),
        .I3(alu2_fi[5]),
        .I4(fi1_mask_4_sn_1),
        .I5(alu2_fi[4]),
        .O(\faulty_module[2]_INST_0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \faulty_module[2]_INST_0_i_2 
       (.I0(alu2_fi[0]),
        .I1(fi1_mask_0_sn_1),
        .I2(fi1_mask_2_sn_1),
        .I3(alu2_fi[2]),
        .I4(fi1_mask_1_sn_1),
        .I5(alu2_fi[1]),
        .O(\faulty_module[2]_INST_0_i_2_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \result[0]_INST_0 
       (.I0(alu1_fi[0]),
        .I1(alu2_fi[0]),
        .I2(alu0_fi[0]),
        .O(fi1_mask_0_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[0]_INST_0_i_1 
       (.I0(fi1_mask[0]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[0]),
        .O(alu1_fi[0]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[0]_INST_0_i_2 
       (.I0(fi2_mask[0]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[0]),
        .O(alu2_fi[0]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[0]_INST_0_i_3 
       (.I0(fi0_mask[0]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[0]),
        .O(alu0_fi[0]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[1]_INST_0 
       (.I0(alu1_fi[1]),
        .I1(alu2_fi[1]),
        .I2(alu0_fi[1]),
        .O(fi1_mask_1_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[1]_INST_0_i_1 
       (.I0(fi1_mask[1]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[1]),
        .O(alu1_fi[1]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[1]_INST_0_i_2 
       (.I0(fi2_mask[1]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[1]),
        .O(alu2_fi[1]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[1]_INST_0_i_3 
       (.I0(fi0_mask[1]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[1]),
        .O(alu0_fi[1]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[2]_INST_0 
       (.I0(alu1_fi[2]),
        .I1(alu2_fi[2]),
        .I2(alu0_fi[2]),
        .O(fi1_mask_2_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[2]_INST_0_i_1 
       (.I0(fi1_mask[2]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[2]),
        .O(alu1_fi[2]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[2]_INST_0_i_2 
       (.I0(fi2_mask[2]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[2]),
        .O(alu2_fi[2]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[2]_INST_0_i_3 
       (.I0(fi0_mask[2]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[2]),
        .O(alu0_fi[2]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[3]_INST_0 
       (.I0(alu1_fi[3]),
        .I1(alu2_fi[3]),
        .I2(alu0_fi[3]),
        .O(fi1_mask_3_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[3]_INST_0_i_1 
       (.I0(fi1_mask[3]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[3]),
        .O(alu1_fi[3]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[3]_INST_0_i_2 
       (.I0(fi2_mask[3]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[3]),
        .O(alu2_fi[3]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[3]_INST_0_i_3 
       (.I0(fi0_mask[3]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[3]),
        .O(alu0_fi[3]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[4]_INST_0 
       (.I0(alu1_fi[4]),
        .I1(alu2_fi[4]),
        .I2(alu0_fi[4]),
        .O(fi1_mask_4_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[4]_INST_0_i_1 
       (.I0(fi1_mask[4]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[4]),
        .O(alu1_fi[4]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[4]_INST_0_i_2 
       (.I0(fi2_mask[4]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[4]),
        .O(alu2_fi[4]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[4]_INST_0_i_3 
       (.I0(fi0_mask[4]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[4]),
        .O(alu0_fi[4]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[5]_INST_0 
       (.I0(alu1_fi[5]),
        .I1(alu2_fi[5]),
        .I2(alu0_fi[5]),
        .O(fi1_mask_5_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[5]_INST_0_i_1 
       (.I0(fi1_mask[5]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[5]),
        .O(alu1_fi[5]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[5]_INST_0_i_2 
       (.I0(fi2_mask[5]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[5]),
        .O(alu2_fi[5]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[5]_INST_0_i_3 
       (.I0(fi0_mask[5]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[5]),
        .O(alu0_fi[5]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[6]_INST_0 
       (.I0(alu1_fi[6]),
        .I1(alu2_fi[6]),
        .I2(alu0_fi[6]),
        .O(fi1_mask_6_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[6]_INST_0_i_1 
       (.I0(fi1_mask[6]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[6]),
        .O(alu1_fi[6]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[6]_INST_0_i_2 
       (.I0(fi2_mask[6]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[6]),
        .O(alu2_fi[6]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[6]_INST_0_i_3 
       (.I0(fi0_mask[6]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[6]),
        .O(alu0_fi[6]));
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
  LUT3 #(
    .INIT(8'hE8)) 
    \result[7]_INST_0 
       (.I0(alu1_fi[7]),
        .I1(alu2_fi[7]),
        .I2(alu0_fi[7]),
        .O(fi1_mask_7_sn_1));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[7]_INST_0_i_1 
       (.I0(fi1_mask[7]),
        .I1(fi1_type[1]),
        .I2(fi1_type[0]),
        .I3(fi1_en),
        .I4(alu0_raw[7]),
        .O(alu1_fi[7]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[7]_INST_0_i_2 
       (.I0(fi2_mask[7]),
        .I1(fi2_type[1]),
        .I2(fi2_type[0]),
        .I3(fi2_en),
        .I4(alu0_raw[7]),
        .O(alu2_fi[7]));
  LUT5 #(
    .INIT(32'h5FFF8800)) 
    \result[7]_INST_0_i_3 
       (.I0(fi0_mask[7]),
        .I1(fi0_type[1]),
        .I2(fi0_type[0]),
        .I3(fi0_en),
        .I4(alu0_raw[7]),
        .O(alu0_fi[7]));
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
        .Q(alu0_raw[0]),
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
        .Q(alu0_raw[1]),
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
        .Q(alu0_raw[2]),
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
        .Q(alu0_raw[3]),
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
        .Q(alu0_raw[4]),
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
        .Q(alu0_raw[5]),
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
        .Q(alu0_raw[6]),
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
        .Q(alu0_raw[7]),
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
  LUT5 #(
    .INIT(32'h00000001)) 
    zero_INST_0
       (.I0(fi1_mask_4_sn_1),
        .I1(fi1_mask_5_sn_1),
        .I2(fi1_mask_7_sn_1),
        .I3(fi1_mask_6_sn_1),
        .I4(zero_INST_0_i_1_n_0),
        .O(zero));
  LUT4 #(
    .INIT(16'hFFFE)) 
    zero_INST_0_i_1
       (.I0(fi1_mask_1_sn_1),
        .I1(fi1_mask_0_sn_1),
        .I2(fi1_mask_3_sn_1),
        .I3(fi1_mask_2_sn_1),
        .O(zero_INST_0_i_1_n_0));
endmodule

(* ECO_CHECKSUM = "9faea762" *) 
(* NotValidForBitStream *)
module top_tmr
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
    result,
    carry_out,
    zero,
    fault_detected,
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
  output [7:0]result;
  output carry_out;
  output zero;
  output fault_detected;
  output [2:0]faulty_module;

  wire [7:0]a;
  wire [7:0]b;
  wire carry_out;
  wire clk;
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
  wire [2:0]op;
  wire [7:0]result;
  wire rst;
  wire zero;

  alu u_alu0
       (.a(a),
        .b(b),
        .carry_out(carry_out),
        .clk(clk),
        .fault_detected(fault_detected),
        .faulty_module(faulty_module),
        .fi0_en(fi0_en),
        .fi0_mask(fi0_mask),
        .fi0_type(fi0_type),
        .fi1_en(fi1_en),
        .fi1_mask(fi1_mask),
        .fi1_mask_0_sp_1(result[0]),
        .fi1_mask_1_sp_1(result[1]),
        .fi1_mask_2_sp_1(result[2]),
        .fi1_mask_3_sp_1(result[3]),
        .fi1_mask_4_sp_1(result[4]),
        .fi1_mask_5_sp_1(result[5]),
        .fi1_mask_6_sp_1(result[6]),
        .fi1_mask_7_sp_1(result[7]),
        .fi1_type(fi1_type),
        .fi2_en(fi2_en),
        .fi2_mask(fi2_mask),
        .fi2_type(fi2_type),
        .op(op),
        .rst(rst),
        .zero(zero));
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
