-------------------------------------------------------------------------------
-- axi_apb_bridge.vhd - entity/architecture pair
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
-- Filename:        axi_apb_bridge.vhd
-- Version:         v1.01a
-- Description:     The AXI to APB Bridge module translates AXI
--                  transactions into APB transactions. It functions as a
--                  AXI slave on the AXI port and an APB master on
--                  the APB interface.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010   Initial version
-- ^^^^^^^
--   NLR      01/05/2012   Added the multiple slave support in RTL
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library axi_apb_bridge_v3_0;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
--
-- Definition of Generics
--
-- System Parameters
--
--  C_FAMILY                 -- FPGA Family for which the axi_apb_bridge is
--                           -- targeted
--  C_INSTANCE               -- Instance name of the axi_apb_bridge in the
--                           -- system
-- AXI Parameters
--
--  C_S_AXI_ADDR_WIDTH       -- Width of the AXI address bus (in bits)
--                              fixed to 32
--  C_S_AXI_DATA_WIDTH       -- Width of the AXI data bus (in bits)
--                              fixed to 32
--  C_BASEADDR               -- AXI Low address for address range 1
--  C_HIGHADDR               -- AXI high address for address range 1
--  C_S_AXI_RNG2_BASEADDR    -- AXI low address for address range 2    
--  C_S_AXI_RNG2_HIGHADDR    -- AXI high address for address range 2
--  C_S_AXI_RNG3_BASEADDR    -- AXI low address for address range 3 
--  C_S_AXI_RNG3_HIGHADDR    -- AXI high address for address range 3 
--  C_S_AXI_RNG4_BASEADDR    -- AXI low address for address range 4 
--  C_S_AXI_RNG4_HIGHADDR    -- AXI high address for address range 4 
--  C_S_AXI_RNG5_BASEADDR    -- AXI low address for address range 5 
--  C_S_AXI_RNG5_HIGHADDR    -- AXI high address for address range 5 
--  C_S_AXI_RNG6_BASEADDR    -- AXI low address for address range 6 
--  C_S_AXI_RNG6_HIGHADDR    -- AXI high address for address range 6 
--  C_S_AXI_RNG7_BASEADDR    -- AXI low address for address range 7  
--  C_S_AXI_RNG7_HIGHADDR    -- AXI high address for address range 7 
--  C_S_AXI_RNG8_BASEADDR    -- AXI low address for address range 8 
--  C_S_AXI_RNG8_HIGHADDR    -- AXI high address for address range 8 
--  C_S_AXI_RNG9_BASEADDR    -- AXI low address for address range 9 
--  C_S_AXI_RNG9_HIGHADDR    -- AXI high address for address range 9 
--  C_S_AXI_RNG10_BASEADDR   -- AXI low address for address range 10 
--  C_S_AXI_RNG10_HIGHADDR   -- AXI high address for address range 10 
--  C_S_AXI_RNG11_BASEADDR   -- AXI low address for address range 11 
--  C_S_AXI_RNG11_HIGHADDR   -- AXI high address for address range 11 
--  C_S_AXI_RNG12_BASEADDR   -- AXI low address for address range 12
--  C_S_AXI_RNG12_HIGHADDR   -- AXI high address for address range 12
--  C_S_AXI_RNG13_BASEADDR   -- AXI low address for address range 13 
--  C_S_AXI_RNG13_HIGHADDR   -- AXI high address for address range 13 
--  C_S_AXI_RNG14_BASEADDR   -- AXI low address for address range 14 
--  C_S_AXI_RNG14_HIGHADDR   -- AXI high address for address range 14 
--  C_S_AXI_RNG15_BASEADDR   -- AXI low address for address range 15 
--  C_S_AXI_RNG15_HIGHADDR   -- AXI high address for address range 15 
--  C_S_AXI_RNG16_BASEADDR   -- AXI low address for address range 16 
--  C_S_AXI_RNG16_HIGHADDR   -- AXI high address for address range 16 
--
-- APB Parameters
--
--  C_M_APB_ADDR_WIDTH       -- Width of the APB address bus (in bits)
--                              fixed to 32
--  C_M_APB_DATA_WIDTH       -- Width of the APB data bus (in bits)
--                              fixed to 32
--  C_APB_NUM_SLAVES         -- The number of APB slaves
--  C_M_APB_PROTOCOL         -- The type of APB interface APB3/APB4
--
-- Core Parameters
--
--  C_DPHASE_TIMEOUT         -- Data phase time out value
--
-- Definition of Ports
--
-- System signals
--
--  s_axi_aclk               -- AXI Clock
--  s_axi_aresetn            -- AXI Reset Signal - active low
--
-- AXI Write address channel signals
--  s_axi_awaddr             -- Write address bus - The write address bus gives
--                              the address of the first transfer in a write
--                              burst transaction - fixed to 32
--  s_axi_awprot             -- Protection type - This signal indicates the
--                              normal, privileged, or secure protection level
--                              of the transaction and whether the transaction
--                              is a data access or an instruction access
--  s_axi_awvalid            -- Write address valid - This signal indicates
--                              that valid write address & control information
--                              are available
--  s_axi_awready            -- Write address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals
--
-- AXI Write data channel signals
--
--  s_axi_wdata              -- Write data bus - fixed to 32
--  s_axi_wstrb              -- Write strobes - These signals indicates which
--                              byte lanes to update in memory
--  s_axi_wvalid             -- Write valid - This signal indicates that valid
--                              write data and strobes are available
--  s_axi_wready             -- Write ready - This signal indicates that the
--                              slave can accept the write data
-- AXI Write response channel signals
--
--  s_axi_bresp              -- Write response - This signal indicates the
--                              status of the write transaction
--  s_axi_bvalid             -- Write response valid - This signal indicates
--                              that a valid write response is available
--  s_axi_bready             -- Response ready - This signal indicates that
--                              the master can accept the response information
--
-- AXI Read address channel signals
--
--  s_axi_araddr             -- Read address - The read address bus gives the
--                              initial address of a read burst transaction
--  s_axi_arprot             -- Protection type - This signal provides
--                              protection unit information for the transaction
--  s_axi_arvalid            -- Read address valid - This signal indicates,
--                              when HIGH, that the read address and control
--                              information is valid and will remain stable
--                              until the address acknowledge signal,ARREADY,
--                              is high.
--  s_axi_arready            -- Read address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals:
--
-- AXI Read data channel signals
--
--  s_axi_rdata              -- Read data bus - fixed to 32
--  s_axi_rresp              -- Read response - This signal indicates the
--                              status of the read transfer
--  s_axi_rvalid             -- Read valid - This signal indicates that the
--                              required read data is available and the read
--                              transfer can complete
--  s_axi_rready             -- Read ready - This signal indicates that the
--                              master can accept the read data and response
--                              information
-- APB signals
--  m_apb_pclk               -- APB Clock
--  m_apb_presetn            -- APB Reset Signal - active low
--  m_apb_paddr              -- APB address bus
--  m_apb_psel               -- Slave select signal
--  m_apb_penable            -- Enable signal indicates that the second and
--                              sub-sequent cycles of an APB transfer
--  m_apb_pwrite             -- Direction indicates an APB write access when
--                              high and an APB read access when low
--  m_apb_pwdata             -- APB write data
--  m_apb_pready             -- Ready, the APB slave uses this signal to
--                              extend an APB transfer
--  m_apb_prdata1            -- APB read data driven by slave 1
--  m_apb_prdata2            -- APB read data driven by slave 2
--  m_apb_prdata3            -- APB read data driven by slave 3
--  m_apb_prdata4            -- APB read data driven by slave 4
--  m_apb_prdata5            -- APB read data driven by slave 5
--  m_apb_prdata6            -- APB read data driven by slave 6
--  m_apb_prdata7            -- APB read data driven by slave 7
--  m_apb_prdata8            -- APB read data driven by slave 8
--  m_apb_prdata9            -- APB read data driven by slave 9
--  m_apb_prdata10           -- APB read data driven by slave 10
--  m_apb_prdata11           -- APB read data driven by slave 11
--  m_apb_prdata12           -- APB read data driven by slave 12
--  m_apb_prdata13           -- APB read data driven by slave 13
--  m_apb_prdata14           -- APB read data driven by slave 14
--  m_apb_prdata15           -- APB read data driven by slave 15
--  m_apb_prdata16           -- APB read data driven by slave 16
--  m_apb_pslverr            -- This signal indicates transfer failure
--  M_APB_PPROT              -- This signal indicates the normal,
--                              privileged, or secure protection level of the
--                              transaction and whether the transaction is a
--                              data access or an instruction access. Driven
--                              when APB4 is selected.
--  M_APB_PSTRB              -- Write strobes. This signal indicates which
--                              byte lanes to update during a write transfer.
--                              Write strobes must not be active during a
--                              read transfer.Driven when APB4 is selected.
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity axi_apb_bridge is
  generic (
    C_FAMILY              : string                    := "virtex7";
    C_INSTANCE            : string                    := "axi_apb_bridge_inst";

    C_S_AXI_ADDR_WIDTH    : integer range 32 to 32    := 32;
    C_S_AXI_DATA_WIDTH    : integer range 32 to 32    := 32;

    C_M_APB_ADDR_WIDTH    : integer range 32 to 32    := 32;
    C_M_APB_DATA_WIDTH    : integer range 32 to 32    := 32;
    C_APB_NUM_SLAVES      : integer range 1 to 16     := 4;
    C_M_APB_PROTOCOL      : string                    := "apb3";

    C_BASEADDR            : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_HIGHADDR            : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG2_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG2_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG3_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG3_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG4_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG4_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG5_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG5_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG6_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG6_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG7_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG7_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG8_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG8_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_S_AXI_RNG9_BASEADDR : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_S_AXI_RNG9_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
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
    C_S_AXI_RNG16_HIGHADDR : std_logic_vector(0 to 31) := X"00000000";
    C_DPHASE_TIMEOUT      : integer range 0 to 256    := 0
    );
  port (
  -- AXI signals
    s_axi_aclk         : in  std_logic;
    s_axi_aresetn      : in  std_logic;

    s_axi_awaddr       : in  std_logic_vector(31 downto 0);
    s_axi_awprot       : in  std_logic_vector(2 downto 0);
    s_axi_awvalid      : in  std_logic;
    s_axi_awready      : out std_logic;
    s_axi_wdata        : in  std_logic_vector(31 downto 0);
    s_axi_wstrb        : in  std_logic_vector
                             (3 downto 0);
    s_axi_wvalid       : in  std_logic;
    s_axi_wready       : out std_logic;
    s_axi_bresp        : out std_logic_vector(1 downto 0);
    s_axi_bvalid       : out std_logic;
    s_axi_bready       : in  std_logic;

    s_axi_araddr       : in  std_logic_vector(31 downto 0);
    s_axi_arprot       : in  std_logic_vector(2 downto 0);
    s_axi_arvalid      : in  std_logic;
    s_axi_arready      : out std_logic;
    s_axi_rdata        : out std_logic_vector(31 downto 0);
    s_axi_rresp        : out std_logic_vector(1 downto 0);
    s_axi_rvalid       : out std_logic;
    s_axi_rready       : in  std_logic;

-- APB signals
    m_apb_paddr        : out std_logic_vector(31 downto 0);
    m_apb_psel         : out std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    m_apb_penable      : out std_logic;
    m_apb_pwrite       : out std_logic;
    m_apb_pwdata       : out std_logic_vector(31 downto 0);
    m_apb_pready       : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    m_apb_prdata       : in  std_logic_vector(31 downto 0);
    m_apb_prdata2      : in  std_logic_vector(31 downto 0);
    m_apb_prdata3      : in  std_logic_vector(31 downto 0);
    m_apb_prdata4      : in  std_logic_vector(31 downto 0);
    m_apb_prdata5      : in  std_logic_vector(31 downto 0);
    m_apb_prdata6      : in  std_logic_vector(31 downto 0);
    m_apb_prdata7      : in  std_logic_vector(31 downto 0);
    m_apb_prdata8      : in  std_logic_vector(31 downto 0);
    m_apb_prdata9      : in  std_logic_vector(31 downto 0);
    m_apb_prdata10     : in  std_logic_vector(31 downto 0);
    m_apb_prdata11     : in  std_logic_vector(31 downto 0);
    m_apb_prdata12     : in  std_logic_vector(31 downto 0);
    m_apb_prdata13     : in  std_logic_vector(31 downto 0);
    m_apb_prdata14     : in  std_logic_vector(31 downto 0);
    m_apb_prdata15     : in  std_logic_vector(31 downto 0);
    m_apb_prdata16     : in  std_logic_vector(31 downto 0);
    m_apb_pslverr      : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    m_apb_pprot        : out std_logic_vector(2 downto 0);
    m_apb_pstrb        : out std_logic_vector
                             (3 downto 0)
    );

