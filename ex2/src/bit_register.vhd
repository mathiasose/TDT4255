library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bit_register is
    port(
        reset           : in std_logic
    ;   clock           : in std_logic
    ;   write_enable    : in std_logic
    ;   in_value        : in std_logic
    ;   out_value       : out std_logic := '0'
    );
end bit_register;

architecture Behavioral of bit_register is
begin
    process(reset, clock, write_enable)
    begin
        if reset = '1' then
            out_value <= '0';
        elsif rising_edge(clock) then
            out_value <= in_value;
        end if;
    end process;
end Behavioral;

