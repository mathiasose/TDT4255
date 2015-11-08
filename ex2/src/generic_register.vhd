library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_register is
    generic(
        WIDTH : integer := 1
    );
    port(
        reset           : in  std_logic
    ;   clock           : in  std_logic
    ;   write_enable    : in  std_logic := '1'
    ;   pass_through    : in  std_logic := '0'
    ;   in_value        : in  std_logic_vector(WIDTH-1 downto 0)
    ;   out_value       : out std_logic_vector(WIDTH-1 downto 0) := (others => '0')
    );
end generic_register;

architecture Behavioral of generic_register is
begin
    process(reset, clock, write_enable, in_value)
    begin
        if reset = '1' then
            out_value <= (others => '0');
        elsif write_enable = '1' then
            if pass_through = '1' then
                out_value <= in_value;
            elsif rising_edge(clock) then
                out_value <= in_value;
            end if;
        end if;
    end process;
end Behavioral;

