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

library extras;

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
    signal ctrl_wr : std_ulogic;
    signal ctrl_rd : std_ulogic;
    signal ctrl_addr : std_ulogic_vector(31 downto 0);
    signal ctrl_out_data : std_ulogic_vector(31 downto 0);
    signal ctrl_in_data : std_ulogic_vector(31 downto 0);
    signal ctrl_addr_num : natural;

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
    process (ctrl_wr, ctrl_rd) begin
        if (ctrl_wr = '1' or ctrl_rd = '1') then
            ctrl_addr_num <= to_integer(signed(ctrl_addr));
        end if;
    end process;

    ctrl0: entity PothosSimulation.ExternalControl
    generic map (
        ID => 0
    )
    port map (
        clk => clk,
        rst => rst,
        wr => ctrl_wr,
        rd => ctrl_rd,
        addr => ctrl_addr,
        out_data => ctrl_out_data,
        in_data => ctrl_in_data
    );

    ram0: entity extras.dual_port_ram
    generic map (
        MEM_SIZE => 4,
        SYNC_READ => false
    )
    port map (
        Wr_clock => clk,
        We => ctrl_wr,
        Wr_addr => ctrl_addr_num,
        Wr_data => ctrl_out_data,
        Rd_clock => clk,
        Re => ctrl_rd,
        Rd_addr => ctrl_addr_num,
        Rd_data => ctrl_in_data
    );

    process begin
        initProxyServer(0);
        wait;
    end process;

end architecture test;
