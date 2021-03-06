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
    -- global signals
    signal write_enable     : std_logic := '0';
    signal flush_pipeline   : std_logic := '0';
    signal stall            : std_logic := '0';
    signal was_stalling     : std_logic := '0';
    signal reset_or_flush   : std_logic := '0';

    -- Fetch stage signals
    signal IF_pc_address        : pc_t;
    signal IF_pc_incremented    : pc_t;

    -- Decode stage signals
    signal ID_pc_address                    : pc_t;
    signal ID_reg_out_1                     : operand_t;
    signal ID_reg_out_2                     : operand_t;
    signal ID_instruction                   : instruction_t;
    signal ID_immediate_value_transformed   : operand_t;
    signal ID_immediate_value_transform     : immediate_value_transformation_t;
    signal ID_control_EX_signals            : EX_signals_t;
    signal ID_control_MEM_signals           : MEM_signals_t;
    signal ID_control_WB_signals            : WB_signals_t;
    signal ID_forward_EX_signals            : EX_signals_t;
    signal ID_forward_MEM_signals           : MEM_signals_t;
    signal ID_forward_WB_signals            : WB_signals_t;
    signal ID_read_data_1                   : operand_t;
    signal ID_read_data_2                   : operand_t;

    -- Execute stage signals
    signal EX_alu_zero              : std_logic;
    signal EX_branch_address        : pc_t;
    signal EX_jump_address          : pc_t;
    signal EX_pc_address            : pc_t;
    signal EX_read_data_1           : operand_t;
    signal EX_read_data_2           : operand_t;
    signal EX_immediate_value       : operand_t;
    signal EX_shift_amount          : shift_amount_t;
    signal EX_operand_1             : operand_t;
    signal EX_operand_2             : operand_t;
    signal EX_operand_2_source      : operand_t;
    signal EX_alu_result            : operand_t;
    signal EX_jump_value            : jump_value_t;
    signal EX_rt                    : register_address_t;
    signal EX_rd                    : register_address_t;
    signal EX_rs                    : register_address_t;
    signal EX_write_register        : register_address_t;
    signal EX_control_signals       : EX_signals_t;
    signal EX_forward_MEM_signals   : MEM_signals_t;
    signal EX_forward_WB_signals    : WB_signals_t;

    -- Mem stage signals
    signal MEM_alu_zero             : std_logic;
    signal MEM_alu_result           : operand_t;
    signal MEM_write_data           : operand_t;
    signal MEM_jump_address         : pc_t;
    signal MEM_branch_address       : pc_t;
    signal MEM_write_register       : register_address_t;
    signal MEM_control_signals      : MEM_signals_t;
    signal MEM_forward_WB_signals   : WB_signals_t;

    -- Writeback stage signals
    signal WB_alu_result        : operand_t;
    signal WB_read_data         : operand_t;
    signal WB_write_register    : register_address_t;
    signal WB_write_data        : operand_t;
    signal WB_control_signals   : WB_signals_t;

