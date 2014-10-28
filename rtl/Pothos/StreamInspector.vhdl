------------------------------------------------------------------------
-- StreamInspector
--
-- Inspect a stream and produce utility signals.
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity StreamInspector is
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- streaming bus signals
        last : in std_ulogic := '1';
        valid : in std_ulogic;
        ready : in std_ulogic;

        -- the stream is transfering a packet and this is not the last cycle
        packet_busy : out std_ulogic;

        --this is the first cycle of a packet transfer
        packet_begin : out std_ulogic;

        --this is the last cycle of a packet transfer
        packet_end : out std_ulogic
    );
end entity StreamInspector;

architecture rtl of StreamInspector is
    signal packet_xfer : std_ulogic;
    signal packet_begin_i : std_ulogic := '0';
    signal packet_end_i : std_ulogic := '0';
begin

    packet_begin_i <= valid and ready and not packet_xfer;
    packet_end_i <= valid and ready and last;
    packet_busy <= (packet_begin_i or packet_xfer) and not packet_end_i;

    packet_begin <= packet_begin_i;
    packet_end <= packet_end_i;

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                packet_xfer <= '0';
            elsif (valid = '1' and ready = '1') then
                packet_xfer <= not last;
            end if;
        end if;
    end process;

end architecture rtl;
