------------------------------------------------------------------------
-- StreamFifo
--
-- Configurable buffering between an input and output stream.
-- SYNC_READ = true uses block ram
-- SYNC_READ = false uses dist ram
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library extras;

entity StreamFifo is
    generic(
        MEM_SIZE           : positive;
        SYNC_READ          : boolean    := true
    );
    port(
        Clock : in std_ulogic;
        Reset : in std_ulogic;

        -- write or input port
        Wr_data : in std_ulogic_vector;
        Wr_valid : in std_ulogic;
        Wr_ready : out std_ulogic;

        -- read or output port
        Rd_data : out std_ulogic_vector;
        Rd_valid : out std_ulogic;
        Rd_ready : in std_ulogic;

        --space and availability
        Almost_empty_thresh : in  natural range 0 to MEM_SIZE-1 := 1;
        Almost_full_thresh  : in  natural range 0 to MEM_SIZE-1 := 1;
        Almost_empty        : out std_ulogic;
        Almost_full         : out std_ulogic
    );
end entity StreamFifo;

architecture rtl of StreamFifo is

    signal Empty : std_ulogic;
    signal Full : std_ulogic;
    signal We : std_ulogic;
    signal Re : std_ulogic;

begin

    Wr_ready <= not Full;
    We <= Wr_valid and not Full;
    Re <= Rd_ready and not Empty;

    process (Clock)
        variable syncValid : std_ulogic := '0';
    begin
        if (SYNC_READ) then
            Rd_valid <= syncValid;
        else
            Rd_valid <= not Empty;
        end if;
        if (rising_edge(Clock)) then
            if (Reset = '1') then
                syncValid := '0';
            else
                syncValid := Re;
            end if;
        end if;
    end process;

    fifo: entity extras.simple_fifo
    generic map (
        MEM_SIZE => MEM_SIZE,
        SYNC_READ => SYNC_READ
    )
    port map (
        Clock => Clock,
        Reset => Reset,

        We => We,
        Wr_data => Wr_data,

        Re => Re,
        Rd_data => Rd_data,

        Empty => Empty,
        Full => Full,

        Almost_empty_thresh => Almost_empty_thresh,
        Almost_full_thresh => Almost_full_thresh,
        Almost_empty => Almost_empty,
        Almost_full => Almost_full
    );
end architecture rtl;
