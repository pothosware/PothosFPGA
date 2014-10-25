------------------------------------------------------------------------
-- Lane Outgress implementation
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LaneOutgress is
    generic(
        -- the number of this outgress port
        PORT_NUMBER : natural
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        --lanes in x NUM_LANES
        in_lane_dest : in std_ulogic_vector;
        in_lane_data : in std_ulogic_vector;
        in_lane_last : in std_ulogic_vector;
        in_lane_valid : in std_ulogic_vector;
        in_lane_ready : out std_ulogic_vector;

        --lanes out x NUM_LANES
        out_lane_dest : out std_ulogic_vector;
        out_lane_data : out std_ulogic_vector;
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

    -- calculate constants from input widths
    constant NUM_LANES : positive := in_lane_valid'length;
    constant DATA_WIDTH : positive := in_lane_data'length/NUM_LANES;
    constant DEST_WIDTH : positive := in_lane_dest'length/NUM_LANES;
    constant LANE_WIDTH : positive := DATA_WIDTH + DEST_WIDTH;
    constant ENABLE_BIT : natural := 2**PORT_NUMBER;

    -- input bus for stream combiner
    signal comb_data : std_ulogic_vector((DATA_WIDTH*NUM_LANES)-1 downto 0);
    signal comb_last : std_ulogic_vector(NUM_LANES-1 downto 0);
    signal comb_valid : std_ulogic_vector(NUM_LANES-1 downto 0);
    signal comb_ready : std_ulogic_vector(NUM_LANES-1 downto 0);

begin

    assert (DATA_WIDTH*NUM_LANES = out_lane_data'length) report "LaneOutgress: out lane data width" severity failure;
    assert (DEST_WIDTH*NUM_LANES = out_lane_dest'length) report "LaneOutgress: out lane dest width" severity failure;
    assert (DATA_WIDTH = out_data'length) report "LaneOutgress: out data width" severity failure;

    --------------------------------------------------------------------
    -- split each input lane to the combiner and to the out lane
    --------------------------------------------------------------------
    gen_lane_splitters: for i in 0 to (NUM_LANES-1) generate
        signal enables : std_ulogic_vector(1 downto 0);

        signal split_in_data : std_ulogic_vector(DATA_WIDTH-1 downto 0);
        signal split_in_dest : std_ulogic_vector(DEST_WIDTH-1 downto 0);
        signal dest_removed : std_ulogic_vector(DEST_WIDTH-1 downto 0);
        signal split_in_both : std_ulogic_vector(LANE_WIDTH-1 downto 0);

        signal split_out_both : std_ulogic_vector((LANE_WIDTH*2)-1 downto 0);
        signal split_out_last : std_ulogic_vector(1 downto 0);
        signal split_out_valid : std_ulogic_vector(1 downto 0);
        signal split_out_ready : std_ulogic_vector(1 downto 0);
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
            out_data => split_out_both,
            out_last => split_out_last,
            out_valid => split_out_valid,
            out_ready => split_out_ready
        );

        --extract input data(i) and input dest(i)
        --clear out "our" enable bit from input dest
        split_in_dest <= in_lane_dest((DEST_WIDTH*(i+1))-1 downto DEST_WIDTH*i);
        split_in_data <= in_lane_data((DATA_WIDTH*(i+1))-1 downto DATA_WIDTH*i);
        dest_removed <= split_in_dest;
        dest_removed(ENABLE_BIT) <= '0'; --remove the enable bit for this port
        split_in_both <= dest_removed & split_in_data;

        --enables logic
        --port 1 enabled when the destination includes this port
        --port 0 enabled when there is at least one destination remaining
        enables(1) <= split_in_dest(ENABLE_BIT);
        enables(0) <= '0' when dest_removed = (dest_removed'range => '0') else '1';

        -- assign splitter output 0 to the output lane
        out_lane_dest((DEST_WIDTH*(i+1))-1 downto DEST_WIDTH*i) <= split_out_both(LANE_WIDTH-1 downto DATA_WIDTH);
        out_lane_data((DATA_WIDTH*(i+1))-1 downto DATA_WIDTH*i) <= split_out_both(DATA_WIDTH-1 downto 0);
        out_lane_last(i) <= split_out_last(0);
        out_lane_valid(i) <= split_out_valid(0);
        split_out_ready(0) <= out_lane_ready(i);

        -- assign splitter output 1 to the combiner
        comb_data((DATA_WIDTH*(i+1))-1 downto DATA_WIDTH*i) <= split_out_both((LANE_WIDTH+DATA_WIDTH)-1 downto LANE_WIDTH);
        comb_last(i) <= split_out_last(1);
        comb_valid(i) <= split_out_valid(1);
        split_out_ready(1) <= comb_ready(i);

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
