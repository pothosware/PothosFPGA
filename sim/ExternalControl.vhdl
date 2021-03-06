------------------------------------------------------------------------
-- External control implementation
-- Low speed read and write control buses.
--
-- Copyright (c) 2014-2015 Josh Blum
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
        clk : in std_logic;
        rst : in std_logic;

        --bus address
        paddr : out std_logic_vector;

        --peripheral select
        psel : out std_logic;

        --transaction enable (high on second and subsequent cycles)
        penable : out std_logic;

        --perform a control write
        --address and write data are valid on the write cycle
        pwrite : out std_logic;

        --write data
        pwdata : out std_logic_vector;

        --slave perif ready
        pready : in std_logic;

        --read data
        prdata : in std_logic_vector
    );
end entity ExternalControl;

architecture sim of ExternalControl is begin

    process (clk)
        variable handle : integer := setupControl(ID);
        variable action : integer := 0;
    begin

        if (rising_edge(clk)) then
            if (rst = '1') then
                paddr <= std_logic_vector(to_signed(0, paddr'length));
                pwdata <= std_logic_vector(to_signed(0, pwdata'length));
                psel <= '0';
                pwrite <= '0';
                penable <= '0';
                action := 0;
            else
                if (action = 0) then
                    action := controlGetAction(handle);
                    penable <= '0';
                    if (action = 1) then
                        pwrite <= '1';
                        paddr <= std_logic_vector(to_signed(controlGetAddr(handle), paddr'length));
                        pwdata <= std_logic_vector(to_signed(controlGetData(handle), pwdata'length));
                        psel <= '1';
                    elsif (action = 2) then
                        paddr <= std_logic_vector(to_signed(controlGetAddr(handle), paddr'length));
                        psel <= '1';
                    end if;
                else
                    penable <= '1';
                    if (pready = '1') then
                        controlPutData(handle, to_integer(signed(prdata)));
                        psel <= '0';
                        pwrite <= '0';
                        penable <= '0';
                        action := controlGetAction(handle);
                    end if;
                end if;
            end if;
        end if;

    end process;

end architecture sim;
