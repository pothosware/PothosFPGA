------------------------------------------------------------------------
-- Tests for the interconnect module.
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

library extras;

entity InterconnectTb is
end entity InterconnectTb;

architecture test of InterconnectTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    constant NUM_INPUTS : positive := 2;
    constant NUM_OUTPUTS : positive := 2;
    constant NUM_LANES : positive := 2;

    --input port signals
    signal in_data : std_ulogic_vector((NUM_INPUTS*32)-1 downto 0);
    signal in_meta : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_last : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_valid : std_ulogic_vector(NUM_INPUTS-1 downto 0);
    signal in_ready : std_ulogic_vector(NUM_INPUTS-1 downto 0);

    --output port signals
    signal out_data : std_ulogic_vector((NUM_OUTPUTS*32)-1 downto 0);
    signal out_meta : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_last : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_valid : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal out_ready : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);

    --control signals
    signal paddr : std_ulogic_vector(31 downto 0);
    signal pwrite : std_ulogic;
    signal psel : std_ulogic;
    signal penable : std_ulogic;
    signal pwdata : std_ulogic_vector(31 downto 0);
    signal pready : std_ulogic;
    signal prdata : std_ulogic_vector(31 downto 0);

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

    --------------------------------------------------------------------
    -- external control interface
    --------------------------------------------------------------------
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

    --------------------------------------------------------------------
    -- external source blocks
    --------------------------------------------------------------------
    gen_sources: for i in 0 to (NUM_INPUTS-1) generate begin

        source: entity PothosSimulation.ExternalSource
        generic map (
            PORT_NUMBER => i
        )
        port map (
            clk => clk,
            rst => rst,
            out_data => in_data(((i+1)*32)-1 downto i*32),
            out_meta => in_meta(i),
            out_last => in_last(i),
            out_valid => in_valid(i),
            out_ready => in_ready(i)
        );

    end generate gen_sources;

    --------------------------------------------------------------------
    -- external sink blocks
    --------------------------------------------------------------------
    gen_sinks: for i in 0 to (NUM_OUTPUTS-1) generate begin

        sink: entity PothosSimulation.ExternalSink
        generic map (
            PORT_NUMBER => i
        )
        port map (
            clk => clk,
            rst => rst,
            in_data => out_data(((i+1)*32)-1 downto i*32),
            in_meta => out_meta(i),
            in_last => out_last(i),
            in_valid => out_valid(i),
            in_ready => out_ready(i)
        );

    end generate gen_sinks;

    --------------------------------------------------------------------
    -- interconnect
    --------------------------------------------------------------------
    interconnect0: entity PothosInterconnect.Interconnect
    generic map (
        NUM_INPUTS => NUM_INPUTS,
        NUM_OUTPUTS => NUM_OUTPUTS,
        NUM_LANES => NUM_LANES
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
        prdata => prdata,

        in_data => in_data,
        in_meta => in_meta,
        in_last => in_last,
        in_valid => in_valid,
        in_ready => in_ready,

        out_data => out_data,
        out_meta => out_meta,
        out_last => out_last,
        out_valid => out_valid,
        out_ready => out_ready
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
