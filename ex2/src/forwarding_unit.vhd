library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity forwarding_unit is
    port(
        mem_reg_write               : in std_logic;
        wb_reg_write                : in std_logic;
        instruction_rs              : in register_address_t;
        instruction_rt              : in register_address_t;
        mem_reg_dest                : in register_address_t;
        wb_reg_dest                 : in register_address_t;
        forward_control_signal_1    : out alu_input_src_t := REG;
        forward_control_signal_2    : out alu_input_src_t := REG
    );
end forwarding_unit;

architecture Behavioral of forwarding_unit is
begin
    forward_data : process(mem_reg_write, mem_reg_dest, wb_reg_write, wb_reg_dest, instruction_rs, instruction_rt)
    begin
        -- Select source for ALU operand 1
        if mem_reg_write = '1' and instruction_rs = mem_reg_dest then
            forward_control_signal_1 <= MEM;
        elsif wb_reg_write = '1' and instruction_rs = wb_reg_dest then
            forward_control_signal_1 <= WB;
        else
            forward_control_signal_1 <= REG;
        end if;

        -- Select source for ALU operand 2
        if mem_reg_write = '1' and instruction_rt = mem_reg_dest then
            forward_control_signal_2 <= MEM;
        elsif wb_reg_write = '1' and instruction_rt = wb_reg_dest then
            forward_control_signal_2 <= WB;
        else
            forward_control_signal_2 <= REG;
        end if;
    end process;
end Behavioral;
