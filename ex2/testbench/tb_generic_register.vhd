LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.testutil.all;
  
ENTITY tb_generic_register IS
END tb_generic_register;
 
ARCHITECTURE behavior OF tb_generic_register IS

    COMPONENT generic_register
    generic(
        WIDTH : integer := 1
    );
    port(
        reset           : in  STD_LOGIC
    ;   clock           : in  STD_LOGIC
    ;   write_enable    : in  STD_LOGIC
    ;   in_value        : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    ;   out_value       : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
    END COMPONENT;

   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal write_enable : std_logic := '0';
   signal in_value_1 : std_logic_vector(0 downto 0) := (others => '0');
   signal out_value_1 : std_logic_vector(0 downto 0) := (others => '0');
   signal in_value_2 : std_logic_vector(31 downto 0) := (others => '0');
   signal out_value_2 : std_logic_vector(31 downto 0) := (others => '0');
   
   constant clock_period : time := 10 ns;
 
BEGIN

    uut1: generic_register
    PORT MAP (
        reset => reset,
        clock => clock,
        write_enable => write_enable,
        in_value => in_value_1,
        out_value => out_value_1
    );

    uut2: generic_register
    generic map(
        WIDTH => 32
    )
    PORT MAP (
        reset => reset,
        clock => clock,
        write_enable => write_enable,
        in_value => in_value_2,
        out_value => out_value_2
    );
    
   clock_process: process
   begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
   end process;

   stim_proc: process
   begin        
      wait for 100 ns;

      check(out_value_1="0", "Default value should be 1 bit of 0");
      check(out_value_2=x"00000000", "Default value should be 32 bits of 0");
      
      write_enable <= '1';
      in_value_1 <= "1";
      in_value_2 <= x"FFFFFFFF";
      wait for clock_period*2;
      write_enable <= '0';
      check(out_value_1="1", "Value should be 1 now");
      check(out_value_2=x"FFFFFFFF", "Value should be all 1s now");

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
