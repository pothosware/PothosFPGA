------------------------------------------------------------------------
-- Simple loopback test bench for trying out external port interfaces
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

entity SimpleLoopbackTb is
end entity SimpleLoopbackTb;

architecture test of SimpleLoopbackTb is

    signal clk    :std_logic := '0';
    signal rst    :std_logic := '1';

    signal data : std_logic_vector(31 downto 0);
    signal valid : std_logic;
    signal ready : std_logic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 3 ns;

    source0: entity PothosSimulation.ExternalSource
    generic map (
        PORT_NUMBER => 0,
        DATA_WIDTH => 32
    )
    port map (
        clk => clk,
        rst => rst,
        out_data => data,
        out_valid => valid,
        out_ready => ready
    );

    sink0: entity PothosSimulation.ExternalSink
    generic map (
        PORT_NUMBER => 0,
        DATA_WIDTH => 32
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => data,
        in_valid => valid,
        in_ready => ready
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
