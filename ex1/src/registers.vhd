library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity registers is
    Port ( read_register_1 : in  STD_LOGIC_VECTOR (5 downto 0);
           read_register_2 : in  STD_LOGIC_VECTOR (5 downto 0);
           write_register : in  STD_LOGIC_VECTOR (3 downto 0);
           write_data : in  STD_LOGIC_VECTOR (7 downto 0);
           read_data_1 : out  STD_LOGIC_VECTOR (31 downto 0);
           read_data_2 : out  STD_LOGIC_VECTOR (31 downto 0);
           register_write : in  STD_LOGIC);
end registers;

architecture Behavioral of registers is

	signal
begin


end Behavioral;

