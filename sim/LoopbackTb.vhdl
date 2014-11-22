------------------------------------------------------------------------
-- Simple loopback test bench for trying out external port interfaces
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

entity LoopbackTb is
end entity LoopbackTb;

architecture test of LoopbackTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    -- loopback test signals
    signal data : std_ulogic_vector(31 downto 0);
    signal meta : std_ulogic;
    signal last : std_ulogic;
    signal valid : std_ulogic;
    signal ready : std_ulogic;

    -- control test signals
    signal paddr : std_ulogic_vector(31 downto 0);
    signal pwrite : std_ulogic;
    signal psel : std_ulogic;
    signal penable : std_ulogic;
    signal pwdata : std_ulogic_vector(31 downto 0);
    signal pready : std_ulogic;
    signal prdata : std_ulogic_vector(31 downto 0);
    signal ctrl_addr_num : natural;
    signal ctrl_wr : std_ulogic;
    signal ctrl_rd : std_ulogic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- test0: basic stream loopback
    --------------------------------------------------------------------
    source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => data,
        out_meta => meta,
        out_last => last,
        out_valid => valid,
        out_ready => ready
    );

    sink0: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => data,
        in_meta => meta,
        in_last => last,
        in_valid => valid,
        in_ready => ready
    );

    --------------------------------------------------------------------
    -- test1: basic control loopback
    --------------------------------------------------------------------
    process (psel, paddr) begin
        if (psel = '1') then
            ctrl_addr_num <= to_integer(signed(paddr));
        end if;
    end process;

    ctrl_wr <= psel and pwrite;
    ctrl_rd <= psel and not pwrite;
    pready <= penable;

    ctrl0: entity PothosSimulation.ExternalControl
    generic map (
        ID => 0
    )
    port map (
        clk => clk,
        rst => rst,
        paddr => paddr,
        pwrite => pwrite,
        psel => psel,
        penable => penable,
        pwdata => pwdata,
        pready => pready,
        prdata => prdata
    );

    ram0: entity PothosInterconnect.dual_port_ram
    generic map (
        MEM_SIZE => 4,
        SYNC_READ => false
    )
    port map (
        Wr_clock => clk,
        We => ctrl_wr,
        Wr_addr => ctrl_addr_num,
        Wr_data => pwdata,
        Rd_clock => clk,
        Re => ctrl_rd,
        Rd_addr => ctrl_addr_num,
        Rd_data => prdata
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
