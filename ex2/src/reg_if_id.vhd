library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;

entity reg_if_id is
    Port(
        reset : in  STD_LOGIC;
        write_enable : in  STD_LOGIC;
        instruction_in : in instruction_t;
        instruction_out : out instruction_t := (others => '0');
        pc_in : in pc_t;
        pc_out : out pc_t := (others => '0')
    );
end reg_if_id;

architecture Behavioral of reg_if_id is

begin
    process(reset, write_enable)
    begin
        if reset = '1' then
            instruction_out <= (others => '0');
            pc_out <= (others => '0');
        elsif write_enable = '1' then
            instruction_out <= instruction_in;
            pc_out <= (others => '0');
        end if;
    end process; 

end Behavioral;

