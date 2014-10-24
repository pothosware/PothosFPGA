------------------------------------------------------------------------
-- External output implementation
-- Write stream data to an output bus.
--
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
        PORT_NUMBER : natural
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- output bus
        out_data : out std_ulogic_vector;
        out_meta : out std_ulogic;
        out_last : out std_ulogic;
        out_valid : out std_ulogic;
        out_ready : in std_ulogic
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
                out_data <= std_ulogic_vector(to_signed(sourceFrontData(handle), out_data'length));
                if (sourceMetaData(handle)) then
                    out_meta <= '1';
                else
                    out_meta <= '0';
                end if;
                if (sourceLastData(handle)) then
                    out_last <= '1';
                else
                    out_last <= '0';
                end if;
            else
                out_valid <= '0';
            end if;
        end if;

        if (rising_edge(clk)) then
            if (rst = '1') then
                out_valid <= '0';
                out_data <= std_ulogic_vector(to_signed(0, out_data'length));
                out_last <= '0';
            elsif (out_ready = '1' and thisValid) then
                sourcePopData(handle);
            end if;
        end if;

    end process;

end architecture sim;
