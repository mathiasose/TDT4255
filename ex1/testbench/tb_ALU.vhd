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
        clock : in  STD_LOGIC
        ; reset : in  STD_LOGIC
        ; operand_A : in operand_t
        ; operand_B : in operand_t
        ; operation : in alu_operation_t
        ; result : out operand_t
        ; zero : out STD_LOGIC
    );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal operand_A : operand_t := (others => '0');
   signal operand_B : operand_t := (others => '0');
   signal operation :  alu_operation_t := NO_OP;

 	--Outputs
   signal result : operand_t;
   signal zero : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          clock => clock,
          reset => reset,
          operand_A => operand_A,
          operand_B => operand_B,
          operation => operation,
          result => result,
          zero => zero
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
      
      -- ADD, SUB, SLT, ALU_AND, ALU_OR, NO_OP
      
      wait for clock_period;

      operand_A <= OPERAND_1;
      operand_B <= OPERAND_1;
      operation <= ADD;
      wait for clock_period;
      check(result = x"00000002", "1 + 1 = 2");
      check(zero /= '1', "1 + 1 does not raise zero flag");

      operation <= SUB;
      wait for clock_period;
      check(result = OPERAND_0, "1 - 1 = 0");
      check(zero = '1', "1 - 1 raises zero flag");

      operation <= SLT;
      wait for clock_period;
      check(result = OPERAND_0, "SLT 1 1 results in 0");

      operand_A <= OPERAND_0;
      wait for clock_period;
      check(result = OPERAND_1, "SLT 0 1 results in 1");

      operand_A <= OPERAND_0;
      operand_B <= x"FFFFFFFF";
      operation <= ALU_AND;
      wait for clock_period;
      check(result = OPERAND_0, "1 AND 0 = 0");

      operation <= ALU_OR;
      wait for clock_period;
      check(result = x"FFFFFFFF", "1 OR 0 = 1");

      report "ALL TESTS SUCCESSFUL";

      wait;
   end process;

END;
