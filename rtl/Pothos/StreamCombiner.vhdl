------------------------------------------------------------------------
-- StreamCombiner
--
-- Combine multiple input streams into one stream.
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity StreamCombiner is
    generic(
        -- the number of input ports
        NUM_INPUTS : positive
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- input buses x NUM_INPUTS
        in_data : in std_ulogic_vector;
        in_last : in std_ulogic_vector(NUM_INPUTS-1 downto 0) := (others => '1');
        in_valid : in std_ulogic_vector(NUM_INPUTS-1 downto 0);
        in_ready : out std_ulogic_vector(NUM_INPUTS-1 downto 0);

        -- output bus
        out_data : out std_ulogic_vector;
        out_last : out std_ulogic;
        out_valid : out std_ulogic;
        out_ready : in std_ulogic
    );
end entity StreamCombiner;

architecture rtl of StreamCombiner is
    constant DATA_WIDTH : positive := in_data'length/NUM_INPUTS;

    --one-hot enables used to determine the input mux
    signal inputEnables : std_ulogic_vector(NUM_INPUTS-1 downto 0);

    --fifo iogress bus signals
    signal out_fifo_data : std_ulogic_vector(DATA_WIDTH downto 0);
    signal in_fifo_data : std_ulogic_vector(DATA_WIDTH downto 0);
    signal in_fifo_valid : std_ulogic;
    signal in_fifo_ready : std_ulogic;
    signal in_fifo_busy : std_ulogic;
begin

    --------------------------------------------------------------------
    -- Create input fifo mux to in_fifo signals
    --------------------------------------------------------------------
    onehot_mux: process (inputEnables, in_valid, in_data, in_last) begin
        for i in 0 to NUM_INPUTS-1 loop
            in_fifo_valid <= in_valid(0);
            in_fifo_data <= in_last(0) & in_data(DATA_WIDTH-1 downto 0);
            if (inputEnables(i) = '1') then
                in_fifo_valid <= in_valid(i);
                in_fifo_data <= in_last(i) & in_data((DATA_WIDTH*(i+1))-1 downto DATA_WIDTH*i);
                exit;
            end if;
        end loop;
    end process onehot_mux;

    ready_mux: for i in 0 to (NUM_INPUTS-1) generate begin
        in_ready(i) <= inputEnables(i) and in_fifo_ready;
    end generate ready_mux;

    --------------------------------------------------------------------
    -- Round robin through input enables
    --------------------------------------------------------------------
    inspect: entity work.StreamInspector
    port map (
        clk => clk,
        rst => rst,
        last => in_fifo_data(DATA_WIDTH),
        valid => in_fifo_valid,
        ready => in_fifo_ready,
        packet_busy => in_fifo_busy
    );

    process (clk)
        variable inputEnablesNext : std_ulogic_vector(NUM_INPUTS downto 0);
    begin

        inputEnablesNext(NUM_INPUTS downto 1) := inputEnables(NUM_INPUTS-1 downto 0);
        inputEnablesNext(0) := inputEnables(NUM_INPUTS-1);

        if (rising_edge(clk)) then
            if (rst = '1') then
                inputEnables <= (others => '0');
                inputEnables(0) <= '1';
            elsif (in_fifo_busy = '0') then
                inputEnables <= inputEnablesNext(NUM_INPUTS-1 downto 0);
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Generate a small outgress fifo
    --------------------------------------------------------------------
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
        in_ready => in_fifo_ready,
        out_data => out_fifo_data,
        out_valid => out_valid,
        out_ready => out_ready
    );

    out_data <= out_fifo_data(DATA_WIDTH-1 downto 0);
    out_last <= out_fifo_data(DATA_WIDTH);

end architecture rtl;
