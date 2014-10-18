------------------------------------------------------------------------
-- External input implementation
------------------------------------------------------------------------

package ExternalInputFunctions is
    function setupInput (portNum : integer) return integer;
    attribute foreign of setupInput : function is "VHPIDIRECT PothosFPGA_setupInput";

    function inputHasSpace (handle : integer) return boolean;
    attribute foreign of inputHasSpace : function is "VHPIDIRECT PothosFPGA_inputHasSpace";

    function inputPushData (handle : integer; data : integer) return boolean;
    attribute foreign of inputPushData : function is "VHPIDIRECT PothosFPGA_inputPushData";
end ExternalInputFunctions;

package body ExternalInputFunctions is
    function setupInput (portNum : integer) return integer is begin
    end function setupInput;

    function inputHasSpace (handle : integer) return boolean is begin
    end function inputHasSpace;

    function inputPushData (handle : integer; data : integer) return boolean is begin
    end function inputPushData;
end ExternalInputFunctions;

library work;
use work.ExternalInputFunctions.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExternalInput is
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
end entity ExternalInput;

architecture sim of ExternalInput is begin

    process (clk)
        variable handle : integer := setupInput(PORT_NUMBER);
        variable pushOk : boolean;
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
                pushOk := inputPushData(handle, to_integer(unsigned(in_data)));
            end if;
        end if;

    end process;

end architecture sim;
