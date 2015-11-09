library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flusher is
    port(
        jump        : in std_logic;
        branch      : in std_logic;
        alu_zero    : in std_logic;
        flush       : out std_logic
    );
end flusher;

architecture Behavioral of flusher is
begin
    process(jump, branch, alu_zero) is
    begin
        if jump = '1' or (branch = '1' and alu_zero = '1') then
            flush <= '1';
        else
            flush <= '0';
        end if;
    end process;
end Behavioral;

