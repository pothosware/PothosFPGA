-------------------------------------------------------------------------------
-- axilite_slif.vhd - entity/architecture pair
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
-- Filename:        axilite_slif.vhd
-- Version:         v1.01a
-- Description:     The AXI4-Lite Slave Interface module provides a
--                  bi-directional slave interface to the AXI. The AXI data
--                  bus width is always fixed to 32-bits. When both write and
--                  read transfers are simultaneously requested on AXI4-Lite,
--                  read requestis given more priority than write request.
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
use ieee.numeric_std.all;

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
library axi_apb_bridge_v3_0;
use axi_apb_bridge_v3_0.counter_f;

entity axilite_sif is
  generic (
    C_FAMILY              : string                   := "virtex7";
    C_S_AXI_ADDR_WIDTH    : integer range 32 to 32   := 32;
    C_S_AXI_DATA_WIDTH    : integer range 32 to 32   := 32;
    C_DPHASE_TIMEOUT      : integer range 0 to 256   := 0;
    C_M_APB_PROTOCOL      : string                   := "apb3"
    );
  port (
  -- AXI Signals
    S_AXI_ACLK       : in  std_logic;
    S_AXI_ARESETN    : in  std_logic;

    S_AXI_AWADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT     : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID    : in  std_logic;
    S_AXI_AWREADY    : out std_logic;
    S_AXI_WVALID     : in  std_logic;
    S_AXI_WREADY     : out std_logic;
    S_AXI_BRESP      : out std_logic_vector(1 downto 0);
    S_AXI_BVALID     : out std_logic;
    S_AXI_BREADY     : in  std_logic;

    S_AXI_ARADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID    : in  std_logic;
    S_AXI_ARREADY    : out std_logic;
    S_AXI_RDATA      : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP      : out std_logic_vector(1 downto 0);
    S_AXI_RVALID     : out std_logic;
    S_AXI_RREADY     : in  std_logic;

  -- Signals from other modules
    axi_awprot       : out  std_logic_vector(2 downto 0);
    address          : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    apb_rd_request   : out std_logic;
    apb_wr_request   : out std_logic;
    dphase_timeout   : out std_logic;
    apb_pready       : in  std_logic;
    slv_err_resp     : in  std_logic;
    rd_data          : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
    );

end entity axilite_sif;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axilite_sif is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
-- This function generates the number of address bits to be compared depending
-- upon the selected base and high addresses.
-------------------------------------------------------------------------------

    type  AXI_SM_TYPE is (AXI_IDLE,
                          WRITE,
                          WRITE_W_WAIT,
                          WRITE_WAIT,
                          WR_RESP,
                          READ,
                          READ_WAIT,
                          RD_RESP);

-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

    signal axi_wr_rd_ns   : AXI_SM_TYPE;
    signal axi_wr_rd_cs   : AXI_SM_TYPE;

    signal ARREADY_i      : std_logic;
    signal WREADY_i       : std_logic;
    signal AWREADY_i      : std_logic;
    signal BVALID_i       : std_logic;
    signal BRESP_1_i      : std_logic;
    signal RVALID_i       : std_logic;
    signal RRESP_1_i      : std_logic;

    signal write_ready_sm : std_logic;
    signal waddr_ready_sm : std_logic;
    signal arready_sm     : std_logic;
    signal BVALID_sm      : std_logic;
    signal RVALID_sm      : std_logic;

    signal load_cntr      : std_logic;
    signal data_timeout   : std_logic;
    signal both_valids    : std_logic;
    signal address_i      : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal send_rd        : std_logic;
    signal send_wr_resp   : std_logic;
    signal cntr_enable    : std_logic;
    signal wr_request     : std_logic;
    signal rd_request     : std_logic;
    
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- I/O signal assignments
-------------------------------------------------------------------------------

    S_AXI_AWREADY         <= AWREADY_i;

    S_AXI_WREADY          <= WREADY_i;

    S_AXI_BRESP(0)        <= '0';
    S_AXI_BRESP(1)        <= BRESP_1_i;
    S_AXI_BVALID          <= BVALID_i;

    S_AXI_ARREADY         <= ARREADY_i;

    S_AXI_RRESP(0)        <= '0';
    S_AXI_RRESP(1)        <= RRESP_1_i;
    S_AXI_RVALID          <= RVALID_i;

