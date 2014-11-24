-------------------------------------------------------------------------------
-- apb_mif.vhd - entity/architecture pair
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
-- Filename:        apb_mif.vhd
-- Version:         v1.01a
-- Description:     The APB Master Interface module provides a bi-directional
--                  APB master interface on the APB. This interface can be APB3
--                  or APB4 that supports M_APB_PSTRB and M_APB_PPROT signals.
--                  The APB data bus width is always fixed to 32-bits.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity apb_mif is
  generic (
    C_M_APB_ADDR_WIDTH   : integer range 32 to 32   := 32;
    C_M_APB_DATA_WIDTH   : integer range 32 to 32   := 32;
    C_S_AXI_DATA_WIDTH   : integer range 32 to 32   := 32;
    C_APB_NUM_SLAVES     : integer range 1 to 16    := 4;
    C_M_APB_PROTOCOL     : string                   := "apb3"

    );
  port (

  -- APB Signals
    M_APB_PCLK       : in std_logic;
    M_APB_PRESETN    : in std_logic;

    M_APB_PADDR      : out std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);
    M_APB_PENABLE    : out std_logic;
    M_APB_PWRITE     : out std_logic;
    M_APB_PWDATA     : out std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PSTRB      : out std_logic_vector
                           ((C_M_APB_DATA_WIDTH/8)-1 downto 0);
    M_APB_PPROT      : out std_logic_vector(2 downto 0);

  -- Signals from other modules
    apb_pslverr      : in  std_logic;
    apb_pready       : in  std_logic;
    apb_rd_request   : in  std_logic;
    apb_wr_request   : in  std_logic;
    dphase_timeout   : in  std_logic;
    apb_prdata       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    rd_data          : out std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    slv_err_resp     : out std_logic;
    PSEL_i           : out std_logic;
    address          : in  std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);
    axi_awprot       : in  std_logic_vector(2 downto 0);

  -- AXI Signals
    S_AXI_WDATA      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB      : in  std_logic_vector
                           ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_ARADDR     : in  std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT     : in  std_logic_vector(2 downto 0)
    );

end entity apb_mif;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of apb_mif is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

    type  APB_SM_TYPE is (APB_IDLE,
                          APB_SETUP,
                          APB_ACCESS
                         );

-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------

    signal apb_wr_rd_ns   : APB_SM_TYPE;
    signal apb_wr_rd_cs   : APB_SM_TYPE;

    signal PENABLE_i      : std_logic;
    signal PWRITE_i       : std_logic;
    signal PWDATA_i       : std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    signal PADDR_i        : std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);

    signal apb_penable_sm : std_logic;
    signal drive_wr_0s    : std_logic;
    signal apb_psel_sm    : std_logic;

begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- APB I/O signal assignments
-------------------------------------------------------------------------------

    M_APB_PADDR           <= PADDR_i;
    M_APB_PENABLE         <= PENABLE_i;
    M_APB_PWRITE          <= PWRITE_i;
    M_APB_PWDATA          <= PWDATA_i;

-------------------------------------------------------------------------------
-- Internal signal assignments
-------------------------------------------------------------------------------

    PSEL_i <= apb_psel_sm;

-- ****************************************************************************
-- This process is used for registering the APB address when a write or a read
-- is requested. To reduce the power consumption the APB_PADDR signal is not
-- changed until a read is requested.
-- ****************************************************************************

   APB_ADDR_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
          if (M_APB_PRESETN = '0') then
             PADDR_i <= (others => '0');
          else
             if (apb_wr_request = '1') then
                   PADDR_i <= address;
             elsif (apb_rd_request = '1') then
                   PADDR_i <= S_AXI_ARADDR;
             end if;
          end if;
      end if;
   end process APB_ADDR_REG;

-- ****************************************************************************
-- This process is used for registering the APB write signal when a write is
-- requested. To reduce the power consumption the APB_PWRITE signal is not
-- changed until a read is requested.
-- ****************************************************************************

   APB_WRITE_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
          if (M_APB_PRESETN = '0') then
             PWRITE_i <= '0';
          else
             if (apb_wr_request = '1') then
                   PWRITE_i <= '1';
             elsif (apb_rd_request = '1') then
                   PWRITE_i <= '0';
             end if;
          end if;
      end if;
   end process APB_WRITE_REG;

-- ****************************************************************************
-- This process is used for registering the APB write data when a write is
-- requested.
-- ****************************************************************************

   APB_WR_DATA_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
          if (M_APB_PRESETN = '0') then
             PWDATA_i <= (others => '0');
          else
             if (apb_wr_request = '1') then
                   PWDATA_i <= S_AXI_WDATA;
             elsif (drive_wr_0s = '1') then
                   PWDATA_i <= (others => '0');
             end if;
          end if;
      end if;
   end process APB_WR_DATA_REG;


