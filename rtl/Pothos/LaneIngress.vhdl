------------------------------------------------------------------------
-- Lane Ingress implementation
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LaneOutgress is
    generic(
        -- the bit width of the input port
        DATA_WIDTH : positive;

        -- the number input and output lanes
        NUM_LANES : positive;

        -- the number of this ingress port
        PORT_NUMBER : natural
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        --lanes in
        in_lane_data : in std_ulogic_vector;
        in_lane_dest : in std_ulogic_vector;
        in_lane_last : in std_ulogic_vector;
        in_lane_valid : in std_ulogic_vector;
        in_lane_ready : out std_ulogic_vector;

        --lanes out
        out_lane_data : out std_ulogic_vector;
        out_lane_dest : out std_ulogic_vector;
        out_lane_last : out std_ulogic_vector;
        out_lane_valid : out std_ulogic_vector;
        out_lane_ready : in std_ulogic_vector;

        -- ingress streaming port
        in_data : in std_ulogic_vector;
        in_last : in std_ulogic;
        in_valid : in std_ulogic;
        in_ready : out std_ulogic
    );
end entity LaneOutgress;

architecture rtl of LaneOutgress is
begin
    --TODO
end architecture rtl;
