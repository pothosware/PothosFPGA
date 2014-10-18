------------------------------------------------------------------------
-- External input implementation
------------------------------------------------------------------------

package ExternalSinkFunctions is
    function setupInput (portNum : integer) return integer;
    attribute foreign of setupInput : function is "VHPIDIRECT PothosFPGA_setupInput";

    function inputHasSpace (handle : integer) return boolean;
    attribute foreign of inputHasSpace : function is "VHPIDIRECT PothosFPGA_inputHasSpace";

    procedure inputPushData (handle : integer; data : integer);
    attribute foreign of inputPushData : procedure is "VHPIDIRECT PothosFPGA_inputPushData";
end ExternalSinkFunctions;

package body ExternalSinkFunctions is
    function setupInput (portNum : integer) return integer is begin
    end function setupInput;

    function inputHasSpace (handle : integer) return boolean is begin
    end function inputHasSpace;

    procedure inputPushData (handle : integer; data : integer) is begin
    end procedure inputPushData;
end ExternalSinkFunctions;

library work;
use work.ExternalSinkFunctions.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExternalSink is
    generic(
        -- the external interface port identification number
        PORT_NUMBER : natural;

        -- the bit width of the data port
        DATA_WIDTH : positive
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- input bus
        in_data : in std_logic_vector((DATA_WIDTH)-1 downto 0);
        in_valid : in std_logic;
        in_ready : out std_logic
    );
end entity ExternalSink;

architecture sim of ExternalSink is begin

    process (clk)
        variable handle : integer := setupInput(PORT_NUMBER);
        variable thisReady : boolean := false;
    begin

        thisReady := inputHasSpace(handle);
        if (thisReady) then
            in_ready <= '1';
        else
            in_ready <= '0';
        end if;

        if (rising_edge(clk)) then
            if (in_valid = '1' and thisReady) then
                inputPushData(handle, to_integer(unsigned(in_data)));
            end if;
        end if;

    end process;

end architecture sim;
