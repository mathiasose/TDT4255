library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity wb_register is
    generic(
            WIDTH : integer := 1
        );
        port(
            reset           : in  STD_LOGIC
        ;   write_enable    : in  STD_LOGIC
        ;   in_value        : in  wb_signals_t
        ;   out_value       : out wb_signals_t
        );
end wb_register;

architecture Behavioral of wb_register is
begin
    process(reset, write_enable)
    begin
        if reset = '1' then
            out_value.reg_write <= '0';
            out_value.mem_to_reg <= '0';
        elsif write_enable = '1' then
            out_value <= in_value;
        end if;
    end process;
end Behavioral;

