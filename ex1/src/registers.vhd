library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity registers is
    Port ( 
		clock : in STD_LOGIC;
		read_register_1 : in  STD_LOGIC_VECTOR (5 downto 0);
		read_register_2 : in  STD_LOGIC_VECTOR (5 downto 0);
		write_register : in  STD_LOGIC_VECTOR (5 downto 0);
		write_data : in  STD_LOGIC_VECTOR (31 downto 0);
		read_data_1 : out  STD_LOGIC_VECTOR (31 downto 0);
		read_data_2 : out  STD_LOGIC_VECTOR (31 downto 0);
		register_write : in  STD_LOGIC);
end registers;

architecture Behavioral of registers is
	type registerArray is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
	signal registers : registerArray;
begin
	process(clock) is
	begin
	
		if rising_edge(clock) then
			if register_write = '1' then
				registers(to_integer(unsigned(write_register))) <= write_data;
			end if;
			
			read_data_1 <= registers(to_integer(unsigned(read_register_1)));
			read_data_2 <= registers(to_integer(unsigned(read_register_2)));
		end if;
		
	end process;
end Behavioral;

