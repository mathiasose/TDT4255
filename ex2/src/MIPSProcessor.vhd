-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- MIPSProcessor.vhd
-- The MIPS processor component to be used in Exercise 1 and 2.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity MIPSProcessor is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    port (
        clock, reset      : in std_logic := '0';
        processor_enable  : in std_logic := '0';
        imem_data_in      : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        dmem_data_in      : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        imem_address      : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        dmem_address      : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        dmem_data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        dmem_write_enable : out std_logic := '0'
    );
end entity MIPSProcessor;

architecture Behavioral of MIPSProcessor is
    signal write_enable     : std_logic := '0';
    signal flush_pipeline    : std_logic := '0';

    -- Fetch stage signals
    signal if_pc_address        : pc_t;
    signal if_pc_incremented    : pc_t;

    -- Decode stage signals
    signal id_pc_address            : pc_t;
    signal id_reg_out_1             : operand_t;
    signal id_reg_out_2             : operand_t;
    signal id_forward_wb_signals    : wb_signals_t;
    signal id_forward_mem_signals   : mem_signals_t;
    signal id_forward_ex_signals    : ex_signals_t;
    signal id_instruction           : instruction_t;
    signal id_immediate_value_transformed: operand_t;
    signal id_immediate_value_transform  : immediate_value_transformation_t;

    -- Execute stage signals
    signal ex_alu_zero              : std_logic;
    signal ex_branch_address        : pc_t;
    signal ex_jump_address          : pc_t;
    signal ex_pc_address            : pc_t;
    signal ex_reg_out_1             : operand_t;
    signal ex_reg_out_2             : operand_t;
    signal ex_immediate_value       : operand_t;
    signal ex_operand_2             : operand_t;
    signal ex_alu_result            : operand_t;
    signal ex_jump_value            : jump_value_t;
    signal ex_rt                    : register_address_t;
    signal ex_rd                    : register_address_t;
    signal ex_write_register        : register_address_t;

    signal ex_forward_wb_signals    : wb_signals_t;
    signal ex_forward_mem_signals   : mem_signals_t;
    signal ex_control_signals       : ex_signals_t;

    -- Mem stage signals
    signal mem_alu_zero             : std_logic;
    signal mem_alu_result           : operand_t;
    signal mem_write_data           : operand_t;
    signal mem_jump_address         : pc_t;
    signal mem_branch_address       : pc_t;
    signal mem_write_register       : register_address_t;

    signal mem_forward_wb_signals   : wb_signals_t;
    signal mem_control_signals      : mem_signals_t;

    -- Writeback stage signals
    signal wb_alu_result        : operand_t;
    signal wb_read_data         : operand_t;
    signal wb_write_register    : register_address_t;
    signal wb_write_data        : operand_t;

    signal wb_control_signals   : wb_signals_t;

