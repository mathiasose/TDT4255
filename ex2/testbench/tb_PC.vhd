LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;
use work.defs.all;
 
ENTITY tb_PC IS
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
END tb_PC;
 
ARCHITECTURE behavior OF tb_PC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT PC
    Port (
        clock           : in std_logic;
        reset           : in std_logic := '0';
        write_pc     : in pc_t;
        write_enable    : in std_logic;
        pc_out          : out pc_t
    );
    END COMPONENT;

   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal write_pc : pc_t;
   signal write_enable : STD_LOGIC := '0';

     --Outputs
   signal pc_out : pc_t;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: PC PORT MAP (
          clock => clock,
          reset => reset,
          pc_out => pc_out,
          write_pc => write_pc,
          write_enable => write_enable
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
      wait for clock_period;
      reset <= '1';
      wait for clock_period;
      reset <= '0';
      check(pc_out = x"00000000", "PC should reset to 0 address");

      wait for clock_period; -- pc += 1
      wait for clock_period; -- pc += 1
      check(pc_out = x"00000002", "PC should increment by 1 each clock period");

      write_enable <= '1';
      write_pc <= x"AAAAAAAA";
      wait for clock_period;
      check(pc_out = x"AAAAAAAA", "PC should have been overwritten");

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
