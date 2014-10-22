------------------------------------------------------------------------
-- Simple loopback test bench with the stream fifo in the middle
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

entity FifoTb is
end entity FifoTb;

architecture test of FifoTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    signal data0 : std_ulogic_vector(31 downto 0);
    signal valid0 : std_ulogic;
    signal ready0 : std_ulogic;

    signal data1 : std_ulogic_vector(31 downto 0);
    signal valid1 : std_ulogic;
    signal ready1 : std_ulogic;

    signal data2 : std_ulogic_vector(31 downto 0);
    signal valid2 : std_ulogic;
    signal ready2 : std_ulogic;

    signal data3 : std_ulogic_vector(31 downto 0);
    signal valid3 : std_ulogic;
    signal ready3 : std_ulogic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- test fifo based on block ram
    --------------------------------------------------------------------
    source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => data0,
        out_valid => valid0,
        out_ready => ready0
    );

    fifo0: entity PothosInterconnect.StreamFifo
    generic map (
        MEM_SIZE => 10,
        SYNC_READ => true -- block ram
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => data0,
        in_valid => valid0,
        in_ready => ready0,
        out_data => data1,
        out_valid => valid1,
        out_ready => ready1
    );

    sink0: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => data1,
        in_valid => valid1,
        in_ready => ready1
    );

    --------------------------------------------------------------------
    -- test fifo based on dist ram
    --------------------------------------------------------------------
    source1: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 1
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => data2,
        out_valid => valid2,
        out_ready => ready2
    );

    fifo1: entity PothosInterconnect.StreamFifo
    generic map (
        MEM_SIZE => 10,
        SYNC_READ => false -- dist ram
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => data2,
        in_valid => valid2,
        in_ready => ready2,
        out_data => data3,
        out_valid => valid3,
        out_ready => ready3
    );

    sink1: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 1
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => data3,
        in_valid => valid3,
        in_ready => ready3
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