end entity axi_apb_bridge;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axi_apb_bridge is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";



-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

    signal Address        : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal sl_pselect     : std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    signal apb_pslverr    : std_logic;
    signal apb_pready     : std_logic;
    signal apb_prdata     : std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    signal apb_rd_request : std_logic;
    signal apb_wr_request : std_logic;
    signal rd_data        : std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    signal slv_err_resp   : std_logic;
    signal PSEL_i         : std_logic;
    signal axi_awprot     : std_logic_vector(2 downto 0);
    signal dphase_timeout : std_logic;    
    
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
    
-------------------------------------------------------------------------------
-- APB clock and reset assignments
-------------------------------------------------------------------------------

    --m_apb_pclk <= s_axi_aclk;
    
    --m_apb_presetn <= s_axi_aresetn;

-------------------------------------------------------------------------------
 -- Instantiate the address decoder as APB is shared
-------------------------------------------------------------------------------

        PSEL_DECODER_MODULE : entity axi_apb_bridge_v3_0.psel_decoder
        generic map
        (
         C_FAMILY                         => C_FAMILY,
         C_S_AXI_ADDR_WIDTH               => C_S_AXI_ADDR_WIDTH,
         C_APB_NUM_SLAVES                 => C_APB_NUM_SLAVES,
         C_S_AXI_RNG1_BASEADDR            => C_BASEADDR,
         C_S_AXI_RNG1_HIGHADDR            => C_HIGHADDR,
         C_S_AXI_RNG2_BASEADDR            => C_S_AXI_RNG2_BASEADDR,
         C_S_AXI_RNG2_HIGHADDR            => C_S_AXI_RNG2_HIGHADDR,
         C_S_AXI_RNG3_BASEADDR            => C_S_AXI_RNG3_BASEADDR,
         C_S_AXI_RNG3_HIGHADDR            => C_S_AXI_RNG3_HIGHADDR,
         C_S_AXI_RNG4_BASEADDR            => C_S_AXI_RNG4_BASEADDR,
         C_S_AXI_RNG4_HIGHADDR            => C_S_AXI_RNG4_HIGHADDR,
         C_S_AXI_RNG5_BASEADDR            => C_S_AXI_RNG5_BASEADDR,
         C_S_AXI_RNG5_HIGHADDR            => C_S_AXI_RNG5_HIGHADDR,
         C_S_AXI_RNG6_BASEADDR            => C_S_AXI_RNG6_BASEADDR,
         C_S_AXI_RNG6_HIGHADDR            => C_S_AXI_RNG6_HIGHADDR,
         C_S_AXI_RNG7_BASEADDR            => C_S_AXI_RNG7_BASEADDR,
         C_S_AXI_RNG7_HIGHADDR            => C_S_AXI_RNG7_HIGHADDR,
         C_S_AXI_RNG8_BASEADDR            => C_S_AXI_RNG8_BASEADDR,
         C_S_AXI_RNG8_HIGHADDR            => C_S_AXI_RNG8_HIGHADDR,
         C_S_AXI_RNG9_BASEADDR            => C_S_AXI_RNG9_BASEADDR,
         C_S_AXI_RNG9_HIGHADDR            => C_S_AXI_RNG9_HIGHADDR,
         C_S_AXI_RNG10_BASEADDR           => C_S_AXI_RNG10_BASEADDR,
         C_S_AXI_RNG10_HIGHADDR           => C_S_AXI_RNG10_HIGHADDR,
         C_S_AXI_RNG11_BASEADDR           => C_S_AXI_RNG11_BASEADDR,
         C_S_AXI_RNG11_HIGHADDR           => C_S_AXI_RNG11_HIGHADDR,
         C_S_AXI_RNG12_BASEADDR           => C_S_AXI_RNG12_BASEADDR,
         C_S_AXI_RNG12_HIGHADDR           => C_S_AXI_RNG12_HIGHADDR,
         C_S_AXI_RNG13_BASEADDR           => C_S_AXI_RNG13_BASEADDR,
         C_S_AXI_RNG13_HIGHADDR           => C_S_AXI_RNG13_HIGHADDR,
         C_S_AXI_RNG14_BASEADDR           => C_S_AXI_RNG14_BASEADDR,
         C_S_AXI_RNG14_HIGHADDR           => C_S_AXI_RNG14_HIGHADDR,
         C_S_AXI_RNG15_BASEADDR           => C_S_AXI_RNG15_BASEADDR,
         C_S_AXI_RNG15_HIGHADDR           => C_S_AXI_RNG15_HIGHADDR,
         C_S_AXI_RNG16_BASEADDR           => C_S_AXI_RNG16_BASEADDR,
         C_S_AXI_RNG16_HIGHADDR           => C_S_AXI_RNG16_HIGHADDR
        )
        port map
        (
         Address                          => address,
         addr_is_valid                    => '1',
         sl_pselect                       => sl_pselect
        );
