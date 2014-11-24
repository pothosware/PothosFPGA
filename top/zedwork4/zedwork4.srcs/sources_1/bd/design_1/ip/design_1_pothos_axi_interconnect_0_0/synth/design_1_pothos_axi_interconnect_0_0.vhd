-- (c) Copyright 1995-2014 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: Pothosware:Pothos:pothos_axi_interconnect:1.0
-- IP Revision: 9

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY Pothos;
USE Pothos.pothos_axi_interconnect;

ENTITY design_1_pothos_axi_interconnect_0_0 IS
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_apb_paddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_apb_psel : IN STD_LOGIC;
    s_apb_penable : IN STD_LOGIC;
    s_apb_pwrite : IN STD_LOGIC;
    s_apb_pwdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_apb_pready : OUT STD_LOGIC;
    s_apb_prdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_apb_pslverr : OUT STD_LOGIC;
    s00_axis_tvalid : IN STD_LOGIC;
    s00_axis_tready : OUT STD_LOGIC;
    s00_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axis_tlast : IN STD_LOGIC;
    s00_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    m00_axis_tvalid : OUT STD_LOGIC;
    m00_axis_tready : IN STD_LOGIC;
    m00_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m00_axis_tlast : OUT STD_LOGIC;
    m00_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axis_tbegin : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    s_axis_tbegin : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END design_1_pothos_axi_interconnect_0_0;