-------------------------------------------------------------------------------
-- Data phase timeout to APB, read and write request assignments
-------------------------------------------------------------------------------

    dphase_timeout <= data_timeout;
    apb_rd_request <= rd_request;
    apb_wr_request <= wr_request;

-------------------------------------------------------------------------------
-- Address generation for generating slave select
-------------------------------------------------------------------------------

   ADDR_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             address_i <= (others => '0');
          else
             if (waddr_ready_sm = '1') then
                   address_i <= S_AXI_AWADDR;
             elsif (rd_request = '1') then
                   address_i <= S_AXI_ARADDR;
             end if;
          end if;
      end if;
   end process ADDR_REG;

-------------------------------------------------------------------------------
-- Address assignment for saving one cycle
-------------------------------------------------------------------------------

    address <= S_AXI_ARADDR when rd_request = '1' else
               S_AXI_AWADDR when waddr_ready_sm = '1' else
               address_i;

-- ****************************************************************************
-- This generate is used when APB3 is selected
-- ****************************************************************************

    GEN_APB3_WRITE_PROT : if C_M_APB_PROTOCOL = "apb3" generate

       axi_awprot <= (others => '0');

    end generate GEN_APB3_WRITE_PROT; 
-- ****************************************************************************
-- This generate is used when APB4 is selected
-- ****************************************************************************

    GEN_APB4_WRITE_PROT : if C_M_APB_PROTOCOL = "apb4" generate

            signal awprot : std_logic_vector(2 downto 0);
    begin
  
-------------------------------------------------------------------------------
-- Write PROT generation for APB
-------------------------------------------------------------------------------

        axi_awprot <= S_AXI_AWPROT when both_valids = '1' else awprot; 
    
-- ****************************************************************************
-- This process is used for registering the AXI protection when a write 
-- is requested. 
-- ****************************************************************************

       AXI_WRITE_PROT_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 awprot <= (others => '0');
              else
                 if (waddr_ready_sm = '1') then
                       awprot <= S_AXI_AWPROT;
                 end if;
              end if;
          end if;
       end process AXI_WRITE_PROT_REG;
   
   end generate GEN_APB4_WRITE_PROT;

-- ****************************************************************************
-- This process is used for registering the APB read data that needs to be
-- sent on AXI
-- ****************************************************************************

    RD_RESP_REG : process(S_AXI_ACLK) is
    begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             RRESP_1_i <= '0';
          else
             if (send_rd = '1') then
                 RRESP_1_i <= slv_err_resp;
             elsif (S_AXI_RREADY = '1') then
                 RRESP_1_i <= '0';
             end if;
          end if;
      end if;
   end process RD_RESP_REG;

-- ****************************************************************************
-- This process is used for registering Read response
-- ****************************************************************************

    RD_DATA_REG : process(S_AXI_ACLK) is
    begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             S_AXI_RDATA <= (others => '0');
          else
             if (send_rd = '1') then
                 S_AXI_RDATA <= rd_data;
             elsif (S_AXI_RREADY = '1') then
                 S_AXI_RDATA <= (others => '0');
             end if;
          end if;
      end if;
   end process RD_DATA_REG;

-- ****************************************************************************
-- This process is used for registering Write response
-- ****************************************************************************

   WR_RESP_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             BRESP_1_i <= '0';
          else
             if (send_wr_resp = '1') then
                 BRESP_1_i <= slv_err_resp;
             elsif (S_AXI_BREADY = '1') then
                 BRESP_1_i <= '0';
             end if;
          end if;
      end if;
   end process WR_RESP_REG;

