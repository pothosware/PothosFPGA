-------------------------------------------------------------------------------
-- psel_decoder.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009-2012 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ****************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        psel_decoder.vhd
-- Version:         v1.01a
-- Description:     This module generates the PSEL signal for selecting
--                  different slaves.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.CONV_INTEGER;
library axi_apb_bridge_v3_0;
use axi_apb_bridge_v3_0.pselect_f;


entity psel_decoder is
  generic (
    C_FAMILY               : string                    := "virtex7";

    C_S_AXI_ADDR_WIDTH     : integer range 32 to 32    := 32;
    C_APB_NUM_SLAVES       : integer range 1 to 16     := 4;

    C_S_AXI_RNG1_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG1_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG2_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG2_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG3_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG3_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG4_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG4_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG5_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG5_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG6_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG6_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG7_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG7_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG8_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG8_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG9_BASEADDR  : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG9_HIGHADDR  : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG10_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG10_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG11_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG11_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG12_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG12_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG13_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG13_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG14_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG14_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG15_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG15_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";

    C_S_AXI_RNG16_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG16_HIGHADDR : std_logic_vector(0 to 31) := X"00000000"

    );
  port (
    Address           : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    addr_is_valid     : in std_logic;
    sl_pselect        : out std_logic_vector(C_APB_NUM_SLAVES-1 downto 0)
    );

end entity psel_decoder;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of psel_decoder is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
-- Function declaration
-- This function generates the number of address bits to be compared depending
-- upon the selected base and high addresses.
-------------------------------------------------------------------------------

    function Get_Addr_Bits (x : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1);
                            y : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1)
                           )
             return integer is
        variable addr_nor : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1);
        begin
            addr_nor := x xor y;
            for i in 0 to C_S_AXI_ADDR_WIDTH-1 loop
                if addr_nor(i)='1' then
                    return i;
                end if;
            end loop;
    -- coverage off
            return(C_S_AXI_ADDR_WIDTH);
    -- coverage on
    end function Get_Addr_Bits;
-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 1
-- ****************************************************************************

    GEN_1_ADDR_RANGES : if C_APB_NUM_SLAVES = 1 generate

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals - As one slave is used select is always
 -- high
-------------------------------------------------------------------------------

        sl_pselect(0)  <= addr_is_valid;

    end generate GEN_1_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 2
-- ****************************************************************************

    GEN_2_ADDR_RANGES : if C_APB_NUM_SLAVES = 2 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

    end generate GEN_2_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 3
-- ****************************************************************************

    GEN_3_ADDR_RANGES : if C_APB_NUM_SLAVES = 3 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range3 & addr_hit_range2 & addr_hit_range1 ;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

    end generate GEN_3_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 4
-- ****************************************************************************

    GEN_4_ADDR_RANGES : if C_APB_NUM_SLAVES = 4 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range4 & addr_hit_range3 &
                        addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

    end generate GEN_4_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 5
-- ****************************************************************************

    GEN_5_ADDR_RANGES : if C_APB_NUM_SLAVES = 5 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

    end generate GEN_5_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 6
-- ****************************************************************************

    GEN_6_ADDR_RANGES : if C_APB_NUM_SLAVES = 6 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );
    end generate GEN_6_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 7
-- ****************************************************************************

    GEN_7_ADDR_RANGES : if C_APB_NUM_SLAVES = 7 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

    end generate GEN_7_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 8
-- ****************************************************************************

    GEN_8_ADDR_RANGES : if C_APB_NUM_SLAVES = 8 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );

    end generate GEN_8_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 9
-- ****************************************************************************

    GEN_9_ADDR_RANGES : if C_APB_NUM_SLAVES = 9 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

    end generate GEN_9_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 10
-- ****************************************************************************

    GEN_10_ADDR_RANGES : if C_APB_NUM_SLAVES = 10 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

    end generate GEN_10_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 11
-- ****************************************************************************

    GEN_11_ADDR_RANGES : if C_APB_NUM_SLAVES = 11 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range11 & addr_hit_range10 &
                    addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );

    end generate GEN_11_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 12
-- ****************************************************************************

    GEN_12_ADDR_RANGES : if C_APB_NUM_SLAVES = 12 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range12 & addr_hit_range11 &
                    addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2& addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );


    end generate GEN_12_ADDR_RANGES;
-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 13
-- ****************************************************************************

    GEN_13_ADDR_RANGES : if C_APB_NUM_SLAVES = 13 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range13 & addr_hit_range12 &
                    addr_hit_range11 & addr_hit_range10 &
                    addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

    end generate GEN_13_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 14
-- ****************************************************************************

    GEN_14_ADDR_RANGES : if C_APB_NUM_SLAVES = 14 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR);
        constant DECODE_BITS_RNG14      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG14_BASEADDR, C_S_AXI_RNG14_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;
        signal addr_hit_range14 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range14 & addr_hit_range13 &
                    addr_hit_range12 & addr_hit_range11 &
                    addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 14
-------------------------------------------------------------------------------

          RANGE14_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG14,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG14_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range14    -- [out]
              );

    end generate GEN_14_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 15
-- ****************************************************************************

    GEN_15_ADDR_RANGES : if C_APB_NUM_SLAVES = 15 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR);
        constant DECODE_BITS_RNG14      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG14_BASEADDR, C_S_AXI_RNG14_HIGHADDR);
        constant DECODE_BITS_RNG15      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG15_BASEADDR, C_S_AXI_RNG15_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;
        signal addr_hit_range14 : std_logic;
        signal addr_hit_range15 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range15 & addr_hit_range14 &
                    addr_hit_range13 & addr_hit_range12 &
                    addr_hit_range11 & addr_hit_range10 &
                    addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 14
-------------------------------------------------------------------------------

          RANGE14_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG14,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG14_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range14    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 15
-------------------------------------------------------------------------------

          RANGE15_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG15,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG15_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range15    -- [out]
              );


    end generate GEN_15_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 16
-- ****************************************************************************

    GEN_16_ADDR_RANGES : if C_APB_NUM_SLAVES = 16 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR);
        constant DECODE_BITS_RNG14      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG14_BASEADDR, C_S_AXI_RNG14_HIGHADDR);
        constant DECODE_BITS_RNG15      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG15_BASEADDR, C_S_AXI_RNG15_HIGHADDR);
        constant DECODE_BITS_RNG16      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG16_BASEADDR, C_S_AXI_RNG16_HIGHADDR);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;
        signal addr_hit_range14 : std_logic;
        signal addr_hit_range15 : std_logic;
        signal addr_hit_range16 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range16 & addr_hit_range15 &
                    addr_hit_range14 & addr_hit_range13 &
                    addr_hit_range12 & addr_hit_range11 &
                    addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 14
-------------------------------------------------------------------------------

          RANGE14_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG14,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG14_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range14    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 15
-------------------------------------------------------------------------------

          RANGE15_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG15,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG15_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range15    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 16
-------------------------------------------------------------------------------

          RANGE16_SELECT: entity axi_apb_bridge_v3_0.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG16,
                  C_AW     => 32,
                  C_BAR    => C_S_AXI_RNG16_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range16    -- [out]
              );

    end generate GEN_16_ADDR_RANGES;

end architecture RTL;
