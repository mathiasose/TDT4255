LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;
 
ENTITY tb_PC IS
END tb_PC;
 
ARCHITECTURE behavior OF tb_PC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PC
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         instr_in : IN  std_logic_vector(31 downto 0);
         jump : IN  std_logic;
         addr_out : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal instr_in : std_logic_vector(31 downto 0) := (others => '0');
   signal jump : std_logic := '0';

 	--Outputs
   signal addr_out : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PC PORT MAP (
          clk => clk,
          rst => rst,
          instr_in => instr_in,
          jump => jump,
          addr_out => addr_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for clk_period;
      rst <= '1';
      wait for clk_period;
      rst <= '0';
      check(addr_out = x"00000000", "PC should reset to 0 address");

      wait for clk_period;
      check(addr_out = x"00000001", "PC should increment by 1");

      wait for clk_period;
      instr_in <= X"08000013"; --j 19
      jump <= '1';
      wait for clk_period;
      jump <= '0';
      check(addr_out = x"00000013", "PC should have jumped to 19");

      report "Test success";
      wait;
   end process;

END;
