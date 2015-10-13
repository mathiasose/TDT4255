library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity registers is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    Port ( 
        clock : in STD_LOGIC;
        read_register_1 : in register_address_t;
        read_register_2 : in  register_address_t;
        write_register : in  register_address_t;
        write_data : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        read_data_1 : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        read_data_2 : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        register_write : in  STD_LOGIC
        );
end registers;

architecture Behavioral of registers is
    type registerArray is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : registerArray := (others => OPERAND_0);
begin
    process(clock) is
    begin
        if rising_edge(clock) then
            if register_write = '1' then
                registers(to_integer(unsigned(write_register))) <= write_data;
            end if;
        end if;
    end process;

    read_data_1 <= registers(to_integer(unsigned(read_register_1)));
    read_data_2 <= registers(to_integer(unsigned(read_register_2)));
end Behavioral;