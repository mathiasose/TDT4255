LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.testutil.ALL;
USE work.defs.ALL;
 
ENTITY tb_ALU IS
END tb_ALU;
 
ARCHITECTURE behavior OF tb_ALU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    Port (
        clk : in  STD_LOGIC
        ; rst : in  STD_LOGIC
        ; data_in_1 : in operand_t
        ; data_in_2 : in operand_t
        ; operation : in alu_operation_t
        ; result : out operand_t
        ; zero : out STD_LOGIC
    );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal data_in_1 : operand_t := (others => '0');
   signal data_in_2 : operand_t := (others => '0');
   signal operation :  alu_operation_t := NO_OP;

 	--Outputs
   signal result : operand_t;
   signal zero : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          clk => clk,
          rst => rst,
          data_in_1 => data_in_1,
          data_in_2 => data_in_2,
          operation => operation,
          result => result,
          zero => zero
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
      
      -- ADD, SUB, SLT, ALU_AND, ALU_OR, NO_OP
      
      wait for clk_period;

      data_in_1 <= x"00000001";
      data_in_2 <= x"00000001";
      operation <= ADD;
      wait for clk_period;
      check(result = x"00000002", "1 + 1 = 2");
      check(zero /= '1', "1 + 1 does not raise zero flag");
      
      operation <= SUB;
      wait for clk_period;
      check(result = x"00000000", "1 - 1 = 0");
      check(zero = '1', "1 - 1 raises zero flag");

      report "ALL TESTS SUCCESSFUL";

      wait;
   end process;

END;
