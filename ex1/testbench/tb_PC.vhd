LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;
 
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
        clock : in  STD_LOGIC
        ; reset : in  STD_LOGIC := '0'
        ; instruction : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
        ; jump : in  STD_LOGIC := '0'
        ; branch : in STD_LOGIC := '0'
        ; alu_zero : in STD_LOGIC := '0'
        ; write_enable : in STD_LOGIC := '0'
        ; addr_out : out  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0)
    );
    END COMPONENT;

   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal instruction : std_logic_vector(31 downto 0) := (others => '0');
   signal jump : std_logic := '0';
   signal branch : std_logic := '0';
   signal alu_zero : std_logic := '0';
   signal write_enable : STD_LOGIC := '0';

 	--Outputs
   signal addr_out : std_logic_vector(ADDR_WIDTH-1 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PC PORT MAP (
          clock => clock,
          reset => reset,
          instruction => instruction,
          jump => jump,
          branch => branch,
          alu_zero => alu_zero,
          addr_out => addr_out,
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
      check(addr_out = x"FF", "PC should reset to FF address");

      wait for clock_period;
      write_enable <= '1';
      wait for clock_period; -- pc += 1
      wait for clock_period; -- pc += 1
      write_enable <= '0';
      check(addr_out = x"01", "PC should increment by 1 each clock period when write enabled");

      wait for clock_period;
      write_enable <= '1';
      wait for clock_period; -- pc += 1
      instruction <= X"08000013"; --j 19
      jump <= '1';
      wait for clock_period;
      write_enable <= '0';
      jump <= '0';
      check(addr_out = x"13", "PC should have jumped to 0x13");

      wait for clock_period; -- fetch state
      instruction <= X"10000002"; --beq $0, $0, 2
      wait for clock_period; -- execute state
      branch <= '1';
      alu_zero <= '1';
      write_enable <= '1';
      wait for clock_period; -- fetch state
      branch <= '0';
      alu_zero <= '0';
      write_enable <= '0';
      check(addr_out = x"16", "PC should have branched to 0x15 + 1");

      wait for clock_period;
      write_enable <= '1';
      wait for clock_period; -- pc += 1
      instruction <= X"1000FFFD"; --beq $0, $0, -3
      branch <= '1';
      alu_zero <= '1';
      write_enable <= '1';
      wait for clock_period;
      branch <= '0';
      alu_zero <= '0';
      write_enable <= '0';
      check(addr_out = x"15", "PC should have branched to 0x17 - 3 + 1");

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
