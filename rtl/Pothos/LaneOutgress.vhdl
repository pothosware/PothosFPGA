------------------------------------------------------------------------
-- Lane Outgress implementation
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LaneOutgress is
    generic(
        -- the bit width of the output port
        DATA_WIDTH : positive;

        -- the number input and output lanes
        NUM_LANES : positive;

        -- the number of this outgress port
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

        -- outgress streaming port
        out_data : out std_ulogic_vector;
        out_last : out std_ulogic;
        out_valid : out std_ulogic;
        out_ready : in std_ulogic
    );
end entity LaneOutgress;

architecture rtl of LaneOutgress is

    constant LANE_DATA_WIDTH : positive := in_lane_data'length/NUM_LANES;
    constant LANE_DEST_WIDTH : positive := in_lane_dest'length/NUM_LANES;
    constant LANE_WIDTH : positive := LANE_DATA_WIDTH + LANE_DEST_WIDTH;

    -- input bus for stream combiner
    signal comb_data : std_ulogic_vector((DATA_WIDTH*NUM_LANES)-1 downto 0);
    signal comb_last : std_ulogic_vector(NUM_LANES-1 downto 0);
    signal comb_valid : std_ulogic_vector(NUM_LANES-1 downto 0);
    signal comb_ready : std_ulogic_vector(NUM_LANES-1 downto 0);

begin

    --------------------------------------------------------------------
    -- split each input lane to the combiner and to the out lane
    --------------------------------------------------------------------
    gen_lane_splitters: for i in 0 to (NUM_LANES-1) generate
        signal enables : std_ulogic_vector(1 downto 0);

        signal split_in_data : std_ulogic_vector(LANE_DATA_WIDTH-1 downto 0);
        signal split_in_dest : std_ulogic_vector(LANE_DEST_WIDTH-1 downto 0);
        signal split_in_both : std_ulogic_vector(LANE_WIDTH-1 downto 0);

        signal split_data : std_ulogic_vector((LANE_WIDTH*2)-1 downto 0);
        signal split_last : std_ulogic_vector(1 downto 0);
        signal split_valid : std_ulogic_vector(1 downto 0);
        signal split_ready : std_ulogic_vector(1 downto 0);
    begin
        splitter: entity work.StreamSplitter
        generic map (
            NUM_OUTPUTS => 2
        )
        port map (
            clk => clk,
            rst => rst,
            enables => enables,
            in_data => split_in_both,
            in_last => in_lane_last(i),
            in_valid => in_lane_valid(i),
            in_ready => in_lane_ready(i),
            out_data => split_data,
            out_last => split_last,
            out_valid => split_valid,
            out_ready => split_ready
        );

        split_in_data <= in_lane_data((LANE_DATA_WIDTH*(i+1))-1 downto LANE_DATA_WIDTH*i);
        split_in_dest <= in_lane_dest((LANE_DEST_WIDTH*(i+1))-1 downto LANE_DEST_WIDTH*i);

        --enables logic
        --TODO this is what we want, but clean it up
        --port 1 enabled when the destination includes this port
        enables(1) <= split_in_dest(2**PORT_NUMBER);
        --remove the enable bit for this port
        split_in_dest(2**PORT_NUMBER) <= '0';
        --port 0 enabled when there is at least one destination remaining
        enables(0) <= '0' when split_in_dest = (split_in_dest'range => '0') else '1';

        split_in_both <= split_in_dest & split_in_data;

        -- assign splitter output 0 to the output lane
        out_lane_data((LANE_DATA_WIDTH*(i+1))-1 downto LANE_DATA_WIDTH*i) <= split_data(LANE_DATA_WIDTH-1 downto 0);
        out_lane_dest((LANE_DEST_WIDTH*(i+1))-1 downto LANE_DEST_WIDTH*i) <= split_data(LANE_WIDTH-1 downto LANE_DATA_WIDTH);
        out_lane_last(i) <= split_last(0);
        out_lane_valid(i) <= split_valid(0);
        split_ready(0) <= out_lane_ready(i);

        -- assign splitter output 1 to the combiner
        comb_data((DATA_WIDTH*(i+1))-1 downto DATA_WIDTH*i) <= split_data((LANE_WIDTH+DATA_WIDTH)-1 downto LANE_WIDTH);
        comb_last(i) <= split_last(1);
        comb_valid(i) <= split_valid(1);
        split_ready(1) <= comb_ready(i);

    end generate gen_lane_splitters;

    --------------------------------------------------------------------
    -- combine all split streams to the output port
    --------------------------------------------------------------------
    combiner: entity work.StreamCombiner
    generic map (
        NUM_INPUTS => NUM_LANES
    )
    port map (
        clk => clk,
        rst => rst,
        in_data => comb_data,
        in_last => comb_last,
        in_valid => comb_valid,
        in_ready => comb_ready,
        out_data => out_data,
        out_last => out_last,
        out_valid => out_valid,
        out_ready => out_ready
    );

end architecture rtl;
