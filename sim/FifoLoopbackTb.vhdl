------------------------------------------------------------------------
-- Simple loopback test bench for trying out external port interfaces
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library PothosInterconnect;

entity FifoLoopbackTb is
end entity FifoLoopbackTb;

architecture test of FifoLoopbackTb is

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    signal data0 : std_ulogic_vector(31 downto 0);
    signal valid0 : std_ulogic;
    signal ready0 : std_ulogic;

    signal data1 : std_ulogic_vector(31 downto 0);
    signal valid1 : std_ulogic;
    signal ready1 : std_ulogic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 25 ns;

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
        MEM_SIZE => 10
    )
    port map (
        Clock => clk,
        Reset => rst,
        Wr_data => data0,
        Wr_valid => valid0,
        Wr_ready => ready0,
        Rd_data => data1,
        Rd_valid => valid1,
        Rd_ready => ready1
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
