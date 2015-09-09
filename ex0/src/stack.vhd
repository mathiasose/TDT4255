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
	type ramType is array(0 to size - 1) of std_logic_vector(7 downto 0);
	signal ram : ramType;
	signal address : std_logic_vector(7 downto 0) := (others => '0');

begin  -- architecture behavioural
		process (clk, rst) is
			begin
				if rst = '1' then
					address <= (others => '0');
					top <= (others => '0');
					ram(0) <= (others => '0');
				else
					if rising_edge(clk) then
						top <= ram(to_integer(unsigned(address)));
					elsif falling_edge(clk) then
						if push = '1' then
							address <= std_logic_vector(unsigned(address) + 1);
							ram(to_integer(unsigned(address)) + 1) <= value_in;
						elsif pop = '1' then
							if unsigned(address) = 0 then
								-- i'm emitting zero.
							else
								address <= std_logic_vector(unsigned(address) - 1);
							end if;
						end if;
					end if;
				end if;
			end process;
end architecture behavioural;
