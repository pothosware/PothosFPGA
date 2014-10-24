------------------------------------------------------------------------
-- Tests for the stream splitter module.
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

entity SplitterTb is
end entity SplitterTb;

architecture test of SplitterTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    -- test 0 signals
    signal src0_data : std_ulogic_vector(31 downto 0);
    signal src0_valid : std_ulogic;
    signal src0_ready : std_ulogic;
    signal dst0_data : std_ulogic_vector(31 downto 0);
    signal dst0_valid : std_ulogic_vector(0 downto 0);
    signal dst0_ready : std_ulogic_vector(0 downto 0);

    -- test 1 signals
    signal src1_data : std_ulogic_vector(31 downto 0);
    signal src1_valid : std_ulogic;
    signal src1_ready : std_ulogic;
    signal dst1_data : std_ulogic_vector(63 downto 0);
    signal dst1_valid : std_ulogic_vector(1 downto 0);
    signal dst1_ready : std_ulogic_vector(1 downto 0);

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- test0: splitter with only one output
    --------------------------------------------------------------------
    test0_source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => src0_data,
        out_valid => src0_valid,
        out_ready => src0_ready
    );

    test0_splitter: entity PothosInterconnect.StreamSplitter
    generic map (
        NUM_OUTPUTS => 1
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

    test0_sink0: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 0
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => dst0_data,
        in_valid => dst0_valid(0),
        in_ready => dst0_ready(0)
    );

    --------------------------------------------------------------------
    -- test1: splitter with two outputs
    --------------------------------------------------------------------
    test1_source1: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 1
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => src1_data,
        out_valid => src1_valid,
        out_ready => src1_ready
    );

    test1_splitter: entity PothosInterconnect.StreamSplitter
    generic map (
        NUM_OUTPUTS => 2
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => src1_data,
        in_valid => src1_valid,
        in_ready => src1_ready,
        out_data => dst1_data,
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
        in_valid => dst1_valid(0),
        in_ready => dst1_ready(0)
    );

    test1_sink2: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 2
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => dst1_data(63 downto 32),
        in_valid => dst1_valid(1),
        in_ready => dst1_ready(1)
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
