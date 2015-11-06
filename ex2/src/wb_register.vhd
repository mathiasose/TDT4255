library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity wb_register is
    generic(
        WIDTH : integer := 1
    );
    port(
        reset           : in  std_logic
    ;   clock           : in  std_logic
    ;   write_enable    : in  std_logic
    ;   in_value        : in  wb_signals_t
    ;   out_value       : out wb_signals_t
    );
end wb_register;

architecture Behavioral of wb_register is
begin
    process(reset, clock, write_enable)
    begin
        if reset = '1' then
            out_value.reg_write <= '0';
            out_value.mem_to_reg <= '0';
        elsif rising_edge(clock) then
            out_value <= in_value;
        end if;
    end process;
end Behavioral;

