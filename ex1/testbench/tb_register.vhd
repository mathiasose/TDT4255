LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;

ENTITY tb_register IS
END tb_register;

ARCHITECTURE behavior OF tb_register IS 
	COMPONENT reg
	Port ( data_in : in  STD_LOGIC_VECTOR (31 downto 0);
			enable : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			clock : in  STD_LOGIC;
			data_out : out  STD_LOGIC_VECTOR (31 downto 0)
	);
	END COMPONENT;
	
   --Inputs
	signal clock : std_logic := '0';
   signal enable : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in : std_logic_vector(31 downto 0) := (others => '0');
   
 	--Outputs
   signal data_out : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN

-- Component Instantiation
	uut: reg PORT MAP(
		clock => clock,
		reset => reset,
		enable => enable,
		data_in => data_in,
		data_out => data_out
	);

   -- Clock process definitions
   clk_process :process
   begin
		clock <= '0';
		wait for clk_period/2;
		clock <= '1';
		wait for clk_period/2;
   end process;
	
	stim_proc: process
   begin
      wait for clk_period;
      reset <= '1';
      wait for clk_period;
      reset <= '0';
      check(data_out = x"00000000", "Register should default to 0 after reset");

		-- Update register value
      wait for clk_period;
      enable <= '1';
		data_in <= x"00001337";
      wait for clk_period;
      enable <= '0';
      check(data_out = x"00001337", "Register should output new data");
		
		-- Should not update register value when enable is 0
		wait for clk_period;
		data_in <= x"11111111";
      wait for clk_period;
      check(data_out = x"00001337", "Register should output old value");
		
		report "ALL TESTS SUCCESSFUL";
		wait;
   end process;

END;
