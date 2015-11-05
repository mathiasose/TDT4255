library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ALU is
    Port (
        operand_A     : in operand_t := OPERAND_0;
        operand_B     : in operand_t := OPERAND_0;
        shift_amount  : in shift_amount_t := (others => '0');
        operation     : in alu_operation_t := NO_OP;
        result        : out operand_t;
        zero          : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
    signal alu_result : operand_t := (others => '0');
begin
    result <= alu_result;
    zero <= '1' when alu_result = OPERAND_0 else '0';

    -- ALU is not clocked directly, but the inputs are clock-dependent
    process(operation, operand_A, operand_B, shift_amount)
    begin
        case operation is
        when ADD =>
            alu_result <= operand_t(signed(operand_A) + signed(operand_B));
        when SUB =>
            alu_result <= operand_t(signed(operand_A) - signed(operand_B));
        when SLT =>
            if signed(operand_A) < signed(operand_B) then
                alu_result <= OPERAND_1;
            else
                alu_result <= OPERAND_0;
            end if;
        when ALU_AND =>
            alu_result <= operand_A AND operand_B;
        when ALU_OR =>
            alu_result <= operand_A OR operand_B;
        when ALU_NOR =>
            alu_result <= operand_A NOR operand_B;
        when ALU_XOR =>
            alu_result <= operand_A XOR operand_B;
        when ALU_SLL =>
            alu_result <= operand_t(shift_left(unsigned(operand_A), to_integer(unsigned(shift_amount))));
        when ALU_SRL =>
            alu_result <= operand_t(shift_right(unsigned(operand_A), to_integer(unsigned(shift_amount))));
        when ALU_SRA =>
            alu_result <= operand_t(shift_right(signed(operand_A), to_integer(unsigned(shift_amount))));
        when others => -- NO_OP
            alu_result <= operand_B;    -- Useful when doing LUI
        end case;
    end process;
end Behavioral;
