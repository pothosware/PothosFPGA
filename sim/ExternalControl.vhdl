------------------------------------------------------------------------
-- External control implementation
-- Low speed read and write control buses.
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library PothosSimulation;
use PothosSimulation.ExternalFunctionsPkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExternalControl is
    generic(
        -- the external interface identification number
        ID : natural
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        --perform a control write
        --address and data out are valid on the write cycle
        wr : out std_ulogic;

        --perform a control read
        --address is valid on the read cycle
        --in data is read on the read cycle
        rd : out std_ulogic;

        --bus address
        addr : out std_ulogic_vector(31 downto 0);

        --data output
        out_data : out std_ulogic_vector(31 downto 0);

        --data input
        in_data : in std_ulogic_vector(31 downto 0)
    );
end entity ExternalControl;

architecture sim of ExternalControl is begin

    process (clk)
        variable handle : integer := setupControl(ID);
        variable action : integer := 0;
    begin

        if (rising_edge(clk)) then
            if (rst = '1') then
                addr <= (others => '0');
                out_data <= (others => '0');
                wr <= '0';
                rd <= '0';
            else
                action := controlGetAction(handle);
                if (action = 1) then
                    wr <= '1';
                    addr <= std_ulogic_vector(to_signed(controlGetAddr(handle), addr'length));
                    out_data <= std_ulogic_vector(to_signed(controlGetData(handle), out_data'length));
                    controlPutData(handle, 0);
                elsif (action = 2) then
                    rd <= '1';
                    addr <= std_ulogic_vector(to_signed(controlGetAddr(handle), addr'length));
                    controlPutData(handle, to_integer(signed(in_data)));
                else
                    wr <= '0';
                    rd <= '0';
                end if;
            end if;
        end if;

    end process;

end architecture sim;
