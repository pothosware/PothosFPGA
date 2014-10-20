------------------------------------------------------------------------
-- External input implementation
------------------------------------------------------------------------

library PothosFPGAHarness;
use PothosFPGAHarness.ExternalFunctionsPkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExternalSink is
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
end entity ExternalSink;

architecture sim of ExternalSink is begin

    process (clk)
        variable handle : integer := setupSink(PORT_NUMBER);
        variable thisReady : boolean := false;
    begin

        if (falling_edge(clk)) then
            thisReady := sinkHasSpace(handle);
            if (thisReady) then
                in_ready <= '1';
            else
                in_ready <= '0';
            end if;
        end if;

        if (rising_edge(clk)) then
            if (in_valid = '1' and thisReady) then
                sinkPushData(handle, to_integer(signed(in_data)));
            end if;
        end if;

    end process;

end architecture sim;
