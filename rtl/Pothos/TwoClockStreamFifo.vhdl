------------------------------------------------------------------------
-- TwoClockStreamFifo
--
-- Copyright (c) 2014-2015 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
--
-- Use this FIFO to move a stream across cross clock domains.
-- In general, this FIFO should be generated with a small memory size.
-- For additional buffering, accompany th cross clock fifo instance
-- with a larger stream FIFO in the appropriate clock domain.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;

entity TwoClockStreamFifo is
    generic(
        MEM_SIZE           : positive   := 16;
        SYNC_READ          : boolean    := false
    );
    port(
        -- input bus
        in_clk : in std_logic;
        in_rst : in std_logic;
        in_data : in std_logic_vector;
        in_valid : in std_logic;
        in_ready : out std_logic;

        -- output bus
        out_clk  : in std_logic;
        out_rst : in std_logic;
        out_data : out std_logic_vector;
        out_valid : out std_logic;
        out_ready : in std_logic
    );
end entity TwoClockStreamFifo;

architecture rtl of TwoClockStreamFifo is

    signal Empty : std_logic;
    signal Full : std_logic;
    signal We : std_logic;
    signal Re : std_logic;
    signal Wr_data : std_ulogic_vector(in_data'range);
    signal Rd_data : std_ulogic_vector(out_data'range);

    signal almost_empty_thresh : natural range 0 to MEM_SIZE-1 := 1;
    signal almost_full_thresh : natural range 0 to MEM_SIZE-1 := 1;
    signal almost_empty : std_logic;
    signal almost_full : std_logic;

    signal ReadOK : std_logic;
    signal LastCycleRead : std_logic;

begin

    --FIXME -- work around, read can happen when it shouldnt -- underlying fifo issue
    --ReadOK <= (not Empty) when (almost_empty = '0') else (not LastCycleRead and not Empty);
    ReadOK <= (not LastCycleRead and not Empty);

    in_ready <= not almost_full;
    We <= in_valid and not almost_full;
    Re <= out_ready and ReadOK;
    Wr_data <= std_ulogic_vector(in_data);
    out_data <= std_logic_vector(Rd_data);

    process (out_clk, ReadOK, Empty, almost_empty)
        variable syncValid : std_logic := '0';
    begin
        if (rising_edge(out_clk)) then
            if (out_rst = '1') then
                syncValid := '0';
            --valid is sticky once high until a transfer occurs
            elsif (syncValid = '0' or (syncValid = '1' and out_ready = '1')) then
                syncValid := Re;
            end if;
            LastCycleRead <= Re;
        end if;
        if (SYNC_READ) then
            out_valid <= syncValid;
        else
            out_valid <= ReadOK;
        end if;
    end process;

    fifo: entity work.fifo
    generic map (
        MEM_SIZE => MEM_SIZE,
        SYNC_READ => SYNC_READ
    )
    port map (
        Wr_Clock => in_clk,
        Wr_Reset => in_rst,

        Rd_Clock => out_clk,
        Rd_Reset => out_rst,

        We => We,
        Wr_data => Wr_data,

        Re => Re,
        Rd_data => Rd_data,

        Empty => Empty,
        Full => Full,

        Almost_empty_thresh => almost_empty_thresh,
        Almost_full_thresh => almost_full_thresh,
        Almost_empty => almost_empty,
        Almost_full => almost_full
    );
end architecture rtl;
