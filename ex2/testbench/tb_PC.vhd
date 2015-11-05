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
        clock, reset        : in std_logic := '0';
        processor_enable    : in std_logic := '0';
        jump                : in std_logic := '0';
        branch              : in std_logic := '0';
        alu_zero            : in std_logic := '0';
        pc_incremented      : in pc_t;
        jump_address        : in pc_t;
        branch_address      : in pc_t;
        pc_out              : out pc_t
    );
    END COMPONENT;

    --Inputs
    signal clock            : std_logic := '0';
    signal reset            : std_logic := '0';
    signal processor_enable : std_logic := '0';
    signal jump             : std_logic := '0';
    signal branch           : std_logic := '0';
    signal alu_zero         : std_logic := '0';
    signal pc_incremented   : pc_t;
    signal jump_address     : pc_t;
    signal branch_address   : pc_t;

     --Outputs
   signal pc_out : pc_t;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: PC PORT MAP (
          clock => clock,
          reset => reset,
          processor_enable => processor_enable,
          jump => jump,
          branch => branch,
          alu_zero => alu_zero,
          pc_incremented => pc_incremented,
          jump_address => jump_address,
          branch_address => branch_address,
          pc_out => pc_out
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
      wait for 10*clock_period;
      reset <= '0';
      check(pc_out = x"00000000", "PC should reset to 0 address and not change before processor is enabled");

      processor_enable <= '1';
      pc_incremented <= pc_t(unsigned(pc_out) + 1);
      wait for clock_period; -- pc += 1
      pc_incremented <= pc_t(unsigned(pc_out) + 1);
      wait for clock_period; -- pc += 1
      check(pc_out = x"00000002", "PC should increment by 1 each clock period");

      jump <= '1';
      jump_address <= x"AAAAAAAA";
      wait for clock_period;
      check(pc_out = x"AAAAAAAA", "PC should have been overwritten");

      jump <= '0';
      branch <= '1';
      branch_address <= x"F0F0F0F0";
      pc_incremented <= pc_t(unsigned(pc_out) + 1);
      wait for clock_period;
      check(pc_out = x"AAAAAAAB", "PC should not have been overwritten but incremented because alu_zero is not enabled");

      alu_zero <= '1';
      wait for clock_period;
      check(pc_out = x"F0F0F0F1", "PC should have been overwritten");

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
