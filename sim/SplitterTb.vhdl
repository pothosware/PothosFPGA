------------------------------------------------------------------------
-- Tests for the stream splitter module.
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

entity SplitterTb is
end entity SplitterTb;

architecture test of SplitterTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    -- test 0 signals
    signal src0_data : std_ulogic_vector(32 downto 0); --meta1, data32
    signal src0_last : std_ulogic;
    signal src0_valid : std_ulogic;
    signal src0_ready : std_ulogic;
    signal dst0_data : std_ulogic_vector(32 downto 0); --meta1, data32
    signal dst0_last : std_ulogic_vector(0 downto 0);
    signal dst0_valid : std_ulogic_vector(0 downto 0);
    signal dst0_ready : std_ulogic_vector(0 downto 0);

    -- test 1 signals
    signal enables1 : std_ulogic_vector(1 downto 0);
    signal src1_data : std_ulogic_vector(32 downto 0); --meta1, data32
    signal src1_last : std_ulogic;
    signal src1_valid : std_ulogic;
    signal src1_ready : std_ulogic;
    signal dst1_data : std_ulogic_vector(65 downto 0); --(meta1, data32) X2
    signal dst1_last : std_ulogic_vector(1 downto 0);
    signal dst1_valid : std_ulogic_vector(1 downto 0);
    signal dst1_ready : std_ulogic_vector(1 downto 0);

    -- ctrl signals
    signal ctrl1_wr : std_ulogic;
    signal ctrl1_addr : std_ulogic_vector(31 downto 0);
    signal ctrl1_out_data : std_ulogic_vector(31 downto 0);
    signal ctrl1_in_data : std_ulogic_vector(31 downto 0);

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
        out_data => src0_data(31 downto 0),
        out_meta => src0_data(32),
        out_last => src0_last,
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
        in_last => dst0_last(0),
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
        out_data => src1_data(31 downto 0),
        out_meta => src1_data(32),
        out_last => src1_last,
        out_valid => src1_valid,
        out_ready => src1_ready
    );

    --simple process to register a new enable setting for the splitter
    ctrl1_in_data <= (others => '0');
    process (clk) begin
        if (rst = '1') then
            enables1 <= (others => '0');
        elsif (ctrl1_wr = '1' and to_integer(signed(ctrl1_addr)) = 1) then
            enables1 <= ctrl1_out_data(1 downto 0);
        end if;
    end process;

    ctrl1: entity PothosSimulation.ExternalControl
    generic map (
        ID => 0
    )
    port map (
        clk => clk,
        rst => rst,
        wr => ctrl1_wr,
        addr => ctrl1_addr,
        out_data => ctrl1_out_data,
        in_data => ctrl1_in_data
    );

    test1_splitter: entity PothosInterconnect.StreamSplitter
    generic map (
        NUM_OUTPUTS => 2
    )
    port map (
        clk => clk,
        rst => rst,
        enables => enables1,
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
        in_last => dst1_last(0),
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
        in_data => dst1_data(64 downto 33),
        in_meta => dst1_data(65),
        in_last => dst1_last(1),
        in_valid => dst1_valid(1),
        in_ready => dst1_ready(1)
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
