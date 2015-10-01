library IEEE;
use IEEE.STD_LOGIC_1164.all;

package defs is
	subtype instruction_t is std_logic_vector(31 downto 0);
	subtype operand_t is std_logic_vector(31 downto 0);
	type alu_operation_t is (ADD, SUB, SLT, ALU_AND, ALU_OR, NO_OP);
	type state_t is (STALL, FETCH, EXECUTE, LOAD_STORE);
	subtype opcode_t is std_logic_vector(5 downto 0);
end package defs;