ARCHITECTURE design_1_pothos_axi_interconnect_0_0_arch OF design_1_pothos_axi_interconnect_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF design_1_pothos_axi_interconnect_0_0_arch: ARCHITECTURE IS "yes";

  COMPONENT pothos_axi_interconnect IS
    GENERIC (
      DATA_WIDTH : POSITIVE;
      NUM_INPUTS : POSITIVE;
      NUM_OUTPUTS : POSITIVE;
      NUM_LANES : POSITIVE;
      FIFO_SIZE : POSITIVE
    );
    PORT (
      aclk : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s_apb_paddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_apb_psel : IN STD_LOGIC;
      s_apb_penable : IN STD_LOGIC;
      s_apb_pwrite : IN STD_LOGIC;
      s_apb_pwdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_apb_pready : OUT STD_LOGIC;
      s_apb_prdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_apb_pslverr : OUT STD_LOGIC;
      s00_axis_tvalid : IN STD_LOGIC;
      s00_axis_tready : OUT STD_LOGIC;
      s00_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axis_tlast : IN STD_LOGIC;
      s00_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axis_tvalid : OUT STD_LOGIC;
      m00_axis_tready : IN STD_LOGIC;
      m00_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axis_tlast : OUT STD_LOGIC;
      m00_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s01_axis_tvalid : IN STD_LOGIC;
      s01_axis_tready : OUT STD_LOGIC;
      s01_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s01_axis_tlast : IN STD_LOGIC;
      s01_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m01_axis_tvalid : OUT STD_LOGIC;
      m01_axis_tready : IN STD_LOGIC;
      m01_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m01_axis_tlast : OUT STD_LOGIC;
      m01_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s02_axis_tvalid : IN STD_LOGIC;
      s02_axis_tready : OUT STD_LOGIC;
      s02_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s02_axis_tlast : IN STD_LOGIC;
      s02_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m02_axis_tvalid : OUT STD_LOGIC;
      m02_axis_tready : IN STD_LOGIC;
      m02_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m02_axis_tlast : OUT STD_LOGIC;
      m02_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s03_axis_tvalid : IN STD_LOGIC;
      s03_axis_tready : OUT STD_LOGIC;
      s03_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s03_axis_tlast : IN STD_LOGIC;
      s03_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m03_axis_tvalid : OUT STD_LOGIC;
      m03_axis_tready : IN STD_LOGIC;
      m03_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m03_axis_tlast : OUT STD_LOGIC;
      m03_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s04_axis_tvalid : IN STD_LOGIC;
      s04_axis_tready : OUT STD_LOGIC;
      s04_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s04_axis_tlast : IN STD_LOGIC;
      s04_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m04_axis_tvalid : OUT STD_LOGIC;
      m04_axis_tready : IN STD_LOGIC;
      m04_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m04_axis_tlast : OUT STD_LOGIC;
      m04_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s05_axis_tvalid : IN STD_LOGIC;
      s05_axis_tready : OUT STD_LOGIC;
      s05_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s05_axis_tlast : IN STD_LOGIC;
      s05_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m05_axis_tvalid : OUT STD_LOGIC;
      m05_axis_tready : IN STD_LOGIC;
      m05_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m05_axis_tlast : OUT STD_LOGIC;
      m05_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s06_axis_tvalid : IN STD_LOGIC;
      s06_axis_tready : OUT STD_LOGIC;
      s06_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s06_axis_tlast : IN STD_LOGIC;
      s06_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m06_axis_tvalid : OUT STD_LOGIC;
      m06_axis_tready : IN STD_LOGIC;
      m06_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m06_axis_tlast : OUT STD_LOGIC;
      m06_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s07_axis_tvalid : IN STD_LOGIC;
      s07_axis_tready : OUT STD_LOGIC;
      s07_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s07_axis_tlast : IN STD_LOGIC;
      s07_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m07_axis_tvalid : OUT STD_LOGIC;
      m07_axis_tready : IN STD_LOGIC;
      m07_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m07_axis_tlast : OUT STD_LOGIC;
      m07_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s08_axis_tvalid : IN STD_LOGIC;
      s08_axis_tready : OUT STD_LOGIC;
      s08_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s08_axis_tlast : IN STD_LOGIC;
      s08_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m08_axis_tvalid : OUT STD_LOGIC;
      m08_axis_tready : IN STD_LOGIC;
      m08_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m08_axis_tlast : OUT STD_LOGIC;
      m08_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s09_axis_tvalid : IN STD_LOGIC;
      s09_axis_tready : OUT STD_LOGIC;
      s09_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s09_axis_tlast : IN STD_LOGIC;
      s09_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m09_axis_tvalid : OUT STD_LOGIC;
      m09_axis_tready : IN STD_LOGIC;
      m09_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m09_axis_tlast : OUT STD_LOGIC;
      m09_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s10_axis_tvalid : IN STD_LOGIC;
      s10_axis_tready : OUT STD_LOGIC;
      s10_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s10_axis_tlast : IN STD_LOGIC;
      s10_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m10_axis_tvalid : OUT STD_LOGIC;
      m10_axis_tready : IN STD_LOGIC;
      m10_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m10_axis_tlast : OUT STD_LOGIC;
      m10_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s11_axis_tvalid : IN STD_LOGIC;
      s11_axis_tready : OUT STD_LOGIC;
      s11_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s11_axis_tlast : IN STD_LOGIC;
      s11_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m11_axis_tvalid : OUT STD_LOGIC;
      m11_axis_tready : IN STD_LOGIC;
      m11_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m11_axis_tlast : OUT STD_LOGIC;
      m11_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s12_axis_tvalid : IN STD_LOGIC;
      s12_axis_tready : OUT STD_LOGIC;
      s12_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s12_axis_tlast : IN STD_LOGIC;
      s12_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m12_axis_tvalid : OUT STD_LOGIC;
      m12_axis_tready : IN STD_LOGIC;
      m12_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m12_axis_tlast : OUT STD_LOGIC;
      m12_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s13_axis_tvalid : IN STD_LOGIC;
      s13_axis_tready : OUT STD_LOGIC;
      s13_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s13_axis_tlast : IN STD_LOGIC;
      s13_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m13_axis_tvalid : OUT STD_LOGIC;
      m13_axis_tready : IN STD_LOGIC;
      m13_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m13_axis_tlast : OUT STD_LOGIC;
      m13_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s14_axis_tvalid : IN STD_LOGIC;
      s14_axis_tready : OUT STD_LOGIC;
      s14_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s14_axis_tlast : IN STD_LOGIC;
      s14_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m14_axis_tvalid : OUT STD_LOGIC;
      m14_axis_tready : IN STD_LOGIC;
      m14_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m14_axis_tlast : OUT STD_LOGIC;
      m14_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s15_axis_tvalid : IN STD_LOGIC;
      s15_axis_tready : OUT STD_LOGIC;
      s15_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s15_axis_tlast : IN STD_LOGIC;
      s15_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m15_axis_tvalid : OUT STD_LOGIC;
      m15_axis_tready : IN STD_LOGIC;
      m15_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m15_axis_tlast : OUT STD_LOGIC;
      m15_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s16_axis_tvalid : IN STD_LOGIC;
      s16_axis_tready : OUT STD_LOGIC;
      s16_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s16_axis_tlast : IN STD_LOGIC;
      s16_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m16_axis_tvalid : OUT STD_LOGIC;
      m16_axis_tready : IN STD_LOGIC;
      m16_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m16_axis_tlast : OUT STD_LOGIC;
      m16_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s17_axis_tvalid : IN STD_LOGIC;
      s17_axis_tready : OUT STD_LOGIC;
      s17_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s17_axis_tlast : IN STD_LOGIC;
      s17_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m17_axis_tvalid : OUT STD_LOGIC;
      m17_axis_tready : IN STD_LOGIC;
      m17_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m17_axis_tlast : OUT STD_LOGIC;
      m17_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s18_axis_tvalid : IN STD_LOGIC;
      s18_axis_tready : OUT STD_LOGIC;
      s18_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s18_axis_tlast : IN STD_LOGIC;
      s18_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m18_axis_tvalid : OUT STD_LOGIC;
      m18_axis_tready : IN STD_LOGIC;
      m18_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m18_axis_tlast : OUT STD_LOGIC;
      m18_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s19_axis_tvalid : IN STD_LOGIC;
      s19_axis_tready : OUT STD_LOGIC;
      s19_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s19_axis_tlast : IN STD_LOGIC;
      s19_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m19_axis_tvalid : OUT STD_LOGIC;
      m19_axis_tready : IN STD_LOGIC;
      m19_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m19_axis_tlast : OUT STD_LOGIC;
      m19_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s20_axis_tvalid : IN STD_LOGIC;
      s20_axis_tready : OUT STD_LOGIC;
      s20_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s20_axis_tlast : IN STD_LOGIC;
      s20_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m20_axis_tvalid : OUT STD_LOGIC;
      m20_axis_tready : IN STD_LOGIC;
      m20_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m20_axis_tlast : OUT STD_LOGIC;
      m20_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s21_axis_tvalid : IN STD_LOGIC;
      s21_axis_tready : OUT STD_LOGIC;
      s21_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s21_axis_tlast : IN STD_LOGIC;
      s21_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m21_axis_tvalid : OUT STD_LOGIC;
      m21_axis_tready : IN STD_LOGIC;
      m21_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m21_axis_tlast : OUT STD_LOGIC;
      m21_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s22_axis_tvalid : IN STD_LOGIC;
      s22_axis_tready : OUT STD_LOGIC;
      s22_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s22_axis_tlast : IN STD_LOGIC;
      s22_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m22_axis_tvalid : OUT STD_LOGIC;
      m22_axis_tready : IN STD_LOGIC;
      m22_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m22_axis_tlast : OUT STD_LOGIC;
      m22_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s23_axis_tvalid : IN STD_LOGIC;
      s23_axis_tready : OUT STD_LOGIC;
      s23_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s23_axis_tlast : IN STD_LOGIC;
      s23_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m23_axis_tvalid : OUT STD_LOGIC;
      m23_axis_tready : IN STD_LOGIC;
      m23_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m23_axis_tlast : OUT STD_LOGIC;
      m23_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s24_axis_tvalid : IN STD_LOGIC;
      s24_axis_tready : OUT STD_LOGIC;
      s24_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s24_axis_tlast : IN STD_LOGIC;
      s24_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m24_axis_tvalid : OUT STD_LOGIC;
      m24_axis_tready : IN STD_LOGIC;
      m24_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m24_axis_tlast : OUT STD_LOGIC;
      m24_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s25_axis_tvalid : IN STD_LOGIC;
      s25_axis_tready : OUT STD_LOGIC;
      s25_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s25_axis_tlast : IN STD_LOGIC;
      s25_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m25_axis_tvalid : OUT STD_LOGIC;
      m25_axis_tready : IN STD_LOGIC;
      m25_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m25_axis_tlast : OUT STD_LOGIC;
      m25_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s26_axis_tvalid : IN STD_LOGIC;
      s26_axis_tready : OUT STD_LOGIC;
      s26_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s26_axis_tlast : IN STD_LOGIC;
      s26_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m26_axis_tvalid : OUT STD_LOGIC;
      m26_axis_tready : IN STD_LOGIC;
      m26_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m26_axis_tlast : OUT STD_LOGIC;
      m26_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s27_axis_tvalid : IN STD_LOGIC;
      s27_axis_tready : OUT STD_LOGIC;
      s27_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s27_axis_tlast : IN STD_LOGIC;
      s27_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m27_axis_tvalid : OUT STD_LOGIC;
      m27_axis_tready : IN STD_LOGIC;
      m27_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m27_axis_tlast : OUT STD_LOGIC;
      m27_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s28_axis_tvalid : IN STD_LOGIC;
      s28_axis_tready : OUT STD_LOGIC;
      s28_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s28_axis_tlast : IN STD_LOGIC;
      s28_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m28_axis_tvalid : OUT STD_LOGIC;
      m28_axis_tready : IN STD_LOGIC;
      m28_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m28_axis_tlast : OUT STD_LOGIC;
      m28_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s29_axis_tvalid : IN STD_LOGIC;
      s29_axis_tready : OUT STD_LOGIC;
      s29_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s29_axis_tlast : IN STD_LOGIC;
      s29_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m29_axis_tvalid : OUT STD_LOGIC;
      m29_axis_tready : IN STD_LOGIC;
      m29_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m29_axis_tlast : OUT STD_LOGIC;
      m29_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s30_axis_tvalid : IN STD_LOGIC;
      s30_axis_tready : OUT STD_LOGIC;
      s30_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s30_axis_tlast : IN STD_LOGIC;
      s30_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m30_axis_tvalid : OUT STD_LOGIC;
      m30_axis_tready : IN STD_LOGIC;
      m30_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m30_axis_tlast : OUT STD_LOGIC;
      m30_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s31_axis_tvalid : IN STD_LOGIC;
      s31_axis_tready : OUT STD_LOGIC;
      s31_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s31_axis_tlast : IN STD_LOGIC;
      s31_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m31_axis_tvalid : OUT STD_LOGIC;
      m31_axis_tready : IN STD_LOGIC;
      m31_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m31_axis_tlast : OUT STD_LOGIC;
      m31_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axis_tbegin : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s_axis_tbegin : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
  END COMPONENT pothos_axi_interconnect;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF design_1_pothos_axi_interconnect_0_0_arch: ARCHITECTURE IS "pothos_axi_interconnect,Vivado 2014.3.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF design_1_pothos_axi_interconnect_0_0_arch : ARCHITECTURE IS "design_1_pothos_axi_interconnect_0_0,pothos_axi_interconnect,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 signal_clock CLK";
  ATTRIBUTE X_INTERFACE_INFO OF aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 signal_reset RST";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_paddr: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_psel: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PSEL";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_penable: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PENABLE";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_pwrite: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PWRITE";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_pwdata: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PWDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_pready: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_prdata: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PRDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_apb_pslverr: SIGNAL IS "xilinx.com:interface:apb:1.0 S_APB PSLVERR";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axis_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 S00_AXIS TUSER";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axis_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 M00_AXIS TUSER";
BEGIN
  U0 : pothos_axi_interconnect
    GENERIC MAP (
      DATA_WIDTH => 32,
      NUM_INPUTS => 1,
      NUM_OUTPUTS => 1,
      NUM_LANES => 2,
      FIFO_SIZE => 4
    )
    PORT MAP (
      aclk => aclk,
      aresetn => aresetn,
      s_apb_paddr => s_apb_paddr,
      s_apb_psel => s_apb_psel,
      s_apb_penable => s_apb_penable,
      s_apb_pwrite => s_apb_pwrite,
      s_apb_pwdata => s_apb_pwdata,
      s_apb_pready => s_apb_pready,
      s_apb_prdata => s_apb_prdata,
      s_apb_pslverr => s_apb_pslverr,
      s00_axis_tvalid => s00_axis_tvalid,
      s00_axis_tready => s00_axis_tready,
      s00_axis_tdata => s00_axis_tdata,
      s00_axis_tlast => s00_axis_tlast,
      s00_axis_tuser => s00_axis_tuser,
      m00_axis_tvalid => m00_axis_tvalid,
      m00_axis_tready => m00_axis_tready,
      m00_axis_tdata => m00_axis_tdata,
      m00_axis_tlast => m00_axis_tlast,
      m00_axis_tuser => m00_axis_tuser,
      s01_axis_tvalid => '0',
      s01_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s01_axis_tlast => '1',
      s01_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m01_axis_tready => '0',
      s02_axis_tvalid => '0',
      s02_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s02_axis_tlast => '1',
      s02_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m02_axis_tready => '0',
      s03_axis_tvalid => '0',
      s03_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s03_axis_tlast => '1',
      s03_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m03_axis_tready => '0',
      s04_axis_tvalid => '0',
      s04_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s04_axis_tlast => '1',
      s04_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m04_axis_tready => '0',
      s05_axis_tvalid => '0',
      s05_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s05_axis_tlast => '1',
      s05_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m05_axis_tready => '0',
      s06_axis_tvalid => '0',
      s06_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s06_axis_tlast => '1',
      s06_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m06_axis_tready => '0',
      s07_axis_tvalid => '0',
      s07_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s07_axis_tlast => '1',
      s07_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m07_axis_tready => '0',
      s08_axis_tvalid => '0',
      s08_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s08_axis_tlast => '1',
      s08_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m08_axis_tready => '0',
      s09_axis_tvalid => '0',
      s09_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s09_axis_tlast => '1',
      s09_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m09_axis_tready => '0',
      s10_axis_tvalid => '0',
      s10_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s10_axis_tlast => '1',
      s10_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m10_axis_tready => '0',
      s11_axis_tvalid => '0',
      s11_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s11_axis_tlast => '1',
      s11_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m11_axis_tready => '0',
      s12_axis_tvalid => '0',
      s12_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s12_axis_tlast => '1',
      s12_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m12_axis_tready => '0',
      s13_axis_tvalid => '0',
      s13_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s13_axis_tlast => '1',
      s13_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m13_axis_tready => '0',
      s14_axis_tvalid => '0',
      s14_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s14_axis_tlast => '1',
      s14_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m14_axis_tready => '0',
      s15_axis_tvalid => '0',
      s15_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s15_axis_tlast => '1',
      s15_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m15_axis_tready => '0',
      s16_axis_tvalid => '0',
      s16_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s16_axis_tlast => '1',
      s16_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m16_axis_tready => '0',
      s17_axis_tvalid => '0',
      s17_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s17_axis_tlast => '1',
      s17_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m17_axis_tready => '0',
      s18_axis_tvalid => '0',
      s18_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s18_axis_tlast => '1',
      s18_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m18_axis_tready => '0',
      s19_axis_tvalid => '0',
      s19_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s19_axis_tlast => '1',
      s19_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m19_axis_tready => '0',
      s20_axis_tvalid => '0',
      s20_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s20_axis_tlast => '1',
      s20_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m20_axis_tready => '0',
      s21_axis_tvalid => '0',
      s21_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s21_axis_tlast => '1',
      s21_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m21_axis_tready => '0',
      s22_axis_tvalid => '0',
      s22_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s22_axis_tlast => '1',
      s22_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m22_axis_tready => '0',
      s23_axis_tvalid => '0',
      s23_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s23_axis_tlast => '1',
      s23_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m23_axis_tready => '0',
      s24_axis_tvalid => '0',
      s24_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s24_axis_tlast => '1',
      s24_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m24_axis_tready => '0',
      s25_axis_tvalid => '0',
      s25_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s25_axis_tlast => '1',
      s25_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m25_axis_tready => '0',
      s26_axis_tvalid => '0',
      s26_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s26_axis_tlast => '1',
      s26_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m26_axis_tready => '0',
      s27_axis_tvalid => '0',
      s27_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s27_axis_tlast => '1',
      s27_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m27_axis_tready => '0',
      s28_axis_tvalid => '0',
      s28_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s28_axis_tlast => '1',
      s28_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m28_axis_tready => '0',
      s29_axis_tvalid => '0',
      s29_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s29_axis_tlast => '1',
      s29_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m29_axis_tready => '0',
      s30_axis_tvalid => '0',
      s30_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s30_axis_tlast => '1',
      s30_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m30_axis_tready => '0',
      s31_axis_tvalid => '0',
      s31_axis_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      s31_axis_tlast => '1',
      s31_axis_tuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m31_axis_tready => '0',
      m_axis_tbegin => m_axis_tbegin,
      s_axis_tbegin => s_axis_tbegin
    );
END design_1_pothos_axi_interconnect_0_0_arch;
