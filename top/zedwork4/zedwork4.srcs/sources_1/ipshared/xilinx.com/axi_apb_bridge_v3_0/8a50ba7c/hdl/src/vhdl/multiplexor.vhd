-------------------------------------------------------------------------------
-- multiplexor.vhd - entity/architecture pair
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
-- Filename:        multiplexor.vhd
-- Version:         v1.01a
-- Description:     The multiplexor module multiplexes APB signals from
--                  different APB slaves depending on the selected APB slave.
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
library IEEE;
use     IEEE.std_logic_1164.all;
use     IEEE.std_logic_unsigned.all;
use     IEEE.numeric_std.all;

entity multiplexor is
  generic (

    C_M_APB_DATA_WIDTH  : integer range 32 to 32   := 32;
    C_APB_NUM_SLAVES    : integer range 1 to 16    := 4
        );

  port (
    M_APB_PCLK          : in std_logic;
    M_APB_PRESETN       : in std_logic;
    M_APB_PREADY        : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    M_APB_PRDATA1       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA2       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA3       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA4       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA5       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA6       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA7       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA8       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA9       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA10      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA11      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA12      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA13      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA14      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA15      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA16      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PSLVERR       : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    M_APB_PSEL          : out std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    PSEL_i              : in  std_logic;
    apb_pslverr         : out std_logic;
    apb_pready          : out std_logic;
    apb_prdata          : out std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    sl_pselect          : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0)
    );

end entity multiplexor;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of multiplexor is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

     signal M_APB_PSEL_i : std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);

begin

     M_APB_PSEL <= M_APB_PSEL_i;

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 1
-- ****************************************************************************

    GEN_1_SELECT_SLAVE : if C_APB_NUM_SLAVES = 1 generate
    begin

-------------------------------------------------------------------------------
 -- PSLVERR, PREADY, PRDATA are directly assigned as only one slave is on APB
-------------------------------------------------------------------------------

         apb_pslverr <= M_APB_PSLVERR(0);
         apb_pready <= M_APB_PREADY(0);
         apb_prdata <= M_APB_PRDATA1;

-------------------------------------------------------------------------------
 -- Slave select signal is assigned after decoding the address
