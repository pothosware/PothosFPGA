------------------------------------------------------------------------
-- StreamInspector - Inspect a stream and produce utility signals.
--
-- Copyright (c) 2014-2015 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity StreamInspector is
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- streaming bus signals
        last : in std_logic := '1';
        valid : in std_logic;
        ready : in std_logic;

        -- the stream is transfering a packet (does not include first cycle)
        packet_xfer : out std_logic;

        -- the stream is transfering a packet (does not include last cycle)
        packet_busy : out std_logic;

        --this is the first cycle of a packet transfer
        packet_begin : out std_logic;

        --this is the last cycle of a packet transfer
        packet_end : out std_logic
    );
end entity StreamInspector;

architecture rtl of StreamInspector is
    signal packet_xfer_i : std_logic := '0';
    signal packet_begin_i : std_logic := '0';
    signal packet_end_i : std_logic := '0';
begin

    packet_begin_i <= valid and ready and not packet_xfer_i;
    packet_end_i <= valid and ready and last;
    packet_busy <= (packet_begin_i or packet_xfer_i) and not packet_end_i;

    packet_xfer <= packet_xfer_i;
    packet_begin <= packet_begin_i;
    packet_end <= packet_end_i;

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                packet_xfer_i <= '0';
            elsif (valid = '1' and ready = '1') then
                packet_xfer_i <= not last;
            end if;
        end if;
    end process;

end architecture rtl;
