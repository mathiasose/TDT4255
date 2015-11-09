library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ex_register is
    port(
        reset           : in  std_logic
    ;   clock           : in  std_logic
    ;   write_enable    : in  std_logic := '1'
    ;   in_value        : in  ex_signals_t
    ;   out_value       : out ex_signals_t
    );
end ex_register;

architecture Behavioral of ex_register is
begin
    process(reset, clock, write_enable, in_value)
    begin
        if reset = '1' then
            out_value <= NO_OP_EX_SIGNALS;
        elsif rising_edge(clock) and write_enable = '1' then
            out_value <= in_value;
        end if;
    end process;
end Behavioral;

