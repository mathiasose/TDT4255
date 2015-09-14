library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity stack is
  
  generic (
    size : natural := 1024);            -- Maximum number of operands on stack

  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    value_in  : in  operand_t;
    push      : in  std_logic;
    pop       : in  std_logic;
    top       : out operand_t);

end entity stack;

architecture behavioural of stack is
	type ramType is array(size downto 0) of operand_t;
	signal ram : ramType;
	signal stack_pointer : integer := 0;

begin  -- architecture behavioural
    process (clk, rst) is
    begin
        if rst = '1' then
            stack_pointer <= 0;
            ram(0) <= (others => '0');
        elsif rising_edge(clk) then
            if push = '1' then
                stack_pointer <= stack_pointer + 1;
                ram(stack_pointer + 1) <= value_in;
            elsif pop = '1' then
                if stack_pointer = 0 then
                    -- i'm emitting zero.
                else
                    stack_pointer <=stack_pointer - 1;
                end if;
            end if;
        end if;
    end process;

    top <= ram(stack_pointer);
end architecture behavioural;
