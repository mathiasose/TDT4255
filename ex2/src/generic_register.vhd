library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_register is
    generic(
        REG_WIDTH : integer := 1
    );
    port(
        reset           : in  STD_LOGIC
    ;   write_enable    : in  STD_LOGIC
    ;   in_value        : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0)
    ;   out_value       : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0) := (others => '0')
    );
end generic_register;

architecture Behavioral of generic_register is
begin
    process(reset, write_enable)
    begin
        if reset = '1' then
            out_value <= (others => '0');
        elsif write_enable = '1' then
            out_value <= in_value;
        end if;
    end process;
end Behavioral;

