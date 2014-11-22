------------------------------------------------------------------------
-- Interconnect implementation
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
--
-- The interconnect is a configurable stream delivery engine.
-- The interface is composed of a configuration bus
-- and an arbitrary number of input and output ports.
--
-- About lanes:
-- The interconnect delivers data from input ports to output ports
-- using the configurable lane-structures inside the interconnect.
-- Each lane is muxed with the available input and output ports.
-- The flow of data through the lanes is dynamically configurable.
-- Users can control how many lanes are synthesized and how lanes
-- are allotted to the available ports to optimize resource usage.
--
-- The configuration bus:
-- This is a very simple APB3 bus for settings and configuration.
-- The interconnect is receptive to configuration reads and writes
-- at specific addresses specified by InterconnectPkg IC_* constants.
--
-- The interconnect inputs:
-- This is an NUM_INPUTS wide input bus following the streaming convention.
-- For the 1-bit control signals, the bit index corresponds to the port index.
-- The data bus is DATA_WIDTH*NUM_INPUTS wide, where the lowest DATA_WIDTH bits
-- corresponds to input port 0, and increase linearly by DATA_WIDTH per port.
--
-- The interconnect outputs:
-- This is an NUM_OUTPUTS wide input bus following the streaming convention.
-- For the 1-bit control signals, the bit index corresponds to the port index.
-- The data bus is DATA_WIDTH*NUM_OUTPUTS wide, where the lowest DATA_WIDTH bits
-- corresponds to output port 0, and increase linearly by DATA_WIDTH per port.
--
-- The begin signals:
-- The begin signals are a form of flow control for packet-based flows.
-- Ports that do not work with packets should simply ignore this signal.
-- The general idea is that input ports should not release packets into
-- the interconnect until all destinations can accept the entire packet.
--
-- For flow-through blocks that can consume and produce at full-bus rate,
-- simply connect begin from the output to begin from the input bus to say:
-- "I can accept a packet when my destinations can accept a packet."
-- For blocks that must fully buffer an entire packet before processing,
-- use the input FIFO's space available count to drive the begin signal.
--
-- The begin signals implementation:
-- The driver of the begin signal should always use this signal
-- as a boolean value to indicate when the destination can accept
-- an entire packet transfer. Its understood that the begin signal
-- may become low once a transfer begins to fill up the buffer.
-- And therefore, this signal is only valid at the start of a packet.
-- Internally, the combined destination begin signals gate the flow
-- from the input ports of the interconnect using the ready signals.
-- Therefore, implementations should still use the bus ready signal
-- to determine when to initiate flow into the interconnect.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use interconnect configuration constants
library PothosInterconnect;
use PothosInterconnect.InterconnectPkg.all;

entity Interconnect is
    generic(

        -- the number of input ports
        NUM_INPUTS : positive;

        -- the number of output ports
        NUM_OUTPUTS : positive;

        -- The number of internal lanes to generate:
        -- Additional lanes provide dedicated paths of data flow
        -- at the expense of increasing resource utilization.
        NUM_LANES : positive;

        -- Buffer depth for lane entry and exit:
        -- Small buffers are used within the interconnect to ease timing,
        -- and to prevent minor contention within the lane in/outgress.
        FIFO_SIZE : positive := 4

        -- high bandwidth ports for performance hints
        -- each bit represents a port by index number
        -- TODO, these will be used to generate muxing with non0 lanes
        --HIGH_BW_INS : std_ulogic_vector;
        --HIGH_BW_OUTS : std_ulogic_vector
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- configuration channel
        paddr : in std_ulogic_vector(31 downto 0);
        psel : in std_ulogic;
        penable : in std_ulogic;
        pwrite : in std_ulogic;
        pwdata : in std_ulogic_vector(31 downto 0);
        pready : out std_ulogic;
        prdata : out std_ulogic_vector(31 downto 0);

        -- all ports into the interconnect
        in_data : in std_ulogic_vector;
        in_meta : in std_ulogic_vector(NUM_INPUTS-1 downto 0) := (others => '0');
        in_last : in std_ulogic_vector(NUM_INPUTS-1 downto 0) := (others => '1');
        in_valid : in std_ulogic_vector(NUM_INPUTS-1 downto 0);
        in_ready : out std_ulogic_vector(NUM_INPUTS-1 downto 0);
        in_begin : out std_ulogic_vector(NUM_INPUTS-1 downto 0);

        -- all ports out from the interconnect
        out_data : out std_ulogic_vector;
        out_meta : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_last : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_valid : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_ready : in std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_begin : in std_ulogic_vector(NUM_OUTPUTS-1 downto 0) := (others => '1')
    );
end entity Interconnect;

