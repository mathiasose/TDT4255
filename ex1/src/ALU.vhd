library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ALU is
    Port (
        clk : in  STD_LOGIC
        ; rst : in  STD_LOGIC
        ; operand_A : in operand_t := OPERAND_0
        ; operand_B : in operand_t := OPERAND_0
        ; operation : in alu_operation_t := NO_OP
        ; result : out operand_t
        ; zero : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
    signal alu_result : operand_t;
begin

    process(clk, rst)
	begin
		if rst = '1' then

		elsif rising_edge(clk) then
			if operation = ADD then
                alu_result <= operand_t(signed(operand_A) + signed(operand_B));
			elsif operation = SUB then
                alu_result <= operand_t(signed(operand_A) - signed(operand_B));
			elsif operation = SLT then
                --alu_result <= OPERAND_1 when (signed(operand_A) < signed(operand_B)) else OPERAND_0;
                if signed(operand_A) < signed(operand_B) then
                    alu_result <= OPERAND_1;
                else
                    alu_result <= OPERAND_0;
                end if;
			elsif operation = ALU_AND then
                alu_result <= operand_A AND operand_B;
			elsif operation = ALU_OR then
                alu_result <= operand_A OR operand_B;
            end if;
		end if;
	end process;
    
    result <= alu_result;
    zero <= '1' when alu_result = OPERAND_0 else '0';
    
end Behavioral;

