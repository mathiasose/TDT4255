library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity PC is
    generic (
        ADDR_WIDTH : integer := 8;  -- in here we maintain a 32 bit register, it may be shortened outside
        DATA_WIDTH : integer := 32
    );
    Port (
        clock, reset        : in std_logic := '0';
        processor_enable    : in std_logic := '0';
        jump                : in std_logic := '0';
        branch              : in std_logic := '0';
        alu_zero            : in std_logic := '0';
        stall               : in std_logic := '0';
        pc_incremented      : in pc_t;
        jump_address        : in pc_t;
        branch_address      : in pc_t;
        pc_out              : out pc_t
    );
end PC;

architecture Behavioral of PC is
    constant PC_INCREMENT   : integer := 1;
    constant PC_INIT        : pc_t := (others => '0');

    signal pc_write_data    : pc_t := PC_INIT;
    signal pc_write_enable  : std_logic := '0';
begin
    pc : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(
        reset => reset,
        clock => clock,
        write_enable => pc_write_enable,
        in_value => pc_write_data,
        out_value => pc_out
    );

    pc_write_enable <= '1' when (processor_enable = '1' and stall = '0') else '0';
    pc_write_data <= jump_address when jump = '1' else branch_address when (branch = '1' and alu_zero = '1') else pc_incremented;
end Behavioral;