-------------------------------------------------------------------------------
-- FSM
-------------------------------------------------------------------------------
-- ****************************************************************************
-- AXI Write Read State Machine -- START
-- ****************************************************************************

   AXI_WR_RD_SM   : process (axi_wr_rd_cs,
                             S_AXI_AWVALID,
                             S_AXI_WVALID,
                             S_AXI_BREADY,
                             S_AXI_ARVALID,
                             S_AXI_RREADY,
                             apb_pready,
                             data_timeout
                             ) is
   begin

      axi_wr_rd_ns <= axi_wr_rd_cs;
      write_ready_sm <= '0';
      waddr_ready_sm <= '0';
      wr_request <= '0';
      rd_request <= '0';
      BVALID_sm <= '0';
      RVALID_sm <= '0';
      arready_sm <= '0';
      load_cntr <= '0';
      both_valids <= '0';
      send_rd <= '0';
      send_wr_resp <= '0';
      cntr_enable <= '0';

      case axi_wr_rd_cs is

           when AXI_IDLE =>
                if (S_AXI_ARVALID = '1') then
                     rd_request <= '1';
                     load_cntr <= '1';
                     arready_sm <= '1';
                     axi_wr_rd_ns <= READ_WAIT;
                elsif(S_AXI_AWVALID = '1' and
                      S_AXI_WVALID = '1') then
                     write_ready_sm <= '1';
                     waddr_ready_sm <= '1';
                     wr_request <= '1';
                     both_valids <= '1';
                     load_cntr <= '1';
                     axi_wr_rd_ns <= WRITE_WAIT;
                elsif(S_AXI_AWVALID = '1') then
                     waddr_ready_sm <= '1';
                     axi_wr_rd_ns <= WRITE_W_WAIT;
                end if;

           when WRITE_WAIT =>
                cntr_enable <= '1';
                axi_wr_rd_ns <= WRITE;

           when WRITE_W_WAIT =>
                if(S_AXI_WVALID = '1') then
                     write_ready_sm <= '1';
                     wr_request <= '1';
                     load_cntr <= '1';
                     axi_wr_rd_ns <= WRITE;
                end if;

           when WRITE =>
                cntr_enable <= '1';
                if(apb_pready = '1' or data_timeout = '1') then
                     cntr_enable <= '0';
                     send_wr_resp <= '1';
                     BVALID_sm <= '1';
                     axi_wr_rd_ns <= WR_RESP;
                end if;

           when WR_RESP =>
                if (S_AXI_BREADY = '1') then
                    axi_wr_rd_ns <= AXI_IDLE;
                else
                    BVALID_sm <= '1';
                end if;

           when READ_WAIT =>
                cntr_enable <= '1';
                axi_wr_rd_ns <= READ;

           when READ =>
                cntr_enable <= '1';
                if(apb_pready = '1' or data_timeout = '1') then
                     cntr_enable <= '0';
                     RVALID_sm <= '1';
                     send_rd <= '1';
                     axi_wr_rd_ns <= RD_RESP;
                end if;

           when RD_RESP =>                
                if(S_AXI_RREADY = '1') then
                     if(S_AXI_AWVALID = '1' and
                        S_AXI_WVALID = '1') then
                          write_ready_sm <= '1';
                          waddr_ready_sm <= '1';
                          wr_request <= '1';
                          load_cntr <= '1';
                          both_valids <= '1';
                          axi_wr_rd_ns <= WRITE_WAIT;
                     elsif(S_AXI_AWVALID = '1') then
                          waddr_ready_sm <= '1';
                          axi_wr_rd_ns <= WRITE_W_WAIT;
                     else
                          axi_wr_rd_ns <= AXI_IDLE;
                     end if;
                else
                     RVALID_sm <= '1';
                end if;

          -- coverage off
           when others =>
                axi_wr_rd_ns <= AXI_IDLE;
          -- coverage on

       end case;

   end process AXI_WR_RD_SM;

