library ieee;
use ieee.std_logic_1164.all;

package defs is

  -- Creating new types for different signals in your design has
  -- certain advantages:
  --   1. It allows you to attach extra semantic information to
  --   signals. For instance , if you see a signal of type
  --   "stack_input_select_t" you know that it is supposed
  --   to be used for selecting the stack input.
  -- 
  --   2. It avoids repeating information such as signal widths. For
  --   example, our instruction_t type is defined as a 16-bit wide
  --   std_logic_vector. If we wanted to expand our instruction size to
  --   32 bits, we would (hopefully) only need to update the type
  --   definition. The same holds for enumeration types such as
  --   alu_operation_t below; the operations our ALU can perform is
  --   captured in the definition of alu_operation_t only.

  subtype operand_t is std_logic_vector(7 downto 0);
  subtype opcode_t is std_logic_vector(7 downto 0);
  subtype instruction_t is std_logic_vector(15 downto 0);

  -- These are called "enumeration types", and are used to represent
  -- signals which can take one of a set of of predefined
  -- (enumerated) values.
  type alu_operation_t is (ALU_ADD, ALU_SUB);
  type stack_input_select_t is (STACK_INPUT_OPERAND, STACK_INPUT_RESULT);

end package defs;
