------------------------------------------------------------------------
-- External output implementation
------------------------------------------------------------------------

package ExternalSourceFunctions is
    function setupOutput (portNum : integer) return integer;
    attribute foreign of setupOutput : function is "VHPIDIRECT PothosFPGA_setupOutput";

    function outputHasData (handle : integer) return boolean;
    attribute foreign of outputHasData : function is "VHPIDIRECT PothosFPGA_outputHasData";

    procedure outputPopData (handle : integer);
    attribute foreign of outputPopData : procedure is "VHPIDIRECT PothosFPGA_outputPopData";

    function outputFrontData (handle : integer) return integer;
    attribute foreign of outputFrontData : function is "VHPIDIRECT PothosFPGA_outputFrontData";
end ExternalSourceFunctions;

package body ExternalSourceFunctions is
    function setupOutput (portNum : integer) return integer is begin
    end function setupOutput;

    function outputHasData (handle : integer) return boolean is begin
    end function outputHasData;

    procedure outputPopData (handle : integer) is begin
    end procedure outputPopData;

    function outputFrontData (handle : integer) return integer is begin
    end function outputFrontData;
end ExternalSourceFunctions;

library work;
use work.ExternalSourceFunctions.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExternalSource is
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
end entity ExternalSource;

architecture sim of ExternalSource is begin

    process (clk)
        variable handle : integer := setupOutput(PORT_NUMBER);
        variable preData : std_logic_vector((DATA_WIDTH)-1 downto 0);
        variable thisValid : boolean := false;
    begin

        thisValid := outputHasData(handle);
        if (thisValid) then
            out_valid <= '1';
            out_data <= std_logic_vector(to_unsigned(outputFrontData(handle), DATA_WIDTH));
        else
            out_valid <= '0';
        end if;

        if (rising_edge(clk)) then
            if (out_ready = '1' and thisValid) then
                outputPopData(handle);
            end if;
        end if;

    end process;

end architecture sim;
