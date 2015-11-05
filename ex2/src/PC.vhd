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
        clock, reset        : in std_logic := '0';
        processor_enable    : in std_logic := '0';
        jump                : in std_logic := '0';
        branch              : in std_logic := '0';
        alu_zero            : in std_logic := '0';
        pc_incremented      : in pc_t;
        jump_address        : in pc_t;
        branch_address      : in pc_t;
        pc_out              : out pc_t
    );
end PC;

architecture Behavioral of PC is
    constant PC_INCREMENT   : integer := 1;
    constant PC_INIT        : pc_t := (others => '0');

    signal pc_read_data : pc_t := PC_INIT;
    signal pc_write_data : pc_t := PC_INIT;
    signal pc_write_enable : std_logic := '0';
begin
    pc : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, write_enable => pc_write_enable, in_value => pc_write_data, out_value => pc_read_data);

    pc_out <= pc_read_data;

    pc_update : process(processor_enable, clock, reset)
    begin
        if reset = '1' then
            pc_write_enable <= '1';
            pc_write_data <= PC_INIT;
        elsif processor_enable = '1' and rising_edge(clock) then
            pc_write_enable <= '1';
            if jump = '1' then
                pc_write_data <= jump_address;
            elsif branch = '1' and alu_zero = '1' then
                pc_write_data <= branch_address;
            else
                pc_write_data <= pc_incremented;
            end if;
        else
            pc_write_enable <= '0';
        end if;
    end process;
end Behavioral;
