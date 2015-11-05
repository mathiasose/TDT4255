library IEEE;
use IEEE.STD_LOGIC_1164.all;

package defs is
    subtype instruction_t       is std_logic_vector(31 downto 0);
    subtype operand_t           is std_logic_vector(31 downto 0);
    subtype immediate_value_t   is std_logic_vector(15 downto 0);
    subtype register_address_t  is std_logic_vector(4 downto 0);
    subtype opcode_t            is std_logic_vector(5 downto 0);
    subtype funct_t             is std_logic_vector(5 downto 0);
    subtype shift_amount_t      is std_logic_vector(5 downto 0);
    subtype pc_t                is std_logic_vector(31 downto 0);
    subtype jump_value_t        is std_logic_vector(25 downto 0);

    type alu_operation_t is (ADD, SUB, SLT, ALU_AND, ALU_OR, ALU_NOR, ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA, NO_OP);
    type immediate_value_transformation_t is (SHIFT_LEFT, SIGN_EXTEND);
    type alu_input_src_t is (REG, MEM, WB);

    type wb_signals_t is
    record
        reg_write   : std_logic;
        mem_to_reg  : std_logic;
    end record;

    type mem_signals_t is
    record
        mem_write   : std_logic;
        branch      : std_logic;
        jump        : std_logic;
    end record;

    type ex_signals_t is
    record
        reg_dst         : std_logic;
        alu_op          : alu_operation_t;
        alu_immediate   : std_logic;
    end record;

    -- ALU function values
    constant ADD_FUNCT : funct_t := "100000";
    constant SUB_FUNCT : funct_t := "100010";
    constant AND_FUNCT : funct_t := "100100";
    constant OR_FUNCT  : funct_t := "100101";
    constant SLT_FUNCT : funct_t := "101010";
    constant NOR_FUNCT : funct_t := "100111";
    constant XOR_FUNCT : funct_t := "100110";
    constant SLL_FUNCT : funct_t := "000000";
    constant SRL_FUNCT : funct_t := "000010";
    constant SRA_FUNCT : funct_t := "000011";

    -- Opcode values
    constant ALU_OP_OPCODE  : opcode_t := "000000";
    constant JUMP_OPCODE    : opcode_t := "000010";
    constant BEQ_OPCODE     : opcode_t := "000100";
    constant LW_OPCODE      : opcode_t := "100011";
    constant SW_OPCODE      : opcode_t := "101011";
    constant LUI_OPCODE     : opcode_t := "001111";
    constant ADDI_OPCODE    : opcode_t := "001000";
    constant ANDI_OPCODE    : opcode_t := "001100";
    constant ORI_OPCODE     : opcode_t := "001101";
    constant XORI_OPCODE    : opcode_t := "001110";
    constant SLTI_OPCODE    : opcode_t := "001010";

    -- Operands
    constant OPERAND_0 : operand_t := x"00000000";
    constant OPERAND_1 : operand_t := x"00000001";

end package defs;
