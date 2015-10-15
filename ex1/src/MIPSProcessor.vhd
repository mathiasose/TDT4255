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
        clock, reset : in std_logic := '0';
        processor_enable : in std_logic := '0';
        imem_data_in : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        imem_address : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        dmem_data_in : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        dmem_address : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        dmem_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        dmem_write_enable : out std_logic := '0'
    );
end entity MIPSProcessor;

architecture Behavioral of MIPSProcessor is
    signal alu_op : alu_operation_t;
    signal alu_src : std_logic;
    signal branch : std_logic;
    signal jump : std_logic;
    signal mem_to_reg : std_logic;
    signal reg_dst : std_logic;
    signal reg_write : std_logic;
    signal alu_zero : std_logic;
    signal reg_out_a : operand_t;
    signal reg_out_b : operand_t;
    signal operand_b : operand_t;
    signal alu_result : operand_t;
    signal write_register : register_address_t;
    signal write_data : operand_t;
    signal pc_write_enable : std_logic;
    signal pc_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal mem_write : std_logic;
    signal immediate_value_transformed : operand_t;
    signal control_immediate_value_transform : immediate_value_transformation_t;
begin

    -- processor_enable dependent wirings
    imem_address <= pc_addr when processor_enable = '1' else (others => '0');
    dmem_address <= alu_result(ADDR_WIDTH-1 downto 0) when processor_enable = '1' else (others => '0');
    dmem_write_enable <= mem_write when processor_enable = '1' else '0';
    dmem_data_out <= reg_out_b when processor_enable = '1' else (others => '0');

    -- other wirings
    operand_b <= immediate_value_transformed when alu_src = '1' else reg_out_b;
    write_data <= dmem_data_in when mem_to_reg = '1' else alu_result;
    write_register <= imem_data_in(15 downto 11) when reg_dst = '1' else imem_data_in(20 downto 16);

    control : entity work.control
    port map(
        clock => clock,
        reset => reset,
        processor_enable => processor_enable,
        instruction => imem_data_in,
        alu_op => alu_op,
        alu_src => alu_src,
        branch => branch,
        jump => jump,
        --mem_read => mem_read,
        mem_to_reg => mem_to_reg,
        mem_write => mem_write,
        reg_dst => reg_dst,
        reg_write => reg_write,
        pc_write => pc_write_enable,
        immediate_value_transform => control_immediate_value_transform
    );

    alu : entity work.alu
    port map (
        clock => clock,
        reset => reset,
        operation => alu_op,
        operand_A => reg_out_a,
        operand_B => operand_b,
        shift_amount => imem_data_in(11 downto 6),
        result => alu_result,
        zero => alu_zero
    );

    pc : entity work.pc
    port map (
        clock => clock,
        reset => reset,
        instruction => imem_data_in,
        jump => jump,
        branch => branch,
        alu_zero => alu_zero,
        addr_out => pc_addr,
        write_enable => pc_write_enable
    );

    registers : entity work.registers
    port map (
        clock => clock,
        read_register_1 => imem_data_in(25 downto 21),
        read_register_2 => imem_data_in(20 downto 16),
        write_register => write_register,
        write_data => write_data,
        read_data_1 => reg_out_a,
        read_data_2 => reg_out_b,
        register_write => reg_write
    );

    immediate_value_transform : entity work.immediate_value_transform
    port map (
        transform => control_immediate_value_transform,
        in_value => imem_data_in(15 downto 0),
        out_value => immediate_value_transformed
    );

end Behavioral;