-------------------------------------------------------------------------------
-- Registering the signals generated from the AXI_WR_RD_SM state machine
-------------------------------------------------------------------------------

   AXI_WR_DATA_SM_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
         if (S_AXI_ARESETN = '0') then
             axi_wr_rd_cs <= AXI_IDLE;
             ARREADY_i <= '0';
             WREADY_i <= '0';
             AWREADY_i <= '0';
             BVALID_i <= '0';
             RVALID_i <= '0';
         else
             axi_wr_rd_cs <= axi_wr_rd_ns;
             WREADY_i <= write_ready_sm;
             AWREADY_i <= waddr_ready_sm;
             ARREADY_i <= arready_sm;
             BVALID_i <= BVALID_sm;
             RVALID_i <= RVALID_sm;
         end if;
      end if;
   end process AXI_WR_DATA_SM_REG;
   
   -------------------------------------------------------------------------------
   -- This implements the dataphase watchdog timeout function. The counter is
   -- allowed to count down when an active APB operation is ongoing. A data 
   -- acknowledge from the target address space forces the counter to reload.
   -- When the APB is not responding and not generating apb_ready within the
   -- number of clock cycles mentioned in C_DPHASE_TIMEOUT, AXI generates
   -- ready so that AXI is not hung.
   ------------------------------------------------------------------------------- 
    
   DATA_PHASE_WDT : if (C_DPHASE_TIMEOUT /= 0) generate
    
    
       constant TIMEOUT_VALUE_TO_USE : integer := C_DPHASE_TIMEOUT;
       constant COUNTER_WIDTH        : Integer := clog2(TIMEOUT_VALUE_TO_USE);
       constant DPTO_LD_VALUE        : std_logic_vector(COUNTER_WIDTH-1 downto 0)
                                     := std_logic_vector(to_unsigned
                                        (TIMEOUT_VALUE_TO_USE-1,COUNTER_WIDTH));
       signal timeout_i              : std_logic;
       signal cntr_start             : std_logic;
       signal cntr_rst               : std_logic;
    
   begin
          
   
-- ****************************************************************************
-- This process is used for generating the counter enable
-- ****************************************************************************

   WR_RESP_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             cntr_start <= '0';
          else
             if (load_cntr = '1') then
                 cntr_start <= '1';
             elsif (timeout_i = '1') then
                 cntr_start <= '0';
             end if;
          end if;
      end if;
   end process WR_RESP_REG;
   
   cntr_rst <= not S_AXI_ARESETN or timeout_i;
   
-- ****************************************************************************
-- Instantiation of counter from proc_common
-- ****************************************************************************

      I_DPTO_COUNTER : entity axi_apb_bridge_v3_0.counter_f
         generic map(
           C_NUM_BITS    =>  COUNTER_WIDTH,
           C_FAMILY      =>  C_FAMILY
             )
         port map(
           Clk           =>  S_AXI_ACLK,
           Rst           =>  cntr_rst,
           Load_In       =>  DPTO_LD_VALUE,
           Count_Enable  =>  cntr_enable,
           Count_Load    =>  load_cntr,
           Count_Down    =>  '1',
           Count_Out     =>  open,
           Carry_Out     =>  timeout_i
           );
       
-- ****************************************************************************
-- This process is used for registering data_timeout
-- ****************************************************************************

       REG_TIMEOUT : process(S_AXI_ACLK)
       begin
           if(S_AXI_ACLK'EVENT and S_AXI_ACLK='1')then
               if(S_AXI_ARESETN='0')then
                   data_timeout <= '0';
               else
                   if (data_timeout = '1') then
                       data_timeout <= '0';
                   elsif (timeout_i = '1' and apb_pready = '0') then
                       data_timeout <= '1';
                   end if;
               end if;
           end if;
       end process REG_TIMEOUT;
       
   end generate DATA_PHASE_WDT;
   
-- ****************************************************************************
-- No logic when C_DPHASE_TIMEOUT = 0
-- ****************************************************************************

   NO_DATA_PHASE_WDT : if (C_DPHASE_TIMEOUT = 0) generate
   begin
        data_timeout <= '0';
   end generate NO_DATA_PHASE_WDT;

end architecture RTL;
