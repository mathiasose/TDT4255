library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity registers is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32;
        NUM_REGISTERS : integer := 32
    );
    Port (
        clock           : in  std_logic;
        read_register_1 : in  register_address_t;
        read_register_2 : in  register_address_t;
        write_register  : in  register_address_t;
        register_write  : in  std_logic;
        write_data      : in  operand_t;
        read_data_1     : out operand_t;
        read_data_2     : out operand_t
    );
end registers;

architecture Behavioral of registers is
    type registerArray is array(0 to NUM_REGISTERS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal registers : registerArray := (others => OPERAND_0);
begin
    -- Read data from registers
    read_data_1 <= registers(to_integer(unsigned(read_register_1)));
    read_data_2 <= registers(to_integer(unsigned(read_register_2)));

    -- Write new data to register
    process(clock, register_write) is
    begin
        if rising_edge(clock) and register_write = '1' then
            registers(to_integer(unsigned(write_register))) <= write_data;
        end if;
    end process;
end Behavioral;