-------------------------------------------------------------------------------
 -- Instantiate the Multiplexor as APB is shared
-------------------------------------------------------------------------------

        MULTIPLEXOR_MODULE : entity axi_apb_bridge_v3_0.multiplexor
        generic map
        (
         C_M_APB_DATA_WIDTH               => C_M_APB_DATA_WIDTH,
         C_APB_NUM_SLAVES                 => C_APB_NUM_SLAVES
        )
        port map
        (
         M_APB_PCLK                       => s_axi_aclk,
         M_APB_PRESETN                    => s_axi_aresetn,
         M_APB_PREADY                     => m_apb_pready,
         M_APB_PRDATA1                    => m_apb_prdata,
         M_APB_PRDATA2                    => m_apb_prdata2,
         M_APB_PRDATA3                    => m_apb_prdata3,
         M_APB_PRDATA4                    => m_apb_prdata4,
         M_APB_PRDATA5                    => m_apb_prdata5,
         M_APB_PRDATA6                    => m_apb_prdata6,
         M_APB_PRDATA7                    => m_apb_prdata7,
         M_APB_PRDATA8                    => m_apb_prdata8,
         M_APB_PRDATA9                    => m_apb_prdata9,
         M_APB_PRDATA10                   => m_apb_prdata10,
         M_APB_PRDATA11                   => m_apb_prdata11,
         M_APB_PRDATA12                   => m_apb_prdata12,
         M_APB_PRDATA13                   => m_apb_prdata13,
         M_APB_PRDATA14                   => m_apb_prdata14,
         M_APB_PRDATA15                   => m_apb_prdata15,
         M_APB_PRDATA16                   => m_apb_prdata16,
         M_APB_PSLVERR                    => m_apb_pslverr,
         M_APB_PSEL                       => m_apb_psel,
         PSEL_i                           => PSEL_i,
         apb_pslverr                      => apb_pslverr,
         apb_pready                       => apb_pready,
         apb_prdata                       => apb_prdata,
         sl_pselect                       => sl_pselect
        );

