-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- MIPSProcessor.vhd
-- The MIPS processor component to be used in Exercise 1 and 2.

-- TODO replace the architecture DummyArch with a working Behavioral

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
        clk, reset                 : in std_logic;
        processor_enable        : in std_logic;
        imem_data_in            : in std_logic_vector(DATA_WIDTH-1 downto 0);
        imem_address            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        dmem_data_in            : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dmem_address            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        dmem_data_out            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        dmem_write_enable        : out std_logic
    );
end entity MIPSProcessor;

architecture NotSoDummyArch of MIPSProcessor is
    signal ALUOp : alu_operation_t;
    signal ALUSrc : std_logic;
    signal Branch : std_logic;
    signal Jump : std_logic;
    signal MemtoReg : std_logic;
    signal RegDst : std_logic;
    signal RegWrite : std_logic;
begin

    process(clk, reset)
    begin
        if reset = '1' then

        elsif rising_edge(clk) then
            if processor_enable = '1' then

            end if;
        end if;
    end process;

    control : entity work.control
    port map(
        clk => clk,
        reset => reset,
        instruction => imem_data_in,
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        Jump => Jump,
        --MemRead => MemRead,
        MemtoReg => MemtoReg,
        MemWrite => dmem_write_enable,
        RegDst => RegDst,
        RegWrite => RegWrite
    );

end NotSoDummyArch;

