package testerz is
    function myfoobar (v : real) return real;
    attribute foreign of myfoobar : function is "VHPIDIRECT myfoobar";

    function testCharType (v : character) return integer;
    attribute foreign of testCharType : function is "VHPIDIRECT testCharType";

    function testBoolType (v : boolean) return integer;
    attribute foreign of testBoolType : function is "VHPIDIRECT testBoolType";

    function testStrType (v : string) return integer; --nope
    attribute foreign of testStrType : function is "VHPIDIRECT testStrType"; --nope
end testerz;

package body testerz is
    function myfoobar (v : real) return real is begin
    end myfoobar;

    function testCharType (v : character) return integer is begin
    end testCharType;

    function testBoolType (v : boolean) return integer is begin
    end testBoolType;

    function testStrType (v : string) return integer is begin --nope
    end testStrType; --nope
end testerz;

library work;
use work.testerz.all;

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
    SIGNAL stringName : STRING (1 to 5) := "START";

begin

    -- Generate clock
    clk <= not clk after 10 ns;
    rst <= '0' after 3 ns;

    -- Display the time and result
    process (clk)
        variable wrbuf :line;
        variable num :real;
        variable numInt :integer;
    begin
        if (clk = '1') then
            num := myfoobar(1.5707963267948966);
            numInt := testCharType('H');
            numInt := testBoolType(false);
            numInt := testBoolType(true);
            numInt := testStrType(stringName); --nope
            write(wrbuf, num);
            write(wrbuf, string'("  Time: "));
            write(wrbuf, now);
            writeline(output, wrbuf);
        end if;
    end process;

end architecture;
