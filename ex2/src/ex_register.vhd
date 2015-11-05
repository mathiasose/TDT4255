library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity ex_register is
    generic(
            WIDTH : integer := 1
        );
        port(
            reset           : in  STD_LOGIC
        ;   write_enable    : in  STD_LOGIC
        ;   in_value        : in  ex_signals_t
        ;   out_value       : out ex_signals_t
    );
end ex_register;

architecture Behavioral of ex_register is
begin
    process(reset, write_enable)
        begin
            if reset = '1' then
                out_value.reg_dst <= '0';
                out_value.alu_op <= NO_OP;
                out_value.alu_src <= '0';
            elsif write_enable = '1' then
                out_value <= in_value;
            end if;
    end process;

end Behavioral;

