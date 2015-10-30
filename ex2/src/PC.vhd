library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity PC is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    Port (
        clock           : in std_logic;
        reset           : in std_logic := '0';
        write_pc        : in pc_t;
        write_enable    : in std_logic;
        pc_out          : out pc_t
    );
end PC;

architecture Behavioral of PC is
    constant PC_INCREMENT   : integer := 1;
    constant PC_INIT        :  pc_t := (others => '0');

    signal pc               : pc_t :=  PC_INIT;
begin
    pc_out <= pc;

    process(clock, reset, write_enable)
    begin
        if reset = '1' then
            pc <= PC_INIT;
        elsif rising_edge(clock) then
            if write_enable = '1' then
                pc <= write_pc;
            else
                pc <= STD_LOGIC_VECTOR(unsigned(pc) + PC_INCREMENT);
            end if;
        end if;
    end process;
end Behavioral;
