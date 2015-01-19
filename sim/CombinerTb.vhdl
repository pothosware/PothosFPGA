------------------------------------------------------------------------
-- Tests for the stream combiner module.
-- Copyright (c) 2014-2015 Josh Blum
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

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- test 0 signals
    signal src0_data : std_logic_vector(32 downto 0); --meta1, data32
    signal src0_last : std_logic_vector(0 downto 0);
    signal src0_valid : std_logic_vector(0 downto 0);
    signal src0_ready : std_logic_vector(0 downto 0);
    signal dst0_data : std_logic_vector(32 downto 0); --meta1, data32
    signal dst0_last : std_logic;
    signal dst0_valid : std_logic;
    signal dst0_ready : std_logic;

    -- test 1 signals
    signal src1_data : std_logic_vector(65 downto 0); --(meta1, data32) X2
    signal src1_last : std_logic_vector(1 downto 0);
    signal src1_valid : std_logic_vector(1 downto 0);
    signal src1_ready : std_logic_vector(1 downto 0);
    signal dst1_data : std_logic_vector(32 downto 0); --meta1, data32
    signal dst1_last : std_logic;
    signal dst1_valid : std_logic;
    signal dst1_ready : std_logic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- test0: combiner with only one input
    --------------------------------------------------------------------
    test0_source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => src0_data(31 downto 0),
        out_meta => src0_data(32),
        out_last => src0_last(0),
        out_valid => src0_valid(0),
        out_ready => src0_ready(0)
    );

    test0_combiner: entity PothosInterconnect.StreamCombiner
    generic map (
        NUM_INPUTS => 1
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => src0_data,
        in_last => src0_last,
        in_valid => src0_valid,
        in_ready => src0_ready,
        out_data => dst0_data,
        out_last => dst0_last,
        out_valid => dst0_valid,
        out_ready => dst0_ready
    );

    test0_sink0: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => dst0_data(31 downto 0),
        in_meta => dst0_data(32),
        in_last => dst0_last,
        in_valid => dst0_valid,
        in_ready => dst0_ready
    );

    --------------------------------------------------------------------
    -- test1: combiner with two inputs
    --------------------------------------------------------------------
    test1_source1: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 1
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => src1_data(31 downto 0),
        out_meta => src1_data(32),
        out_last => src1_last(0),
        out_valid => src1_valid(0),
        out_ready => src1_ready(0)
    );

    test1_source2: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 2
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => src1_data(64 downto 33),
        out_meta => src1_data(65),
        out_last => src1_last(1),
        out_valid => src1_valid(1),
        out_ready => src1_ready(1)
    );

    test1_combiner: entity PothosInterconnect.StreamCombiner
    generic map (
        NUM_INPUTS => 2
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => src1_data,
        in_last => src1_last,
        in_valid => src1_valid,
        in_ready => src1_ready,
        out_data => dst1_data,
        out_last => dst1_last,
        out_valid => dst1_valid,
        out_ready => dst1_ready
    );

    test1_sink1: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 1
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => dst1_data(31 downto 0),
        in_meta => dst1_data(32),
        in_last => dst1_last,
        in_valid => dst1_valid,
        in_ready => dst1_ready
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
