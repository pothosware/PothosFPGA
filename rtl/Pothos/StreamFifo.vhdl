------------------------------------------------------------------------
-- StreamFifo
--
-- Copyright (c) 2014-2014 Josh Blum
-- SPDX-License-Identifier: BSL-1.0
--
-- Configurable buffering between an input and output stream.
-- See vhdl-extras simple_fifo for additional documentation.
-- SYNC_READ = true uses block ram
-- SYNC_READ = false uses dist ram
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;

entity StreamFifo is
    generic(
        MEM_SIZE           : positive;
        SYNC_READ          : boolean    := true
    );
    port(
        clk : in std_ulogic;
        rst : in std_ulogic;

        -- input bus
        in_data : in std_ulogic_vector;
        in_valid : in std_ulogic;
        in_ready : out std_ulogic;

        -- output bus
        out_data : out std_ulogic_vector;
        out_valid : out std_ulogic;
        out_ready : in std_ulogic;

        --space and availability
        almost_empty_thresh : in  natural range 0 to MEM_SIZE-1 := 1;
        almost_full_thresh  : in  natural range 0 to MEM_SIZE-1 := 1;
        almost_empty        : out std_ulogic;
        almost_full         : out std_ulogic
    );
end entity StreamFifo;

architecture rtl of StreamFifo is

    signal Empty : std_ulogic;
    signal Full : std_ulogic;
    signal We : std_ulogic;
    signal Re : std_ulogic;

begin

    in_ready <= not Full;
    We <= in_valid and not Full;
    Re <= out_ready and not Empty;

    process (clk, Empty)
        variable syncValid : std_ulogic := '0';
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                syncValid := '0';
            else
                syncValid := Re;
            end if;
        end if;
        if (SYNC_READ) then
            out_valid <= syncValid;
        else
            out_valid <= not Empty;
        end if;
    end process;

    fifo: entity work.simple_fifo
    generic map (
        MEM_SIZE => MEM_SIZE,
        SYNC_READ => SYNC_READ
    )
    port map (
        Clock => clk,
        Reset => rst,

        We => We,
        Wr_data => in_data,

        Re => Re,
        Rd_data => out_data,

        Empty => Empty,
        Full => Full,

        Almost_empty_thresh => almost_empty_thresh,
        Almost_full_thresh => almost_full_thresh,
        Almost_empty => almost_empty,
        Almost_full => almost_full
    );
end architecture rtl;
