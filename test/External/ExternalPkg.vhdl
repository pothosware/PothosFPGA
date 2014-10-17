------------------------------------------------------------------------
-- Top level package for external interfaces into C
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package ExternalPkg is

    --------------------------------------------------------------------
    -- External output:
    -- Interface an external resource provider to an output bus.
    --------------------------------------------------------------------
    component ExternalOutput is
        generic(
            -- the external interface port identification number
            PORT_NUMBER : natural;

            -- the bit width of the data port
            DATA_WIDTH : positive
        );
        port(
            clk : in std_logic;
            rst : in std_logic;

            -- output bus
            out_data : out std_logic_vector((DATA_WIDTH)-1 downto 0);
            out_valid : out std_logic;
            out_ready : in std_logic
        );
    end component ExternalOutput;

    --------------------------------------------------------------------
    -- External input:
    -- Interface an input bus with an external resource consumer.
    --------------------------------------------------------------------
    component ExternalInput is
        generic(
            -- the external interface port identification number
            PORT_NUMBER : natural;

            -- the bit width of the data port
            DATA_WIDTH : positive
        );
        port(
            clk : in std_logic;
            rst : in std_logic;

            -- input bus
            in_data : in std_logic_vector((DATA_WIDTH)-1 downto 0);
            in_valid : in std_logic;
            in_ready : out std_logic
        );
    end component ExternalInput;

end package ExternalPkg;
