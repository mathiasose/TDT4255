library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ALU is
    Port (
        clk : in  STD_LOGIC
        ; rst : in  STD_LOGIC
        ; data_in_1 : in operand_t := (others => '0')
        ; data_in_2 : in operand_t := (others => '0')
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
                alu_result <= operand_t(signed(data_in_1) + signed(data_in_2));
			elsif operation = SUB then
                alu_result <= operand_t(signed(data_in_1) - signed(data_in_2));
            end if;
		end if;
	end process;
    
    result <= alu_result;
    zero <= '1' when alu_result = x"00000000" else '0';
    
end Behavioral;