-------------------------------------------------------------------------------
 -- Instantiate the AXI Lite Slave Interface module
-------------------------------------------------------------------------------

        AXILITE_SLAVE_IF_MODULE : entity axi_apb_bridge_v3_0.axilite_sif
        generic map
        (
         C_FAMILY                         => C_FAMILY,
         C_S_AXI_ADDR_WIDTH               => C_S_AXI_ADDR_WIDTH,
         C_S_AXI_DATA_WIDTH               => C_S_AXI_DATA_WIDTH,
         C_DPHASE_TIMEOUT                 => C_DPHASE_TIMEOUT,
         C_M_APB_PROTOCOL                 => C_M_APB_PROTOCOL
        )
        port map
        (
         S_AXI_ACLK                       => s_axi_aclk,
         S_AXI_ARESETN                    => s_axi_aresetn,

         S_AXI_AWADDR                     => s_axi_awaddr,
         S_AXI_AWPROT                      => s_axi_awprot,
         S_AXI_AWVALID                    => s_axi_awvalid,
         S_AXI_AWREADY                    => s_axi_awready,
         S_AXI_WVALID                     => s_axi_wvalid,
         S_AXI_WREADY                     => s_axi_wready,
         S_AXI_BRESP                      => s_axi_bresp,
         S_AXI_BVALID                     => s_axi_bvalid,
         S_AXI_BREADY                     => s_axi_bready,

         S_AXI_ARADDR                     => s_axi_araddr,
         S_AXI_ARVALID                    => s_axi_arvalid,
         S_AXI_ARREADY                    => s_axi_arready,
         S_AXI_RDATA                      => s_axi_rdata,
         S_AXI_RRESP                      => s_axi_rresp,
         S_AXI_RVALID                     => s_axi_rvalid,
         S_AXI_RREADY                     => s_axi_rready,
         axi_awprot                       => axi_awprot,
         address                          => address,
         apb_rd_request                   => apb_rd_request,
         apb_wr_request                   => apb_wr_request,
         dphase_timeout                   => dphase_timeout,
         apb_pready                       => apb_pready,
         slv_err_resp                     => slv_err_resp,
         rd_data                          => rd_data
        );

