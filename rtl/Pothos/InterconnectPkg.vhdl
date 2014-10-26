------------------------------------------------------------------------
-- Interconnect configuration constants
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

package InterconnectPkg is

    --IC = interconnect configuation

    --The version number of the interconnect config.
    --This value can be read with IC_VERSION_ADDR.
    constant IC_VERSION : natural;

    --Read this address to get the config version.
    --This value should change with config address changes,
    --so the host driver can determine the correct procedure.
    constant IC_VERSION_ADDR : natural;

    --Read this address to get the total lane count.
    constant IC_NUM_LANES_ADDR : natural;

    --Read this address to get the total input count.
    constant IC_NUM_INPUTS_ADDR : natural;

    --Read this address to get the total output count.
    constant IC_NUM_OUTPUTS_ADDR : natural;

    --Write this address to set a value.
    --Read this address to readback the value.
    --This is a sanity check for the config bus.
    constant IC_TEST_LOOPBACK_ADDR : natural;

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

    --increment on breaking changes
    constant IC_VERSION : natural := 1;

    constant IC_VERSION_ADDR : natural := 5;
    constant IC_NUM_LANES_ADDR : natural := 6;
    constant IC_NUM_INPUTS_ADDR : natural := 7;
    constant IC_NUM_OUTPUTS_ADDR : natural := 8;
    constant IC_TEST_LOOPBACK_ADDR : natural := 9;
    constant IC_LANE_SELECT_ADDR : natural := 10;
    constant IC_INPUT_SELECT_ADDR : natural := 11;
    constant IC_LANE_DEST_MASK_ADDR : natural := 12;
    constant IC_OUTPUT_DEST_MASK_ADDR : natural := 13;

end InterconnectPkg;
