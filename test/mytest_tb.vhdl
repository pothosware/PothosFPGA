

------------------------------------------------------------------------------
--  TEST BENCH
------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    --use ieee.std_logic_unsigned.all;
    --use ieee.std_logic_textio.all;
    use std.textio.all;
library work;
use work.ExternalPkg.all;

entity mytest_tb is
end entity mytest_tb;
architecture test of mytest_tb is

    signal clk    :std_logic := '0';
    signal rst    :std_logic := '1';

    signal data : std_logic_vector(31 downto 0);
    signal valid : std_logic;
    signal ready : std_logic;

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 3 ns;

    extOut0: ExternalOutput
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

    extIn0: ExternalInput
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

end architecture;
