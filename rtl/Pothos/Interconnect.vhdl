------------------------------------------------------------------------
-- Interconnect implementation
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Interconnect is
    generic(

        -- the number of input ports
        NUM_INPUTS : positive;

        -- the number of output ports
        NUM_OUTPUTS : positive;

        -- the bit width of a single port
        DATA_WIDTH : positive;

        -- the number of internal lanes to generate
        NUM_LANES : positive;

        -- high bandwidth ports for performance hints
        -- each bit represents a port by index number
        HIGH_BW_INS : std_logic_vector;
        HIGH_BW_OUTS : std_logic_vector
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- configuration channel
        -- TODO addr and data interpretation
        config_write : in std_logic;
        config_addr : in std_logic_vector(31 downto 0);
        config_data : in std_logic_vector(31 downto 0);

        -- all ports into the interconnect
        in_data : in std_logic_vector((NUM_INPUTS*DATA_WIDTH)-1 downto 0);
        in_meta : in std_logic_vector(NUM_INPUTS-1 downto 0);
        in_last : in std_logic_vector(NUM_INPUTS-1 downto 0);
        in_valid : in std_logic_vector(NUM_INPUTS-1 downto 0);
        in_ready : out std_logic_vector(NUM_INPUTS-1 downto 0);

        -- all ports out from the interconnect
        out_data : out std_logic_vector((NUM_OUTPUTS*DATA_WIDTH)-1 downto 0);
        out_meta : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
        out_last : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
        out_valid : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
        out_ready : in std_logic_vector(NUM_OUTPUTS-1 downto 0)
    );
end entity Interconnect;

architecture rtl of Interconnect is
begin
    --TODO
end architecture rtl;
