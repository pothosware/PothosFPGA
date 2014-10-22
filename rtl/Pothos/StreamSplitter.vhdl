------------------------------------------------------------------------
-- StreamSplitter
--
-- Split an input stream to multiple output streams.
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity StreamSplitter is
    generic(
        -- the number of output ports
        NUM_OUTPUTS : positive
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- output enables (which outputs get the input)
        enables : in std_ulogic_vector(NUM_OUTPUTS-1 downto 0) := (others => '1');

        -- input buses
        in_data : in std_ulogic_vector;
        in_last : in std_ulogic;
        in_valid : in std_ulogic;
        in_ready : out std_ulogic;

        -- output bus (num output ports width)
        out_data : out std_ulogic_vector;
        out_last : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_valid : out std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
        out_ready : in std_ulogic_vector(NUM_OUTPUTS-1 downto 0)
    );
end entity StreamSplitter;

architecture rtl of StreamSplitter is

    constant DATA_WIDTH : positive := out_data'length/NUM_OUTPUTS;

    --all ready signals to fifo input stream buses
    signal in_fifo_ready : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);
    signal in_fifo_busy : std_ulogic;

    --enables that are not changed during a packet transfer
    signal usedEnables : std_ulogic_vector(NUM_OUTPUTS-1 downto 0);

    --internal driver for in_ready
    signal in_ready_i : std_ulogic;

begin

    --------------------------------------------------------------------
    -- Create in_ready output signal from enabled ready signals
    --------------------------------------------------------------------
    process begin
        --in ready is a combination of all fifo ready signals on enabled ports
        in_ready_i <= '1';
        for i in 0 to NUM_OUTPUTS-1 loop
            if (usedEnables(i) = '1') then
                in_ready_i <= in_ready_i and in_fifo_ready(i);
            end if;
        end loop;
        in_ready <= in_ready_i;
    end process;

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
        packet_busy => in_fifo_busy
    );

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = '1' or in_fifo_busy = '0') then
                usedEnables <= enables;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Generate small outgress fifos
    --------------------------------------------------------------------
    gen_code_label: for i in 0 to (NUM_OUTPUTS-1) generate
        signal out_fifo_data : std_ulogic_vector(DATA_WIDTH downto 0);
        signal in_fifo_data : std_ulogic_vector(DATA_WIDTH downto 0);
        signal in_fifo_valid : std_ulogic;
    begin

        --input fifo data comes from input last, data
        in_fifo_data(DATA_WIDTH) <= in_last;
        in_fifo_data(DATA_WIDTH-1 downto 0) <= in_data(DATA_WIDTH-1 downto 0);

        --input fifo valid is when the input is valid and output enabled
        in_fifo_valid <= in_valid and usedEnables(i);

        --output fifo data assigned to outout last, data
        out_last(i) <= out_fifo_data(DATA_WIDTH);
        out_data(((i+1)*DATA_WIDTH)-1 downto i*DATA_WIDTH) <= out_fifo_data(DATA_WIDTH-1 downto 0);

        fifo: entity work.StreamFifo
        generic map (
            --configure a small distributed ram
            MEM_SIZE => 2,
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
    end generate;

end architecture rtl;
