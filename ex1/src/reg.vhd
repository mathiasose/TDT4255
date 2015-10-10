library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
    Port ( data_in : in  STD_LOGIC_VECTOR (31 downto 0);
           enable : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (31 downto 0));
end reg;

architecture Behavioral of reg is

begin
	process(clock, reset)
	begin
		if reset = '1' then
			data_out <= x"00000000";
		elsif rising_edge(clock) then
			if enable = '1' then
				data_out <= data_in;
			end if;
		end if;
	end process;
end Behavioral;