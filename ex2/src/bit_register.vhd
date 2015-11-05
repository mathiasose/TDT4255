library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bit_register is
    port(
        reset           : in  STD_LOGIC
    ;   write_enable    : in  STD_LOGIC
    ;   in_value        : in  STD_LOGIC
    ;   out_value       : out STD_LOGIC := '0'
    );
end bit_register;

architecture Behavioral of bit_register is
begin
    process(reset, write_enable)
    begin
        if reset = '1' then
            out_value <= '0';
        elsif write_enable = '1' then
            out_value <= in_value;
        end if;
    end process;
end Behavioral;

