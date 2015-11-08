library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity hazard_detection_unit is
    Port (
        mem_read    : in std_logic;
        ex_rt       : in register_address_t;
        id_rt       : in register_address_t;
        id_rs       : in register_address_t;
        stall       : out std_logic
    );
end hazard_detection_unit;

architecture Behavioral of hazard_detection_unit is

begin
    stall <= '1' when mem_read = '1' and (ex_rt = id_rs or ex_rt = id_rt) else '0';
end Behavioral;