-- ****************************************************************************
-- This generate is used when APB3 is selected
-- ****************************************************************************

    GEN_APB3_STRBS_PROT : if C_M_APB_PROTOCOL = "apb3" generate
        M_APB_PSTRB          <= (others => '1');
        M_APB_PPROT          <= (others => '0');
    end generate GEN_APB3_STRBS_PROT;
-- ****************************************************************************
-- This generate is used when APB4 is selected
-- ****************************************************************************

    GEN_APB4_STRBS_PROT : if C_M_APB_PROTOCOL = "apb4" generate

            signal PSTRB_i        : std_logic_vector
                                    ((C_M_APB_DATA_WIDTH/8)-1 downto 0);
            signal PPROT_i         : std_logic_vector(2 downto 0);
    begin

-------------------------------------------------------------------------------
-- APB STRB/PROT signal assignments
-------------------------------------------------------------------------------

        M_APB_PSTRB          <= PSTRB_i;
        M_APB_PPROT          <= PPROT_i;

-- ****************************************************************************
-- This process is used for registering the APB write strobes when a write is
-- requested.
-- ****************************************************************************

       APB_WR_STRB_REG : process(M_APB_PCLK) is
       begin
          if (M_APB_PCLK'event and M_APB_PCLK = '1') then
              if (M_APB_PRESETN = '0') then
                 PSTRB_i <= (others => '0');
              else
                 if (apb_wr_request = '1') then
                       PSTRB_i <= S_AXI_WSTRB;
                 elsif (drive_wr_0s = '1') then
                       PSTRB_i <= (others => '0');
                 end if;
              end if;
          end if;
       end process APB_WR_STRB_REG;

-- ****************************************************************************
-- This process is used for driving the APB PROT when a write or a read
-- is requested. To reduce the power consumption the APB_PPROT signal is not
-- changed until a read is requested.
-- ****************************************************************************

       APB_PROT_REG : process(M_APB_PCLK) is
       begin
          if (M_APB_PCLK'event and M_APB_PCLK = '1') then
              if (M_APB_PRESETN = '0') then
                 PPROT_i <= (others => '0');
              else
                 if (apb_wr_request = '1') then
                       PPROT_i <= axi_awprot;
                 elsif (apb_rd_request = '1') then
                       PPROT_i <= S_AXI_ARPROT;
                 end if;
              end if;
          end if;
       end process APB_PROT_REG;

   end generate GEN_APB4_STRBS_PROT;

-- ****************************************************************************
-- APB State Machine -- START
-- ****************************************************************************

   APB_WR_RD_SM   : process (apb_wr_rd_cs,
                             apb_wr_request,
                             apb_rd_request,
                             apb_pslverr,
                             apb_pready,
                             apb_prdata,
                             dphase_timeout
                            ) is
   begin

     apb_wr_rd_ns <= apb_wr_rd_cs;
     apb_penable_sm <= '0';
     rd_data <= (others => '0');
     slv_err_resp <= '0';
     drive_wr_0s <= '0';
     apb_psel_sm <= '0';

      case apb_wr_rd_cs is

           when APB_IDLE =>
                if(apb_wr_request = '1' or
                   apb_rd_request = '1') then
                     apb_psel_sm <= '1';
                     apb_wr_rd_ns <= APB_SETUP;
                end if;

           when APB_SETUP =>
                     apb_psel_sm <= '1';
                     apb_penable_sm <= '1';
                     apb_wr_rd_ns <= APB_ACCESS;

           when APB_ACCESS =>
                if(apb_pready = '1') then
                     drive_wr_0s <= '1';
                     slv_err_resp <= apb_pslverr;
                     rd_data <= apb_prdata;
                     apb_wr_rd_ns <= APB_IDLE;
                elsif (dphase_timeout = '1') then
                     drive_wr_0s  <= '1';
                     slv_err_resp <= '1';    --Added error response when timeout
                     apb_wr_rd_ns <= APB_IDLE;
                else
                     apb_psel_sm <= '1';
                     apb_penable_sm <= '1';
                end if;
                
          -- coverage off
            when others =>
                apb_wr_rd_ns <= APB_IDLE;
          -- coverage on

       end case;

   end process APB_WR_RD_SM;

-------------------------------------------------------------------------------
-- Registering the signals generated from the APB state machine
-------------------------------------------------------------------------------

   APB_WR_RD_SM_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
         if (M_APB_PRESETN = '0') then
           apb_wr_rd_cs <= APB_IDLE;
           PENABLE_i <= '0';
         else
           apb_wr_rd_cs <= apb_wr_rd_ns;
           PENABLE_i <= apb_penable_sm;
         end if;
      end if;
   end process APB_WR_RD_SM_REG;

end architecture RTL;
