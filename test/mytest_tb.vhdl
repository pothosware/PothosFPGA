package math is
       function myfoobar (v : real) return real;
       attribute foreign of myfoobar : function is "VHPIDIRECT myfoobar";
     end math;
     
     package body math is
       function myfoobar (v : real) return real is
       begin
         assert false severity failure;
       end myfoobar;
     end math;

library work;
use work.math.all;

------------------------------------------------------------------------------
--  TEST BENCH
------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    --use ieee.std_logic_unsigned.all;
    --use ieee.std_logic_textio.all;
    use std.textio.all;

entity mytest_tb is
end entity mytest_tb;
architecture test of mytest_tb is

    signal clk    :std_logic := '0';
    signal rst    :std_logic := '1';

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 3 ns;

    -- Display the time and result
    process (clk)
        variable wrbuf :line;
        variable num :real;
    begin
        if (clk = '1') then
            num := myfoobar(1.5707963267948966);
            write(wrbuf, num);
            write(wrbuf, string'("  Time: "));
            write(wrbuf, now);
            writeline(output, wrbuf);
        end if;
    end process;

end architecture;
