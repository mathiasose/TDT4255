library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity mem_register is
    generic(
        WIDTH : integer := 1
    );
    port(
        reset           : in  std_logic
    ;   clock           : in  std_logic
    ;   write_enable    : in  std_logic
    ;   in_value        : in  mem_signals_t
    ;   out_value       : out mem_signals_t
    );
end mem_register;

architecture Behavioral of mem_register is

begin
    process(reset, clock, write_enable)
    begin
        if reset = '1' then
            out_value.mem_write <= '0';
            out_value.jump <= '0';
            out_value.branch <= '0';
        elsif rising_edge(clock) then
            out_value <= in_value;
        end if;
    end process;

end Behavioral;

