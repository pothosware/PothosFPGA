------------------------------------------------------------------------
-- Simple loopback test bench for trying out external port interfaces
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.SimulationHarnessPkg.all;

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

    source0: entity work.ExternalSource
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

    sink0: entity work.ExternalSink
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
