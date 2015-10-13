library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity immediate_value_transform is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    Port (
        transform : in immediate_value_transformation_t;
        in_value : in immediate_value_t;
        out_value : out operand_t
    );
end immediate_value_transform;

architecture Behavioral of immediate_value_transform is
    signal shifted_value : operand_t;
    signal extended_value : operand_t;
begin
    shifted_value <= operand_t(in_value & x"0000");
    extended_value <= operand_t(resize(unsigned(in_value), operand_t'length));
    out_value <= shifted_value when transform = SHIFT_LEFT else extended_value;
end Behavioral;

