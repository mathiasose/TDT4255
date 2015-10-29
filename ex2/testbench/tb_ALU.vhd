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
        operand_A : in operand_t
        ; operand_B : in operand_t
        ; operation : in alu_operation_t
        ; shift_amount : in shift_amount_t
        ; result : out operand_t
        ; zero : out STD_LOGIC
    );
    END COMPONENT;
    

   --Inputs
   signal operand_A : operand_t := (others => '0');
   signal operand_B : operand_t := (others => '0');
   signal operation :  alu_operation_t := NO_OP;
   signal shift_amount : shift_amount_t := (others => '0');

     --Outputs
   signal result : operand_t;
   signal zero : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          operand_A => operand_A,
          operand_B => operand_B,
          operation => operation,
          shift_amount => shift_amount,
          result => result,
          zero => zero
        );
 

   -- Stimulus process
   stim_proc: process
   begin      
      wait for clock_period;

      operand_A <= (others => '1');
      operand_B <= OPERAND_1;

      wait for clock_period;
      check(result = OPERAND_1, "NO_OP means result <= operand_B");

      operand_A <= OPERAND_1;
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

      operation <= ALU_NOR;
      wait for clock_period;
      check(result = OPERAND_0, "1 NOR 0 = 0");

      operand_A <= OPERAND_1;
      operand_B <= x"FFFFFFFF";
      operation <= ALU_XOR;
      wait for clock_period;
      check(result = x"FFFFFFFE", "Test XOR");

      operation <= ALU_SLL;
      shift_amount <= "000100";
      wait for clock_period;
      check(result = x"00000010", "Test SLL");

      operation <= ALU_SRL;
      operand_A <= x"00000010";
      wait for clock_period;
      check(result = x"00000001", "Test SRL");

      operation <= ALU_SRA;
      operand_A <= x"F0000000";
      shift_amount <= "000100";
      wait for clock_period;
      check(result = x"FF000000", "Test SRA");

      report "ALL TESTS SUCCESSFUL";

      wait;
   end process;

END;