architecture rtl of Interconnect is

    constant NUM_PORTS : positive := NUM_INPUTS + NUM_OUTPUTS;
    constant DATA_WIDTH : positive := in_data'length/NUM_INPUTS;

    --selection registers set by the config bus
    signal paddr_num : natural;
    signal test_loopback_reg : std_ulogic_vector(31 downto 0);
    signal lane_select_reg : natural range 0 to NUM_LANES-1;
    signal input_select_reg : natural range 0 to NUM_INPUTS-1;

    --multi lane bus data types:
    --Each array element is a streaming bus between iogress blocks.
    --Notice the extra bus (NUM_PORTS + 1) which is for convenience
    --We connect streaming NUM_PORTS to 0 to connect the loop.
    type lanes_dest_type is array(0 to NUM_PORTS) of std_ulogic_vector((NUM_LANES*NUM_OUTPUTS)-1 downto 0);
    type lanes_data_type is array(0 to NUM_PORTS) of std_ulogic_vector((NUM_LANES*(DATA_WIDTH+1))-1 downto 0); --(data + meta) x NUM_LANES
    type lanes_last_type is array(0 to NUM_PORTS) of std_ulogic_vector(NUM_LANES-1 downto 0);
    type lanes_valid_type is array(0 to NUM_PORTS) of std_ulogic_vector(NUM_LANES-1 downto 0);
    type lanes_ready_type is array(0 to NUM_PORTS) of std_ulogic_vector(NUM_LANES-1 downto 0);

    --multi lane connections:
    signal lane_dest : lanes_dest_type;
    signal lane_data : lanes_data_type;
    signal lane_last : lanes_last_type;
    signal lane_valid : lanes_valid_type;
    signal lane_ready : lanes_ready_type;

