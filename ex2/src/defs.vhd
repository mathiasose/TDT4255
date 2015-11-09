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
    type forwarded_reg_src_t is (REG, MEM, WB);

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
        mem_read    : std_logic;
    end record;

    type ex_signals_t is
    record
        reg_dst         : std_logic;
        alu_op          : alu_operation_t;
        alu_immediate   : std_logic;
    end record;

    constant NO_OP_EX_SIGNALS  : ex_signals_t := ('0', NO_OP, '0');
    constant NO_OP_MEM_SIGNALS : mem_signals_t := ('0', '0', '0', '0');
    constant NO_OP_WB_SIGNALS  : wb_signals_t := ('0', '0');

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

    constant INSTRUCTION_NO_OP : instruction_t := (others => '0');

    -- Convenience functions for extractng parts of instructions
    function opcode(I : instruction_t) return opcode_t;
    function rs(I : instruction_t) return register_address_t;
    function rt(I : instruction_t) return register_address_t;
    function rd(I : instruction_t) return register_address_t;
    function shift_amount(I : instruction_t) return shift_amount_t;
    function i_value(I : instruction_t) return immediate_value_t;
    function j_value(I : instruction_t) return jump_value_t;

end package defs;

package body defs is
    function opcode(I : instruction_t) return opcode_t is
    begin
        return opcode_t(I(31 downto 26));
    end function opcode;

    function rs(I : instruction_t) return register_address_t is
    begin
        return register_address_t(I(25 downto 21));
    end function rs;

    function rt(I : instruction_t) return register_address_t is
    begin
        return register_address_t(I(20 downto 16));
    end function rt;

    function rd(I : instruction_t) return register_address_t is
    begin
        return register_address_t(I(15 downto 11));
    end function rd;

    function shift_amount(I : instruction_t) return shift_amount_t is
    begin
        return shift_amount_t(I(11 downto 6));
    end function shift_amount;

    function i_value(I : instruction_t) return immediate_value_t is
    begin
        return immediate_value_t(I(15 downto 0));
    end function i_value;

    function j_value(I : instruction_t) return jump_value_t is
    begin
        return jump_value_t(I(25 downto 0));
    end function j_value;
end package body defs;
