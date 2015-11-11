library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity forwarder_mux is
    port(
        MEM_reg_write       : in std_logic;
        WB_reg_write        : in std_logic;
        MEM_reg_dst         : in register_address_t;
        WB_reg_dst          : in register_address_t;
        selected_register   : in register_address_t;
        
        --inputs
        default_value   : in operand_t;
        MEM_value       : in operand_t;
        WB_value        : in operand_t;
        
        --output
        out_value : out operand_t
    );
end forwarder_mux;

architecture Behavioral of forwarder_mux is
    signal selected_source : forward_select_t;
begin
    with selected_source select
        out_value <= MEM_value when MEM, WB_value when WB, default_value when others;

    select_source : process(MEM_reg_write, MEM_reg_dst, WB_reg_write, WB_reg_dst, selected_register)
    begin
        if MEM_reg_write = '1' and selected_register = MEM_reg_dst then
            selected_source <= MEM;
        elsif WB_reg_write = '1' and selected_register = WB_reg_dst then
            selected_source <= WB;
        else
            selected_source <= DEFAULT;
        end if;
    end process;
end Behavioral;
