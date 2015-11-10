library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ex_PC is
    Port (
        pc_in           : in pc_t           := (others => '0')
    ;   immediate_value : in operand_t      := (others => '0')
    ;   j_value         : in jump_value_t   := (others => '0')
    ;   branch_address  : out pc_t
    ;   jump_address    : out pc_t
    );
end ex_PC;

architecture Behavioral of ex_PC is
begin
    branch_address <= pc_t(signed(pc_in) + signed(immediate_value));
    jump_address <= pc_in(31 downto 26) & j_value;
end Behavioral;
