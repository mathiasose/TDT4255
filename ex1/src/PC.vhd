library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    generic (
        -- operating with 32 wide MIPS addresses in here, chop off everything but ADDR_WIDTH when outputting
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    Port (
        clock         : in  STD_LOGIC;
        reset         : in  STD_LOGIC := '0';
        instruction   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        jump          : in  STD_LOGIC := '0';
        branch        : in  STD_LOGIC := '0';
        alu_zero      : in  STD_LOGIC := '0';
        write_enable  : in  STD_LOGIC := '0';
        addr_out      : out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0)
    );
end PC;

architecture Behavioral of PC is
    constant PC_INCREMENT   : integer := 1; -- Increment PC by 1
    constant PC_INIT        : STD_LOGIC_VECTOR(31 downto 0) := (others => '1');

    signal pc               : STD_LOGIC_VECTOR(31 downto 0) :=  PC_INIT; -- start at max so that the first inceremnt overflows to 0
    signal jump_address     : STD_LOGIC_VECTOR(31 downto 0);
    signal immediate_value  : STD_LOGIC_VECTOR(15 downto 0);
begin
    immediate_value <= instruction(15 downto 0);
    jump_address <= pc(31 downto 26) & instruction(25 downto 0);
    addr_out <= pc(ADDR_WIDTH-1 downto 0);

    process(clock, reset, write_enable)
    begin
        if reset = '1' then
            pc <= PC_INIT;
        elsif rising_edge(clock) and write_enable = '1' then
            -- BEQ instruction
            if branch = '1' and alu_zero = '1' then
                pc <= STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(pc)), pc'length) + signed(immediate_value) + PC_INCREMENT);

            -- Jump instruction
            elsif jump = '1' then
                pc <= jump_address;

            else
                pc <= STD_LOGIC_VECTOR(unsigned(pc) + PC_INCREMENT);
            end if;
        end if;
    end process;
end Behavioral;
