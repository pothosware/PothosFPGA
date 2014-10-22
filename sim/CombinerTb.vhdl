------------------------------------------------------------------------
-- Tests for the stream combiner module.
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

entity CombinerTb is
end entity CombinerTb;

architecture test of CombinerTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    signal data0 : std_ulogic_vector(31 downto 0);
    signal valid0 : std_ulogic_vector(0 downto 0);
    signal ready0 : std_ulogic_vector(0 downto 0);

    signal data1 : std_ulogic_vector(31 downto 0);
    signal valid1 : std_ulogic;
    signal ready1 : std_ulogic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- test combiner with only one input
    --------------------------------------------------------------------
    source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => data0,
        out_valid => valid0(0),
        out_ready => ready0(0)
    );

    combiner0: entity PothosInterconnect.StreamCombiner
    generic map (
        NUM_INPUTS => 1
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

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
