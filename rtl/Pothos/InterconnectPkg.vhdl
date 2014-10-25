------------------------------------------------------------------------
-- Interconnect configuration constants
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

package InterconnectPkg is

    --IC = interconnect configuation

    --Write this address to select a lane.
    --The data format is an available lane index.
    constant IC_LANE_SELECT_ADDR : natural;

    --Write this address to select an input port.
    --The data format is an available input index.
    constant IC_INPUT_SELECT_ADDR : natural;

    --Write this address to program a lane destination.
    --The user should first program the input select.
    --The data format is a bit mask of lane enables,
    --where each bit corresponds to a lane index.
    constant IC_LANE_DEST_MASK_ADDR : natural;

    --Write this address to program an output destination.
    --The user should first program the input and lane select.
    --The data format is a bit mask of output enables,
    --where each bit corresponds to an output port index.
    constant IC_OUTPUT_DEST_MASK_ADDR : natural;

end InterconnectPkg;

package body InterconnectPkg is

    constant IC_LANE_SELECT_ADDR : natural := 10;
    constant IC_INPUT_SELECT_ADDR : natural := 11;
    constant IC_LANE_DEST_MASK_ADDR : natural := 12;
    constant IC_OUTPUT_DEST_MASK_ADDR : natural := 13;

end InterconnectPkg;