-------------------------------------------------------------------------------

        PSEL_1_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i(0) <= PSEL_i;
                end if;
            end if;
        end process PSEL_1_PROCESS;

    end generate GEN_1_SELECT_SLAVE;

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 2
-- ****************************************************************************

    GEN_2_SELECT_SLAVE : if C_APB_NUM_SLAVES = 2 generate

        signal pselect_i     : std_logic_vector(1 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_2_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is                        
                        when "10" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "01" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_2_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_2_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "01" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_2_SL_SIGNALS;

    end generate GEN_2_SELECT_SLAVE;

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 3
-- ****************************************************************************

    GEN_3_SELECT_SLAVE : if C_APB_NUM_SLAVES = 3 generate

        signal pselect_i     : std_logic_vector(2 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_3_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_3_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_3_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_3_SL_SIGNALS;

    end generate GEN_3_SELECT_SLAVE;

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 4
-- ****************************************************************************

    GEN_4_SELECT_SLAVE : if C_APB_NUM_SLAVES = 4 generate

        signal pselect_i     : std_logic_vector(3 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_4_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "1000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_4_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_4_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_4_SL_SIGNALS;

    end generate GEN_4_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 5
-- ****************************************************************************

    GEN_5_SELECT_SLAVE : if C_APB_NUM_SLAVES = 5 generate

        signal pselect_i     : std_logic_vector(4 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_5_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "10000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "01000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_5_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_5_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "01000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_5_SL_SIGNALS;

    end generate GEN_5_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 6
-- ****************************************************************************

    GEN_6_SELECT_SLAVE : if C_APB_NUM_SLAVES = 6 generate

        signal pselect_i     : std_logic_vector(5 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_6_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_6_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_6_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_6_SL_SIGNALS;

    end generate GEN_6_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 7
-- ****************************************************************************

    GEN_7_SELECT_SLAVE : if C_APB_NUM_SLAVES = 7 generate

        signal pselect_i     : std_logic_vector(6 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_7_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "1000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_7_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_7_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_7_SL_SIGNALS;

    end generate GEN_7_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 8
-- ****************************************************************************

    GEN_8_SELECT_SLAVE : if C_APB_NUM_SLAVES = 8 generate

        signal pselect_i     : std_logic_vector(7 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_8_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "10000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "01000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "00100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "00010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "00001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_8_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_8_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "01000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "00100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "00010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "00001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_8_SL_SIGNALS;

    end generate GEN_8_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 9
-- ****************************************************************************

    GEN_9_SELECT_SLAVE : if C_APB_NUM_SLAVES = 9 generate

        signal pselect_i     : std_logic_vector(8 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_9_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_9_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_9_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_9_SL_SIGNALS;

    end generate GEN_9_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 10
-- ****************************************************************************

    GEN_10_SELECT_SLAVE : if C_APB_NUM_SLAVES = 10 generate

        signal pselect_i     : std_logic_vector(9 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_10_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "1000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "0100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "0010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "0001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_10_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_10_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "0100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "0010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "0001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_10_SL_SIGNALS;

    end generate GEN_10_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 11
-- ****************************************************************************

    GEN_11_SELECT_SLAVE : if C_APB_NUM_SLAVES = 11 generate

        signal pselect_i     : std_logic_vector(10 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_11_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "10000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "01000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "00100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "00010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "00001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "00000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "00000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "00000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_11_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_11_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "01000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "00100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "00010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "00001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "00000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "00000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "00000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_11_SL_SIGNALS;

    end generate GEN_11_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 12
-- ****************************************************************************

    GEN_12_SELECT_SLAVE : if C_APB_NUM_SLAVES = 12 generate

        signal pselect_i     : std_logic_vector(11 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_12_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_12_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_12_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_12_SL_SIGNALS;

    end generate GEN_12_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 13
-- ****************************************************************************

    GEN_13_SELECT_SLAVE : if C_APB_NUM_SLAVES = 13 generate

        signal pselect_i     : std_logic_vector(12 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_13_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "1000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "0100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "0010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "0001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "0000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "0000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "0000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_13_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_13_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "0100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "0010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "0001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "0000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "0000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "0000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_13_SL_SIGNALS;

    end generate GEN_13_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 14
-- ****************************************************************************

    GEN_14_SELECT_SLAVE : if C_APB_NUM_SLAVES = 14 generate

        signal pselect_i     : std_logic_vector(13 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_14_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "10000000000000" =>
                            M_APB_PSEL_i(13) <= PSEL_i;
                        when "01000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "00100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "00010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "00001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "00000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "00000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "00000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "00000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "00000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "00000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_14_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_14_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA14,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(13);
                    apb_pready <= M_APB_PREADY(13);
                    apb_prdata <= M_APB_PRDATA14;
                when "01000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "00100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "00010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "00001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "00000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "00000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "00000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "00000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "00000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "00000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_14_SL_SIGNALS;

    end generate GEN_14_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 15
-- ****************************************************************************

    GEN_15_SELECT_SLAVE : if C_APB_NUM_SLAVES = 15 generate

        signal pselect_i     : std_logic_vector(14 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_15_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100000000000000" =>
                            M_APB_PSEL_i(14) <= PSEL_i;
                        when "010000000000000" =>
                            M_APB_PSEL_i(13) <= PSEL_i;
                        when "001000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "000100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "000010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "000001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "000000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "000000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "000000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "000000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "000000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "000000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_15_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_15_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA15,
                                    M_APB_PRDATA14,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(14);
                    apb_pready <= M_APB_PREADY(14);
                    apb_prdata <= M_APB_PRDATA15;
                when "010000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(13);
                    apb_pready <= M_APB_PREADY(13);
                    apb_prdata <= M_APB_PRDATA14;
                when "001000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "000100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "000010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "000001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "000000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "000000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "000000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "000000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "000000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "000000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_15_SL_SIGNALS;

    end generate GEN_15_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 16
-- ****************************************************************************

    GEN_16_SELECT_SLAVE : if C_APB_NUM_SLAVES = 16 generate

        signal pselect_i     : std_logic_vector(15 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_16_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others=> '0');
                    case pselect_i is
                        when "1000000000000000" =>
                            M_APB_PSEL_i(15) <= PSEL_i;
                        when "0100000000000000" =>
                            M_APB_PSEL_i(14) <= PSEL_i;
                        when "0010000000000000" =>
                            M_APB_PSEL_i(13) <= PSEL_i;
                        when "0001000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "0000100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "0000010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "0000001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "0000000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "0000000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "0000000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0000000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0000000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0000000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others=> '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_16_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_16_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA16,
                                    M_APB_PRDATA15,
                                    M_APB_PRDATA14,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(15);
                    apb_pready <= M_APB_PREADY(15);
                    apb_prdata <= M_APB_PRDATA16;
                when "0100000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(14);
                    apb_pready <= M_APB_PREADY(14);
                    apb_prdata <= M_APB_PRDATA15;
                when "0010000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(13);
                    apb_pready <= M_APB_PREADY(13);
                    apb_prdata <= M_APB_PRDATA14;
                when "0001000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "0000100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "0000010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "0000001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "0000000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "0000000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "0000000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0000000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0000000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0000000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_16_SL_SIGNALS;

    end generate GEN_16_SELECT_SLAVE;
end architecture RTL;
