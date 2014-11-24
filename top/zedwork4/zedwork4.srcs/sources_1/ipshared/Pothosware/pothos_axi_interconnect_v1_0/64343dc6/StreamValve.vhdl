------------------------------------------------------------------------
-- StreamValve - Control a stream's flow using an external signal.
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity StreamValve is
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- Control stream forwarding:
        -- '1' forward input to output
        -- '0' backpressure input stream
        -- forward is only valid at packet start
        forward : in std_ulogic;

        -- input bus
        in_data : in std_ulogic_vector;
        in_last : in std_ulogic;
        in_valid : in std_ulogic;
        in_ready : out std_ulogic;

        -- output bus
        out_data : out std_ulogic_vector;
        out_last : out std_ulogic;
        out_valid : out std_ulogic;
        out_ready : in std_ulogic
    );
end entity StreamValve;

architecture rtl of StreamValve is
    signal in_ready_i : std_ulogic;
    signal packet_xfer : std_ulogic;
begin

    assert (in_data'length = out_data'length) report "StreamValve: data width mismatch" severity failure;

    out_data <= in_data;
    out_last <= in_last;
    in_ready <= in_ready_i;

    out_valid <= in_valid when (packet_xfer = '1') else forward and in_valid;
    in_ready_i <= out_ready when (packet_xfer = '1') else forward and out_ready;

    inspect: entity work.StreamInspector
    port map (
        clk => clk,
        rst => rst,
        last => in_last,
        valid => in_valid,
        ready => in_ready_i,
        packet_xfer => packet_xfer
    );

end architecture rtl;