begin
    -- processor_enable dependent wirings
    imem_address <= IF_pc_address(ADDR_WIDTH-1 downto 0) when processor_enable = '1' else (others => '0');
    dmem_address <= MEM_alu_result(ADDR_WIDTH-1 downto 0) when processor_enable = '1' else (others => '0');
    dmem_write_enable <= MEM_control_signals.MEM_write when processor_enable = '1' else '0';
    dmem_data_out <= MEM_write_data when processor_enable = '1' else (others => '0');

    -- MUXes
    IF_pc_incremented <= pc_t(unsigned(IF_pc_address) + 1);
    EX_write_register <= EX_rd when EX_control_signals.reg_dst = '1' else EX_rt;
    WB_write_data <= WB_read_data when WB_control_signals.MEM_to_reg = '1' else WB_alu_result;

    -- Data forwarding muxes
    ID_fwd_read_data_1 : entity work.forwarder_mux
    port map(
        MEM_reg_write       => MEM_forward_WB_signals.reg_write,
        WB_reg_write        => WB_control_signals.reg_write,
        MEM_reg_dst         => MEM_write_register,
        WB_reg_dst          => WB_write_register,
        selected_register   => rs(ID_instruction),
        default_value       => ID_reg_out_1,
        MEM_value           => MEM_alu_result,
        WB_value            => WB_write_data,
        out_value           => ID_read_data_1
    );
    ID_fwd_read_data_2 : entity work.forwarder_mux
    port map(
        MEM_reg_write       => MEM_forward_WB_signals.reg_write,
        WB_reg_write        => WB_control_signals.reg_write,
        MEM_reg_dst         => MEM_write_register,
        WB_reg_dst          => WB_write_register,
        selected_register   => rt(ID_instruction),
        default_value       => ID_reg_out_2,
        MEM_value           => MEM_alu_result,
        WB_value            => WB_write_data,
        out_value           => ID_read_data_2
    );
    EX_fwd_alu_input_1 : entity work.forwarder_mux
    port map(
        MEM_reg_write       => MEM_forward_WB_signals.reg_write,
        WB_reg_write        => WB_control_signals.reg_write,
        MEM_reg_dst         => MEM_write_register,
        WB_reg_dst          => WB_write_register,
        selected_register   => EX_rs,
        default_value       => EX_read_data_1,
        MEM_value           => MEM_alu_result,
        WB_value            => WB_write_data,
        out_value           => EX_operand_1
    );
    EX_fwd_alu_input_2 : entity work.forwarder_mux
    port map(
        MEM_reg_write       => MEM_forward_WB_signals.reg_write,
        WB_reg_write        => WB_control_signals.reg_write,
        MEM_reg_dst         => MEM_write_register,
        WB_reg_dst          => WB_write_register,
        selected_register   => EX_rt,
        default_value       => EX_read_data_2,
        MEM_value           => MEM_alu_result,
        WB_value            => WB_write_data,
        out_value           => EX_operand_2_source
    );

    EX_operand_2 <= EX_immediate_value when EX_control_signals.alu_immediate = '1' else EX_operand_2_source;

    -- Stalling
    reset_or_flush <= reset or flush_pipeline;
    ID_forward_EX_signals <= NO_OP_EX_SIGNALS when stall = '1' else ID_control_EX_signals;
    ID_forward_MEM_signals <= NO_OP_MEM_SIGNALS when stall = '1' else ID_control_MEM_signals;
    ID_forward_WB_signals <= NO_OP_WB_SIGNALS when stall = '1' else ID_control_WB_signals;

    stalling : process(clock, stall, was_stalling) is
    begin
        if rising_edge(clock) then
            if stall = '1' then
                was_stalling <= '1';
            elsif was_stalling = '1' then
                was_stalling <= '0';
            end if;
        end if;
    end process stalling;

    -- functional unit instantiations

    control : entity work.control
    port map(
        processor_enable => processor_enable,
        instruction => ID_instruction,
        immediate_value_transform => ID_immediate_value_transform,
        WB_signals => ID_control_WB_signals,
        MEM_signals => ID_control_MEM_signals,
        EX_signals => ID_control_EX_signals
    );

    alu : entity work.alu
    port map (
        operation       => EX_control_signals.alu_op,
        operand_A       => EX_operand_1,
        operand_B       => EX_operand_2,
        shift_amount    => EX_shift_amount,
        result          => EX_alu_result,
        zero            => EX_alu_zero
    );

    pc : entity work.pc
    port map (
        clock               => clock,
        reset               => reset,
        stall               => stall,
        processor_enable    => processor_enable,
        jump                => MEM_control_signals.jump,
        branch              => MEM_control_signals.branch,
        alu_zero            => MEM_alu_zero,
        pc_incremented      => IF_pc_incremented,
        jump_address        => MEM_jump_address,
        branch_address      => MEM_branch_address,
        pc_out              => IF_pc_address
    );

    EX_pc : entity work.EX_pc
    port map (
        pc_in           => EX_pc_address,
        immediate_value => EX_immediate_value,
        j_value         => EX_jump_value,
        branch_address  => EX_branch_address,
        jump_address    => EX_jump_address
    );

    registers : entity work.registers
    port map (
        clock           => clock,
        read_register_1 => rs(ID_instruction),
        read_register_2 => rt(ID_instruction),
        write_register  => WB_write_register,
        write_data      => WB_write_data,
        read_data_1     => ID_reg_out_1,
        read_data_2     => ID_reg_out_2,
        register_write  => WB_control_signals.reg_write
    );

    immediate_value_transform : entity work.immediate_value_transform
    port map (
        transform   => ID_immediate_value_transform,
        in_value    => i_value(ID_instruction),
        out_value   => ID_immediate_value_transformed
    );

    hazard_detection_unit : entity work.hazard_detection_unit
    port map (
        mem_read    => EX_forward_MEM_signals.mem_read,
        ex_rt       => EX_rt,
        id_rt       => rt(ID_instruction),
        id_rs       => rs(ID_instruction),
        stall       => stall
    );

    flusher: entity work.flusher
    port map(
        jump     => MEM_control_signals.jump,
        branch   => MEM_control_signals.branch,
        alu_zero => MEM_alu_zero,
        flush    => flush_pipeline
    );

    -- information flow between states

    -----------------------------------------------------------------
    -- IF --> ID
    -----------------------------------------------------------------
    IFID_pc : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset_or_flush, clock => clock, write_enable => not stall, in_value => IF_pc_incremented, out_value => ID_pc_address);

    -- slow memory module, bypass the synchronous registers
    -- also an intentional latch when stalling
    ID_instruction <= imem_data_in when was_stalling = '0' else ID_instruction;

    -----------------------------------------------------------------
    -- ID --> EX
    -----------------------------------------------------------------
    IDEX_pc : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => ID_pc_address, out_value => EX_pc_address);

    IDEX_read_data_1 : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => ID_read_data_1, out_value => EX_read_data_1);

    IDEX_read_data_2 : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => ID_read_data_2, out_value => EX_read_data_2);

    IDEX_read_imm_value : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => ID_immediate_value_transformed, out_value => EX_immediate_value);

    IDEX_jump_value : entity work.generic_register
    generic map(WIDTH => jump_value_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => j_value(ID_instruction), out_value => EX_jump_value);

    IDEX_shift_amount : entity work.generic_register
    generic map(WIDTH => shift_amount_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => shift_amount(ID_instruction), out_value => EX_shift_amount);

    IDEX_rs : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => rs(ID_instruction), out_value => EX_rs);

    IDEX_rt : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => rt(ID_instruction), out_value => EX_rt);

    IDEX_rd : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset_or_flush, clock => clock, in_value => rd(ID_instruction), out_value => EX_rd);

    IDEX_forward_WB_signals : entity work.WB_register 
    port map(reset => reset_or_flush, clock => clock, in_value => ID_forward_WB_signals, out_value => EX_forward_WB_signals);

    IDEX_forward_MEM_signals : entity work.MEM_register 
    port map(reset => reset_or_flush, clock => clock, in_value => ID_forward_MEM_signals, out_value => EX_forward_MEM_signals);

    IDEX_forward_EX_signals : entity work.EX_register 
    port map(reset => reset_or_flush, clock => clock, in_value => ID_forward_EX_signals, out_value => EX_control_signals);

    -----------------------------------------------------------------
    -- EX --> MEM
    -----------------------------------------------------------------
    EXMEM_jump_address : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, clock => clock, in_value => EX_jump_address, out_value => MEM_jump_address);

    EXMEM_branch_address : entity work.generic_register
    generic map(WIDTH => pc_t'length)
    port map(reset => reset, clock => clock, in_value => EX_branch_address, out_value => MEM_branch_address);

    EXMEM_alu_zero : entity work.bit_register
    port map(reset => reset, clock => clock, in_value => EX_alu_zero, out_value => MEM_alu_zero);

    EXMEM_alu_result : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, clock => clock, in_value => EX_alu_result, out_value => MEM_alu_result);

    EXMEM_read_data_2 : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, clock => clock, in_value => EX_operand_2_source, out_value => MEM_write_data);

    EXMEM_write_register : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset, clock => clock, in_value => EX_write_register, out_value => MEM_write_register);

    EXMEM_forward_WB_signals : entity work.WB_register 
    port map(reset => reset, clock => clock, in_value => EX_forward_WB_signals, out_value => MEM_forward_WB_signals);

    EXMEM_forward_MEM_signals : entity work.MEM_register 
    port map(reset => reset, clock => clock, in_value => EX_forward_MEM_signals, out_value => MEM_control_signals);

    -----------------------------------------------------------------
    -- MEM --> WB
    -----------------------------------------------------------------
    -- slow memory module, bypass the synchronous registers
    WB_read_data <= dmem_data_in;

    MEMWB_alu_result : entity work.generic_register
    generic map(WIDTH => operand_t'length)
    port map(reset => reset, clock => clock, in_value => MEM_alu_result, out_value => WB_alu_result);

    MEMWB_write_register : entity work.generic_register
    generic map(WIDTH => register_address_t'length)
    port map(reset => reset, clock => clock, in_value => MEM_write_register, out_value => WB_write_register);

    MEMWB_forward_WB_signals : entity work.WB_register 
    port map(reset => reset, clock => clock, in_value => MEM_forward_WB_signals, out_value => WB_control_signals);

end Behavioral;