-------------------------------------------------------------------------------
 -- Instantiate the APB Master Interface module
-------------------------------------------------------------------------------

        APB_MASTER_IF_MODULE : entity axi_apb_bridge_v3_0.apb_mif
        generic map
        (
         C_M_APB_ADDR_WIDTH               => C_M_APB_ADDR_WIDTH,
         C_M_APB_DATA_WIDTH               => C_M_APB_DATA_WIDTH,
         C_S_AXI_DATA_WIDTH               => C_S_AXI_DATA_WIDTH,
         C_APB_NUM_SLAVES                 => C_APB_NUM_SLAVES,
         C_M_APB_PROTOCOL                 => C_M_APB_PROTOCOL
        )
        port map
        (
         M_APB_PCLK                       => s_axi_aclk,
         M_APB_PRESETN                    => s_axi_aresetn,

         M_APB_PADDR                      => m_apb_paddr,
         M_APB_PENABLE                    => m_apb_penable,
         M_APB_PWRITE                     => m_apb_pwrite,
         M_APB_PWDATA                     => m_apb_pwdata,
         M_APB_PSTRB                      => m_apb_pstrb,
         M_APB_PPROT                      => m_apb_pprot,
         apb_pslverr                      => apb_pslverr,
         apb_pready                       => apb_pready,
         apb_rd_request                   => apb_rd_request,
         apb_wr_request                   => apb_wr_request,
         dphase_timeout                   => dphase_timeout,
         apb_prdata                       => apb_prdata,
         rd_data                          => rd_data,
         slv_err_resp                     => slv_err_resp,
         PSEL_i                           => PSEL_i,
         address                          => address,
         axi_awprot                       => axi_awprot,
         S_AXI_WDATA                      => s_axi_wdata,
         S_AXI_WSTRB                      => s_axi_wstrb,
         S_AXI_ARADDR                     => s_axi_araddr,
         S_AXI_ARPROT                     => s_axi_arprot
        );

end architecture RTL;