begin

    -- processor_enable dependent wirings
    imem_address <= if_pc_address(ADDR_WIDTH-1 downto 0) when processor_enable = '1' else (others => '0');
    dmem_address <= mem_alu_result(ADDR_WIDTH-1 downto 0) when processor_enable = '1' else (others => '0');
    dmem_write_enable <= mem_control_signals.mem_write when processor_enable = '1' else '0';
    dmem_data_out <= mem_write_data when processor_enable = '1' else (others => '0');

    -- other wirings
    if_pc_incremented <= pc_t(unsigned(if_pc_address) + 1);
    ex_operand_2 <= ex_immediate_value when ex_control_signals.alu_src = '1' else ex_reg_out_2;
    ex_write_register <= ex_rd when ex_control_signals.reg_dst = '1' else ex_rt;
    wb_write_data <= wb_read_data when wb_control_signals.mem_to_reg = '1' else wb_alu_result;


    propagate : process(clock, processor_enable) is
    begin
        if rising_edge(clock) and processor_enable = '1' then
            write_enable <= '1';
        else
            write_enable <= '0';
        end if;
    end process propagate;
    
    flush : process(mem_control_signals, mem_alu_zero) is
    begin
        if (mem_control_signals.jump = '1' or (mem_control_signals.branch = '1' and mem_alu_zero = '1')) then
            flush_pipeline <= '1';
        else
            flush_pipeline <= '0';
        end if;
    end process flush;

    -- Control module
    control : entity work.control
    port map(
        clock => clock,
        reset => reset,
        processor_enable => processor_enable,
        instruction => id_instruction,
        immediate_value_transform => id_immediate_value_transform,
        wb_signals => id_forward_wb_signals,
        mem_signals => id_forward_mem_signals,
        ex_signals => id_forward_ex_signals
    );

    -- ALU module
    alu : entity work.alu
    port map (
        operation => ex_control_signals.alu_op,
        operand_A => ex_reg_out_1,
        operand_B => ex_operand_2,
        shift_amount => "000000",  --TODO
        result => ex_alu_result,
        zero => ex_alu_zero
    );

    -- PC module
    pc : entity work.pc
    port map (
        clock => clock,
        reset => reset,
        processor_enable => processor_enable,
        jump => mem_control_signals.jump,
        branch => mem_control_signals.branch,
        alu_zero => mem_alu_zero,
        pc_incremented => if_pc_incremented,
        jump_address => mem_jump_address,
        branch_address => mem_branch_address,
        pc_out => if_pc_address
    );

    ex_pc : entity work.ex_pc
    port map (
        pc_in           => ex_pc_address,
        immediate_value => ex_immediate_value,
        j_value         => ex_jump_value,
        branch_address  => ex_branch_address,
        jump_address    => ex_jump_address
    );

    -- Registers module
    registers : entity work.registers
    port map (
        clock => clock,
        read_register_1 => id_instruction(25 downto 21),
        read_register_2 => id_instruction(20 downto 16),
        write_register => wb_write_register,
        write_data => wb_write_data,
        read_data_1 => id_reg_out_1,
        read_data_2 => id_reg_out_2,
        register_write => wb_control_signals.reg_write
    );

    -- Immediate value transform module
    immediate_value_transform : entity work.immediate_value_transform
    port map (
        transform => id_immediate_value_transform,
        in_value => id_instruction(15 downto 0),
        out_value => id_immediate_value_transformed
    );

    -- information flow between states
    
    -----------------------------------------------------------------
    -- IF --> ID
    -----------------------------------------------------------------
    if_to_id_pc : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => if_pc_address, out_value => id_pc_address);

    if_to_id_instruction : entity work.generic_register
    generic map(WIDTH => instruction_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => imem_data_in, out_value => id_instruction);

    -----------------------------------------------------------------
    -- ID --> EX
    -----------------------------------------------------------------
    id_to_ex_pc : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_pc_address, out_value => ex_pc_address);

    id_to_ex_read_data_1 : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_reg_out_1, out_value => ex_reg_out_1);

    id_to_ex_read_data_2 : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_reg_out_2, out_value => ex_reg_out_2);

    id_to_ex_read_imm_value : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_immediate_value_transformed, out_value => ex_immediate_value);

    id_to_ex_jump_value : entity work.generic_register
    generic map(WIDTH => jump_value_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_instruction(25 downto 0), out_value => ex_jump_value);

    id_to_ex_read_rt : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_instruction(20 downto 16), out_value => ex_rt);

    id_to_ex_read_rd : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => id_instruction(15 downto 11), out_value => ex_rd);

    id_to_ex_forward_wb_signals : entity work.wb_register 
    port map(reset => reset, write_enable => write_enable, in_value => id_forward_wb_signals, out_value => ex_forward_wb_signals);

    id_to_ex_forward_mem_signals : entity work.mem_register 
    port map(reset => reset, write_enable => write_enable, in_value => id_forward_mem_signals, out_value => ex_forward_mem_signals);

    id_to_ex_forward_ex_signals : entity work.ex_register 
    port map(reset => reset, write_enable => write_enable, in_value => id_forward_ex_signals, out_value => ex_control_signals);

    -----------------------------------------------------------------
    -- EX --> MEM
    -----------------------------------------------------------------
    ex_to_mem_jump_address : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => ex_jump_address, out_value => mem_jump_address);

    ex_to_mem_branch_address : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => ex_branch_address, out_value => mem_branch_address);

    ex_to_mem_alu_zero : entity work.bit_register
    port map(reset => reset, write_enable => write_enable, in_value => ex_alu_zero, out_value => mem_alu_zero);

    ex_to_mem_alu_result : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => ex_alu_result, out_value => mem_alu_result);

    ex_to_mem_read_data_2 : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => ex_reg_out_2, out_value => mem_write_data);

    ex_to_mem_write_register : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => ex_write_register, out_value => mem_write_register);

    ex_to_mem_forward_wb_signals : entity work.wb_register 
    port map(reset => reset, write_enable => write_enable, in_value => ex_forward_wb_signals, out_value => mem_forward_wb_signals);

    ex_to_mem_forward_mem_signals : entity work.mem_register 
    port map(reset => reset, write_enable => write_enable, in_value => ex_forward_mem_signals, out_value => mem_control_signals);

    -----------------------------------------------------------------
    -- MEM --> WB
    -----------------------------------------------------------------
    mem_to_wb_read_data : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => dmem_data_in, out_value => wb_read_data);

    mem_to_wb_alu_result : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => mem_alu_result, out_value => wb_alu_result);

    mem_to_wb_write_register : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset, write_enable => write_enable, in_value => mem_write_register, out_value => wb_write_register);

    mem_to_wb_forward_wb_signals : entity work.wb_register 
    port map(reset => reset, write_enable => write_enable, in_value => mem_forward_wb_signals, out_value => wb_control_signals);

end Behavioral;
