  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS
          SIGNAL out0,out1,out2,out3,bitin : std_logic:='0';
          SIGNAL sel :  std_logic_vector(1 downto 0):="00";
  BEGIN
    UUT : entity work.demux1_4 port map(out0,out1,out2,out3,sel,bitin);

     tb : PROCESS
     BEGIN
            bitin <= '1';
            sel <="00";
             wait for 2 ns;
             sel <="01";
             wait for 2 ns;
             sel <="10";
             wait for 2 ns;
             sel <="11";
             wait for 2 ns;
             --more input combinations can be given here.
     END PROCESS tb;

  END;
