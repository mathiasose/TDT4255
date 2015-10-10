LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;
use work.defs.all;
 
ENTITY tb_registers IS
END tb_registers;
 
ARCHITECTURE behavior OF tb_registers IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT registers
    Port ( 
        clock : in STD_LOGIC;
        read_register_1 : in  register_address_t;
        read_register_2 : in  register_address_t;
        write_register : in  register_address_t;
        write_data : in  STD_LOGIC_VECTOR (31 downto 0);
        read_data_1 : out  STD_LOGIC_VECTOR (31 downto 0);
        read_data_2 : out  STD_LOGIC_VECTOR (31 downto 0);
        register_write : in  STD_LOGIC);
    END COMPONENT;

   --Inputs
   signal read_register_1 : register_address_t := (others => '0');
   signal read_register_2 : register_address_t := (others => '0');
   signal write_register : register_address_t := (others => '0');
   signal write_data : std_logic_vector(31 downto 0) := (others => '0');
   signal register_write : std_logic := '0';
    signal clock : std_logic := '0';

     --Outputs
   signal read_data_1 : std_logic_vector(31 downto 0) := (others => '0');
   signal read_data_2 : std_logic_vector(31 downto 0) := (others => '0');
 
   constant clock_period : time := 10 ns;
 
BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: registers PORT MAP (
             clock => clock,
          read_register_1 => read_register_1,
          read_register_2 => read_register_2,
          write_register => write_register,
          write_data => write_data,
          read_data_1 => read_data_1,
          read_data_2 => read_data_2,
          register_write => register_write
        );

   -- Clock process definitions
   clock_process :process
   begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
       -- Save data to register and retrive afterwards
      wait for clock_period;
        register_write <= '1';
        write_register <= "11100";
        write_data <= x"00001337";
        wait for clock_period;
        register_write <= '0';
        wait for clock_period;
        read_register_1 <= "11100";
        wait for clock_period;

        check(read_data_1 = x"00001337", "Read_data_1 should contain 00001337 at address 11100");

        -- Save data to register and retrive from two registers
        wait for clock_period;
        register_write <= '1';
        write_register <= "11111";
        write_data <= x"00001337";
        wait for clock_period;
        register_write <= '0';
        wait for clock_period;
        read_register_2 <= "11111";
        wait for clock_period;
        check(read_data_1 = x"00001337", "Read_data_1 should contain 00001337 at address 11100");
        check(read_data_2 = x"00001337", "Read_data_2 should contain 00001337 at address 11111");

        report "ALL TESTS SUCCESSFUL";
        wait;
   end process;

END;
