------------------------------------------------------------------------
-- Lane Ingress implementation
--
-- Copyright (c) 2014-2015 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
--
-- A lane ingress attaches to a multi-lane busway,
-- and combines an input stream onto the busway based on an enable mask.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LaneIngress is
    generic(
        -- buffer depth for lane entry and exit
        FIFO_SIZE : positive := 4
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        --dest enables for splitter
        --each enable maps to a lane
        lane_mask : in std_logic_vector;

        --dest bus per each lane
        --each dest is num out ports wide
        --[destN-1.., dest1, dest0]
        egress_masks : in std_logic_vector;

        --lanes in x NUM_LANES
        in_lane_dest : in std_logic_vector;
        in_lane_data : in std_logic_vector;
        in_lane_last : in std_logic_vector;
        in_lane_valid : in std_logic_vector;
        in_lane_ready : out std_logic_vector;

        --lanes out x NUM_LANES
        out_lane_dest : out std_logic_vector;
        out_lane_data : out std_logic_vector;
        out_lane_last : out std_logic_vector;
        out_lane_valid : out std_logic_vector;
        out_lane_ready : in std_logic_vector;

        -- ingress streaming port
        in_data : in std_logic_vector;
        in_last : in std_logic;
        in_valid : in std_logic;
        in_ready : out std_logic
    );
end entity LaneIngress;

architecture rtl of LaneIngress is

    -- calculate constants from input widths
    constant NUM_LANES : positive := in_lane_valid'length;
    constant DATA_WIDTH : positive := in_lane_data'length/NUM_LANES;
    constant DEST_WIDTH : positive := in_lane_dest'length/NUM_LANES;
    constant LANE_WIDTH : positive := DATA_WIDTH + DEST_WIDTH;

    -- splitter output
    signal split_data : std_logic_vector((NUM_LANES*DATA_WIDTH)-1 downto 0);
    signal split_last : std_logic_vector(NUM_LANES-1 downto 0);
    signal split_valid : std_logic_vector(NUM_LANES-1 downto 0);
    signal split_ready : std_logic_vector(NUM_LANES-1 downto 0);

begin

    assert (NUM_LANES*DEST_WIDTH = in_lane_dest'length) report "LaneIngress: in lane dest width" severity failure;
    assert (NUM_LANES*DATA_WIDTH = in_lane_data'length) report "LaneIngress: in lane dest width" severity failure;
    assert (NUM_LANES = in_lane_last'length) report "LaneIngress: in lane last width" severity failure;
    assert (NUM_LANES = in_lane_valid'length) report "LaneIngress: in lane valid width" severity failure;
    assert (NUM_LANES = in_lane_ready'length) report "LaneIngress: in lane ready width" severity failure;

    assert (NUM_LANES*DEST_WIDTH = out_lane_dest'length) report "LaneIngress: out lane dest width" severity failure;
    assert (NUM_LANES*DATA_WIDTH = out_lane_data'length) report "LaneIngress: out lane dest width" severity failure;
    assert (NUM_LANES = out_lane_last'length) report "LaneIngress: out lane last width" severity failure;
    assert (NUM_LANES = out_lane_valid'length) report "LaneIngress: out lane valid width" severity failure;
    assert (NUM_LANES = out_lane_ready'length) report "LaneIngress: out lane ready width" severity failure;

    assert (NUM_LANES*DEST_WIDTH = egress_masks'length) report "LaneIngress: egress masks width" severity failure;
    assert (NUM_LANES = lane_mask'length) report "LaneIngress: lane mask width" severity failure;
    assert (DATA_WIDTH = in_data'length) report "LaneIngress: in data width" severity failure;

    --------------------------------------------------------------------
    -- split the input port to each lane
    --------------------------------------------------------------------
    splitter: entity work.StreamSplitter
    generic map (
        NUM_OUTPUTS => NUM_LANES,
        FIFO_SIZE => FIFO_SIZE
    )
    port map (
        clk => clk,
        rst => rst,
        enables => lane_mask,
        in_data => in_data,
        in_last => in_last,
        in_valid => in_valid,
        in_ready => in_ready,
        out_data => split_data,
        out_last => split_last,
        out_valid => split_valid,
        out_ready => split_ready
    );

    --------------------------------------------------------------------
    -- combine each split output with a lane
    --------------------------------------------------------------------
    gen_lane_combiners: for i in 0 to (NUM_LANES-1) generate

        signal comb_in_data : std_logic_vector((LANE_WIDTH*2)-1 downto 0);
        signal comb_in_last : std_logic_vector(1 downto 0);
        signal comb_in_valid : std_logic_vector(1 downto 0);
        signal comb_in_ready : std_logic_vector(1 downto 0);
        signal comb_out_data : std_logic_vector(LANE_WIDTH-1 downto 0);

    begin
        combiner: entity work.StreamCombiner
        generic map (
            NUM_INPUTS => 2,
            FIFO_SIZE => FIFO_SIZE
        )
        port map (
            clk => clk,
            rst => rst,
            in_data => comb_in_data,
            in_last => comb_in_last,
            in_valid => comb_in_valid,
            in_ready => comb_in_ready,
            out_data => comb_out_data,
            out_last => out_lane_last(i),
            out_valid => out_lane_valid(i),
            out_ready => out_lane_ready(i)
        );

        --assign splitter to combiner input 0
        --assign input lane to combiner input 1
        comb_in_data <=
            in_lane_dest(((i+1)*DEST_WIDTH)-1 downto i*DEST_WIDTH) &
            in_lane_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH) &
            egress_masks(((i+1)*DEST_WIDTH)-1 downto i*DEST_WIDTH) &
            split_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH);
        comb_in_last <= in_lane_last(i) & split_last(i);
        comb_in_valid <= in_lane_valid(i) & split_valid(i);
        split_ready(i) <= comb_in_ready(0);
        in_lane_ready(i) <= comb_in_ready(1);

        --output data and dest from combined bus
        out_lane_dest(((i+1)*DEST_WIDTH)-1 downto i*DEST_WIDTH) <= comb_out_data(DEST_WIDTH+DATA_WIDTH-1 downto DATA_WIDTH);
        out_lane_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH) <= comb_out_data(DATA_WIDTH-1 downto 0);

    end generate gen_lane_combiners;

end architecture rtl;
