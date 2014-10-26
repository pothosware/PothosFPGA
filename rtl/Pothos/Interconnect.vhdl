------------------------------------------------------------------------
-- Interconnect implementation
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
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

        -- the number of internal lanes to generate
        NUM_LANES : positive

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
        config_write : in std_ulogic;
        config_read : in std_ulogic;
        config_addr : in std_ulogic_vector(31 downto 0);
        config_in_data : in std_ulogic_vector(31 downto 0);
        config_out_data : out std_ulogic_vector(31 downto 0);

        -- all ports into the interconnect
        in_data : in std_ulogic_vector;
        in_meta : in std_ulogic_vector(NUM_INPUTS-1 downto 0);
        in_last : in std_ulogic_vector(NUM_INPUTS-1 downto 0);
        in_valid : in std_ulogic_vector(NUM_INPUTS-1 downto 0);
        in_ready : out std_ulogic_vector(NUM_INPUTS-1 downto 0);

        -- all ports out from the interconnect
        out_data : out std_ulogic_vector;
        out_meta : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_last : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_valid : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_ready : in std_ulogic_vector(NUM_OUTPUTS-1 downto 0)
    );
end entity Interconnect;

architecture rtl of Interconnect is

    constant NUM_PORTS : positive := NUM_INPUTS + NUM_OUTPUTS;
    constant DATA_WIDTH : positive := in_data'length/NUM_INPUTS;

    --selection registers set by the config bus
    signal config_addr_num : natural;
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
    config_addr_num <= to_integer(unsigned(config_addr));
    config_out_data <=
        std_ulogic_vector(to_unsigned(NUM_LANES, 32)) when (config_addr_num = IC_NUM_LANES_ADDR) else
        std_ulogic_vector(to_unsigned(NUM_INPUTS, 32)) when (config_addr_num = IC_NUM_INPUTS_ADDR) else
        std_ulogic_vector(to_unsigned(NUM_OUTPUTS, 32)) when (config_addr_num = IC_NUM_OUTPUTS_ADDR) else
        test_loopback_reg when (config_addr_num = IC_TEST_LOOPBACK_ADDR) else (others => '0');

    --------------------------------------------------------------------
    -- record configuration selections
    --------------------------------------------------------------------
    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                test_loopback_reg <= (others => '0');
                lane_select_reg <= 0;
                input_select_reg <= 0;
            elsif (config_write = '1') then
                if (config_addr_num = IC_TEST_LOOPBACK_ADDR) then
                    test_loopback_reg <= config_in_data;
                elsif (config_addr_num = IC_LANE_SELECT_ADDR) then
                    lane_select_reg <= to_integer(unsigned(config_in_data));
                elsif (config_addr_num = IC_INPUT_SELECT_ADDR) then
                    input_select_reg <= to_integer(unsigned(config_in_data));
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- generate ingress blocks for each input port
    --------------------------------------------------------------------
    gen_lane_ingress: for i in 0 to (NUM_INPUTS-1) generate
        signal lane_mask : std_ulogic_vector(NUM_LANES-1 downto 0);
        signal egress_masks : std_ulogic_vector((NUM_OUTPUTS*NUM_LANES)-1 downto 0);
        signal in_data_i : std_ulogic_vector(DATA_WIDTH downto 0);
    begin

        --record configuration selections into lane and output masks
        process (clk) begin
            if (rising_edge(clk)) then
                if (rst = '1') then
                    lane_mask <= (others => '0');
                    egress_masks <= (others => '0');
                elsif (config_write = '1' and i = input_select_reg) then
                    if (config_addr_num = IC_LANE_DEST_MASK_ADDR) then
                        lane_mask <= config_in_data(NUM_LANES-1 downto 0);
                    elsif (config_addr_num = IC_OUTPUT_DEST_MASK_ADDR) then
                        for j in 0 to NUM_LANES-1 loop
                            if (j = lane_select_reg) then
                                egress_masks(((j+1)*NUM_OUTPUTS)-1 downto j*NUM_OUTPUTS) <= config_in_data(NUM_OUTPUTS-1 downto 0);
                            end if;
                        end loop;
                    end if;
                end if;
            end if;
        end process;

        ingress: entity work.LaneIngress
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

            in_data => in_data_i,
            in_last => in_last(i),
            in_valid => in_valid(i),
            in_ready => in_ready(i)
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
            PORT_NUMBER => i
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
