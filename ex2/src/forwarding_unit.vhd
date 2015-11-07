library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity forwarding_unit is
    port(
        MEM_reg_write   : in std_logic;
        WB_reg_write    : in std_logic;
        EX_rs           : in register_address_t;
        EX_rt           : in register_address_t;
        ID_rs           : in register_address_t;
        ID_rt           : in register_address_t;
        MEM_reg_dest    : in register_address_t;
        WB_reg_dest     : in register_address_t;
        alu_input_1     : out forwarded_reg_src_t := REG;
        alu_input_2     : out forwarded_reg_src_t := REG;
        read_register_1 : out forwarded_reg_src_t := REG;
        read_register_2 : out forwarded_reg_src_t := REG
    );
end forwarding_unit;

architecture Behavioral of forwarding_unit is
begin
    forward_data : process(mem_reg_write, mem_reg_dest, wb_reg_write, wb_reg_dest, EX_rs, EX_rt, ID_rs, ID_rt)
    begin
        -- Select source for ALU operand 1
        if mem_reg_write = '1' and EX_rs = mem_reg_dest then
            alu_input_1 <= MEM;
        elsif wb_reg_write = '1' and EX_rs = wb_reg_dest then
            alu_input_1 <= WB;
        else
            alu_input_1 <= REG;
        end if;

        -- Select source for ALU operand 2
        if mem_reg_write = '1' and EX_rt = mem_reg_dest then
            alu_input_2 <= MEM;
        elsif wb_reg_write = '1' and EX_rt = wb_reg_dest then
            alu_input_2 <= WB;
        else
            alu_input_2 <= REG;
        end if;

        -- Select source for register read value 1
        if mem_reg_write = '1' and ID_rs = mem_reg_dest then
            read_register_1 <= MEM;
        elsif wb_reg_write = '1' and ID_rs = wb_reg_dest then
            read_register_1 <= WB;
        else
            read_register_1 <= REG;
        end if;

        -- Select source for register read value 2
        if mem_reg_write = '1' and ID_rt = mem_reg_dest then
            read_register_2 <= MEM;
        elsif wb_reg_write = '1' and ID_rt = wb_reg_dest then
            read_register_2 <= WB;
        else
            read_register_2 <= REG;
        end if;
    end process;
end Behavioral;
