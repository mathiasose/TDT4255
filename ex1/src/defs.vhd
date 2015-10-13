library IEEE;
use IEEE.STD_LOGIC_1164.all;

package defs is
    subtype instruction_t is std_logic_vector(31 downto 0);
    subtype operand_t is std_logic_vector(31 downto 0);
    subtype immediate_value_t is std_logic_vector(15 downto 0);
    subtype register_address_t is std_logic_vector(4 downto 0);
    subtype opcode_t is std_logic_vector(5 downto 0);

    type alu_operation_t is (ADD, SUB, SLT, ALU_AND, ALU_OR, NO_OP);
    type state_t is (STALL, FETCH, EXECUTE);
    type immediate_value_transformation_t is (SHIFT_LEFT, SIGN_EXTEND);

    constant OPERAND_0 : operand_t := x"00000000";
    constant OPERAND_1 : operand_t := x"00000001";

    constant ALU_OP_OPCODE : opcode_t := "000000";
    constant JUMP_OPCODE : opcode_t := "000010";
    constant BEQ_OPCODE : opcode_t := "000100";
    constant LW_OPCODE : opcode_t := "100011";
    constant SW_OPCODE : opcode_t := "101011";
    constant LUI_OPCODE : opcode_t := "001111";
end package defs;