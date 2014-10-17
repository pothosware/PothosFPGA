------------------------------------------------------------------------
-- External input implementation
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ExternalInput is
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
end entity ExternalInput;

architecture sim of ExternalInput is



    begin
end architecture sim;
