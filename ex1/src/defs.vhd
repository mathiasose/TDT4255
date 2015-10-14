library IEEE;
use IEEE.STD_LOGIC_1164.all;

package defs is
    subtype instruction_t is std_logic_vector(31 downto 0);
    subtype operand_t is std_logic_vector(31 downto 0);
    subtype immediate_value_t is std_logic_vector(15 downto 0);
    subtype register_address_t is std_logic_vector(4 downto 0);
    subtype opcode_t is std_logic_vector(5 downto 0);
    subtype funct_t is std_logic_vector(5 downto 0);

    type alu_operation_t is (ADD, SUB, SLT, ALU_AND, ALU_OR, ALU_NOR, ALU_XOR, NO_OP);
    type state_t is (STALL, FETCH, EXECUTE);
    type immediate_value_transformation_t is (SHIFT_LEFT, SIGN_EXTEND);

    constant OPERAND_0 : operand_t := x"00000000";
    constant OPERAND_1 : operand_t := x"00000001";

    constant ADD_FUNCT : funct_t := "100000";
    constant SUB_FUNCT : funct_t := "100010";
    constant ALU_AND_FUNCT : funct_t := "100100";
    constant ALU_OR_FUNCT : funct_t := "100101";
    constant SLT_FUNCT : funct_t := "101010";
    constant NOR_FUNCT : funct_t := "100111";
    constant XOR_FUNCT : funct_t := "100110";

    constant ALU_OP_OPCODE : opcode_t := "000000";
    constant JUMP_OPCODE : opcode_t := "000010";
    constant BEQ_OPCODE : opcode_t := "000100";
    constant LW_OPCODE : opcode_t := "100011";
    constant SW_OPCODE : opcode_t := "101011";
    constant LUI_OPCODE : opcode_t := "001111";

    constant ADDI_OPCODE : opcode_t := "001000";
    constant ANDI_OPCODE : opcode_t := "001100";
    constant ORI_OPCODE : opcode_t := "001101";
    constant XORI_OPCODE : opcode_t := "001110";
end package defs;