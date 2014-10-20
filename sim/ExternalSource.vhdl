------------------------------------------------------------------------
-- External output implementation
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExternalSource is
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
end entity ExternalSource;

architecture sim of ExternalSource is begin

    process (clk)
        variable handle : integer := setupSource(PORT_NUMBER);
        variable thisValid : boolean := false;
    begin

        if (falling_edge(clk)) then
            thisValid := sourceHasData(handle);
            if (thisValid) then
                out_valid <= '1';
                out_data <= std_logic_vector(to_signed(sourceFrontData(handle), DATA_WIDTH));
            else
                out_valid <= '0';
            end if;
        end if;

        if (rising_edge(clk)) then
            if (out_ready = '1' and thisValid) then
                sourcePopData(handle);
            end if;
        end if;

    end process;

end architecture sim;
