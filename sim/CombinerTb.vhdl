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

    -- test 0 signals
    signal src0_data : std_ulogic_vector(31 downto 0);
    signal src0_valid : std_ulogic_vector(0 downto 0);
    signal src0_ready : std_ulogic_vector(0 downto 0);
    signal dst0_data : std_ulogic_vector(31 downto 0);
    signal dst0_valid : std_ulogic;
    signal dst0_ready : std_ulogic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- test0: combiner with only one input
    --------------------------------------------------------------------
    source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => src0_data,
        out_valid => src0_valid(0),
        out_ready => src0_ready(0)
    );

    combiner0: entity PothosInterconnect.StreamCombiner
    generic map (
        NUM_INPUTS => 1
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => src0_data,
        in_valid => src0_valid,
        in_ready => src0_ready,
        out_data => dst0_data,
        out_valid => dst0_valid,
        out_ready => dst0_ready
    );

    sink0: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => dst0_data,
        in_valid => dst0_valid,
        in_ready => dst0_ready
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