begin

    assert (NUM_INPUTS*DATA_WIDTH = in_data'length) report "Interconnect: in data width" severity failure;
    assert (NUM_OUTPUTS*DATA_WIDTH = out_data'length) report "Interconnect: out data width" severity failure;

    assert (NUM_INPUTS <= 32) report "Interconnect: 32 inputs limit" severity failure;
    assert (NUM_OUTPUTS <= 32) report "Interconnect: 32 outputs limit" severity failure;
    assert (NUM_LANES <= 32) report "Interconnect: 32 lanes limit" severity failure;

    --------------------------------------------------------------------
    -- configuration readback mux
    --------------------------------------------------------------------
    paddr_num <= to_integer(unsigned(paddr));
    prdata <=
        std_ulogic_vector(to_unsigned(IC_VERSION, 32)) when (paddr_num = IC_VERSION_ADDR) else
        std_ulogic_vector(to_unsigned(NUM_LANES, 32)) when (paddr_num = IC_NUM_LANES_ADDR) else
        std_ulogic_vector(to_unsigned(NUM_INPUTS, 32)) when (paddr_num = IC_NUM_INPUTS_ADDR) else
        std_ulogic_vector(to_unsigned(NUM_OUTPUTS, 32)) when (paddr_num = IC_NUM_OUTPUTS_ADDR) else
        test_loopback_reg when (paddr_num = IC_TEST_LOOPBACK_ADDR) else (others => '0');
    pready <= penable;

    --------------------------------------------------------------------
    -- record configuration selections
    --------------------------------------------------------------------
    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                test_loopback_reg <= (others => '0');
                lane_select_reg <= 0;
                input_select_reg <= 0;
            elsif (pwrite = '1' and psel = '1') then
                if (paddr_num = IC_TEST_LOOPBACK_ADDR) then
                    test_loopback_reg <= pwdata;
                elsif (paddr_num = IC_LANE_SELECT_ADDR) then
                    lane_select_reg <= to_integer(unsigned(pwdata));
                elsif (paddr_num = IC_INPUT_SELECT_ADDR) then
                    input_select_reg <= to_integer(unsigned(pwdata));
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- generate ingress blocks for each input port
    --------------------------------------------------------------------
    gen_lane_ingress: for i in 0 to (NUM_INPUTS-1) generate

        --configuration registers
        signal lane_mask : std_ulogic_vector(NUM_LANES-1 downto 0);
        signal flow_mask : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        signal egress_masks : std_ulogic_vector((NUM_OUTPUTS*NUM_LANES)-1 downto 0);

        --valve input data
        signal in_data_i : std_ulogic_vector(DATA_WIDTH downto 0);
        signal in_begin_i : std_ulogic;

        --bus inbetween valve and lane ingress
        signal valve_data : std_ulogic_vector(DATA_WIDTH downto 0);
        signal valve_last : std_ulogic;
        signal valve_valid : std_ulogic;
        signal valve_ready : std_ulogic;
    begin

        --record configuration selections into lane and output masks
        process (clk) begin
            if (rising_edge(clk)) then
                if (rst = '1') then
                    lane_mask <= (others => '0');
                    flow_mask <= (others => '0');
                    egress_masks <= (others => '0');
                elsif (pwrite = '1' and psel = '1' and i = input_select_reg) then
                    if (paddr_num = IC_LANE_DEST_MASK_ADDR) then
                        lane_mask <= pwdata(lane_mask'range);
                    elsif (paddr_num = IC_OUTPUT_FLOW_MASK_ADDR) then
                        flow_mask <= pwdata(flow_mask'range);
                    elsif (paddr_num = IC_OUTPUT_DEST_MASK_ADDR) then
                        for j in 0 to NUM_LANES-1 loop
                            if (j = lane_select_reg) then
                                egress_masks(((j+1)*NUM_OUTPUTS)-1 downto j*NUM_OUTPUTS) <= pwdata(NUM_OUTPUTS-1 downto 0);
                            end if;
                        end loop;
                    end if;
                end if;
            end if;
        end process;

        --Generate the begin signal:
        --The begin signal is intentionally delayed by register cycles
        --to ease combinatorial paths on input and output begin signals.
        --The delay is acceptable because the destination buffers are deeper.
        process (clk)
            variable out_begin_r : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        begin
            if (rising_edge(clk)) then
                out_begin_r := out_begin;
                if (rst = '1') then
                    in_begin_i <= '0';
                -- are all bits in the flow mask set in the begin signal?
                elsif ((flow_mask and out_begin_r) = flow_mask) then
                    in_begin_i <= '1';
                else
                    in_begin_i <= '0';
                end if;
            end if;
        end process;
        in_begin(i) <= in_begin_i;

        ingress: entity work.LaneIngress
        generic map (
            FIFO_SIZE => FIFO_SIZE
        )
        port map (
            clk => clk,
            rst => rst,

            lane_mask => lane_mask,
            egress_masks => egress_masks,

            in_lane_dest => lane_dest(i),
            in_lane_data => lane_data(i),
            in_lane_last => lane_last(i),
            in_lane_valid => lane_valid(i),
            in_lane_ready => lane_ready(i),

            out_lane_dest => lane_dest(i+1),
            out_lane_data => lane_data(i+1),
            out_lane_last => lane_last(i+1),
            out_lane_valid => lane_valid(i+1),
            out_lane_ready => lane_ready(i+1),

            in_data => valve_data,
            in_last => valve_last,
            in_valid => valve_valid,
            in_ready => valve_ready
        );

        valve : entity work.StreamValve
        port map (
            clk => clk,
            rst => rst,

            forward => in_begin_i,

            in_data => in_data_i,
            in_last => in_last(i),
            in_valid => in_valid(i),
            in_ready => in_ready(i),

            out_data => valve_data,
            out_last => valve_last,
            out_valid => valve_valid,
            out_ready => valve_ready
        );

        --combine meta and data into the input data bus
        in_data_i <= in_meta(i) & in_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH);

    end generate gen_lane_ingress;

    --------------------------------------------------------------------
    -- generate outgress blocks for each output port
    --------------------------------------------------------------------
    gen_lane_outgress: for i in 0 to (NUM_OUTPUTS-1) generate
        signal out_data_i : std_ulogic_vector(DATA_WIDTH downto 0);
    begin

        outgress: entity work.LaneOutgress
        generic map (
            PORT_NUMBER => i,
            FIFO_SIZE => FIFO_SIZE
        )
        port map (
            clk => clk,
            rst => rst,

            in_lane_dest => lane_dest(NUM_INPUTS+i),
            in_lane_data => lane_data(NUM_INPUTS+i),
            in_lane_last => lane_last(NUM_INPUTS+i),
            in_lane_valid => lane_valid(NUM_INPUTS+i),
            in_lane_ready => lane_ready(NUM_INPUTS+i),

            out_lane_dest => lane_dest(NUM_INPUTS+i+1),
            out_lane_data => lane_data(NUM_INPUTS+i+1),
            out_lane_last => lane_last(NUM_INPUTS+i+1),
            out_lane_valid => lane_valid(NUM_INPUTS+i+1),
            out_lane_ready => lane_ready(NUM_INPUTS+i+1),

            out_data => out_data_i,
            out_last => out_last(i),
            out_valid => out_valid(i),
            out_ready => out_ready(i)
        );

        --split the output data bus to meta and data
        out_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH) <= out_data_i(DATA_WIDTH-1 downto 0);
        out_meta(i) <= out_data_i(DATA_WIDTH);

    end generate gen_lane_outgress;

    --------------------------------------------------------------------
    -- connect lane end to lane start to complete the loop
    --------------------------------------------------------------------
    lane_dest(0) <= lane_dest(NUM_PORTS);
    lane_data(0) <= lane_data(NUM_PORTS);
    lane_last(0) <= lane_last(NUM_PORTS);
    lane_valid(0) <= lane_valid(NUM_PORTS);
    lane_ready(NUM_PORTS) <= lane_ready(0);

end architecture rtl;
