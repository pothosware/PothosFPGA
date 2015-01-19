------------------------------------------------------------------------
-- StreamSplitter - Split an input stream to multiple output streams.
--
-- Copyright (c) 2014-2015 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity StreamSplitter is
    generic(
        -- the number of output ports
        NUM_OUTPUTS : positive;

        -- ingress fifo size
        FIFO_SIZE : positive := 4
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- output enables (which outputs get the input)
        enables : in std_logic_vector(NUM_OUTPUTS-1 downto 0) := (others => '1');

        -- input buses
        in_data : in std_logic_vector;
        in_last : in std_logic := '1';
        in_valid : in std_logic;
        in_ready : out std_logic;

        -- output bus x NUM_OUTPUTS
        out_data : out std_logic_vector;
        out_last : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
        out_valid : out std_logic_vector(NUM_OUTPUTS-1 downto 0);
        out_ready : in std_logic_vector(NUM_OUTPUTS-1 downto 0)
    );
end entity StreamSplitter;

architecture rtl of StreamSplitter is

    constant DATA_WIDTH : positive := out_data'length/NUM_OUTPUTS;

    --all ready signals to fifo input stream buses
    signal in_fifo_ready : std_logic_vector(NUM_OUTPUTS-1 downto 0);
    signal in_fifo_begin : std_logic;

    --enables that are not changed during a packet transfer
    signal usedEnables : std_logic_vector(NUM_OUTPUTS-1 downto 0);
    signal cachedEnables : std_logic_vector(NUM_OUTPUTS-1 downto 0);

    --internal driver for in_ready
    signal in_ready_i : std_logic;

begin

    assert (DATA_WIDTH = in_data'length) report "StreamSplitter: in data width" severity failure;

    --------------------------------------------------------------------
    -- Create in_ready output signal from enabled ready signals
    --------------------------------------------------------------------
    --in ready is a combination of all fifo ready signals on enabled ports
    in_ready_i <= '1' when (usedEnables and in_fifo_ready) = usedEnables else '0';
    in_ready <= in_ready_i;

    --------------------------------------------------------------------
    -- Maintain packet-safe up-to-date copy of enables
    --------------------------------------------------------------------
    inspect: entity work.StreamInspector
    port map (
        clk => clk,
        rst => rst,
        last => in_last,
        valid => in_valid,
        ready => in_ready_i,
        packet_begin => in_fifo_begin
    );

    usedEnables <= enables when (in_fifo_begin = '1') else cachedEnables;

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                cachedEnables <= (others => '0');
            elsif (in_fifo_begin = '1') then
                cachedEnables <= enables;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Generate small outgress fifos
    --------------------------------------------------------------------
    gen_fifos: for i in 0 to (NUM_OUTPUTS-1) generate
        signal out_fifo_data : std_logic_vector(DATA_WIDTH downto 0);
        signal in_fifo_data : std_logic_vector(DATA_WIDTH downto 0);
        signal in_fifo_valid : std_logic;
    begin

        --input fifo data comes from input last, data
        in_fifo_data <= in_last & in_data(DATA_WIDTH-1 downto 0);

        --input fifo valid is when the input is valid and output enabled
        --and *all* destination fifos are ready to accept transfers
        in_fifo_valid <= in_valid and usedEnables(i) and in_ready_i;

        --output fifo data assigned to outout last, data
        out_last(i) <= out_fifo_data(DATA_WIDTH);
        out_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH) <= out_fifo_data(DATA_WIDTH-1 downto 0);

        fifo: entity work.StreamFifo
        generic map (
            --configure a small distributed ram
            MEM_SIZE => FIFO_SIZE,
            SYNC_READ => false
        )
        port map (
            clk => clk,
            rst => rst,
            in_data => in_fifo_data,
            in_valid => in_fifo_valid,
            in_ready => in_fifo_ready(i),
            out_data => out_fifo_data,
            out_valid => out_valid(i),
            out_ready => out_ready(i)
        );
    end generate gen_fifos;

end architecture rtl;
