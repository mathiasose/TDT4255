library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;

entity reg_id_ex is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    Port(
        reset : in std_logic
    ;   write_enable : in std_logic
    ;   pc_in : in pc_t
    ;   pc_out : out pc_t := (others => '0')
    ;   read_data_1_in : in operand_t
    ;   read_data_1_out : out operand_t
    ;   imm_val_in : in operand_t
    ;   imm_val_out : out operand_t
    ;   rt_in : in register_address_t
    ;   rt_out : in register_address_t
    ;   rd_in : in register_address_t
    ;   rd_out : in register_address_t
    
    --control signals to WB
    ;   reg_write_in : in std_logic
    ;   reg_write_out : out std_logic := '0'
    ;   mem_to_reg_in : in std_logic
    ;   mem_to_reg_out : out std_logic := '0'
    
    --control signals to MEM
    ;   mem_read_in : in std_logic
    ;   mem_read_out : out std_logic := '0'
    ;   mem_write_in : in std_logic
    ;   mem_write_out : out std_logic := '0'
    ;   branch_in : in std_logic
    ;   branch_out : out std_logic := '0'
    
    --control signals to EX
    ;   reg_dst_in : in std_logic
    ;   reg_dst_out : out std_logic := '0'
    ;   alu_op_in : in std_logic
    ;   alu_op_out : out std_logic := '0'
    ;   alu_src_in : in std_logic
    ;   alu_src_out : out std_logic := '0'
    );
end reg_if_id;

architecture Behavioral of reg_id_ex is

begin
    process(reset, clock, write_enable)
    begin
        if reset = '1' then
            pc_out <= (others => '0');
        elsif write_enable = '1' then
            pc_out <= pc_in;
        end if;
    end process; 

end Behavioral;

