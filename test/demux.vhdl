library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux1_4 is
port (
      out0 : out std_logic;   --output bit
      out1 : out std_logic;   --output bit
       out2 : out std_logic;   --output bit
      out3 : out std_logic;   --output bit
       sel : in std_logic_vector(1 downto 0);
       bitin : in std_logic   --input bit
     );
end demux1_4;

architecture Behavioral of demux1_4 is

begin
process(bitin,sel)
begin
case sel is
  when "00" => out0 <= bitin; out1 <= '0'; out2 <= '0'; out3 <='0';
  when "01" => out1 <= bitin; out0 <= '0'; out2 <= '0'; out3 <='0';
  when "10" => out2 <= bitin; out0 <= '0'; out1 <= '0'; out3 <='0';
  when others => out3 <= bitin;  out0 <= '0'; out1 <= '0'; out2 <='0';
end case;
end process;

end Behavioral;
