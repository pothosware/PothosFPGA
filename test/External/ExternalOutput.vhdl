------------------------------------------------------------------------
-- External output implementation
------------------------------------------------------------------------

package ExternalOutputFunctions is
    function setupOutput (v : natural) return integer;
    attribute foreign of setupOutput : function is "VHPIDIRECT PothosFPGA_setupOutput";
end ExternalOutputFunctions;

package body ExternalOutputFunctions is
    function setupOutput (v : natural) return integer is begin
    end function setupOutput;
end ExternalOutputFunctions;

library work;
use work.ExternalOutputFunctions.all;

library ieee;
use ieee.std_logic_1164.all;

entity ExternalOutput is
    generic(
        -- the external interface port identification number
        PORT_NUMBER : natural;

        -- the bit width of the data port
        DATA_WIDTH : positive
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- output bus
        out_data : out std_logic_vector((DATA_WIDTH)-1 downto 0);
        out_valid : out std_logic;
        out_ready : in std_logic
    );
end entity ExternalOutput;

architecture sim of ExternalOutput is


begin

    process(clk)
    variable setupResult : integer := setupOutput(PORT_NUMBER);
    begin
        if(rising_edge(clk)) then
            if(rst = '0') then  --reset is checked only at the rising edge of clock.
                --
            else
                --
            end if;
        end if;
    end process;


end architecture sim;
