-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- tb_shifting.vhd
-- Testbench for the MIPSProcessor component
-- Instantiates data and instruction memory, fills them with some
-- test data, enables the processor, then checks the data memory
-- to see if the expected values have been written.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;

ENTITY tb_shifting IS
END tb_shifting;

ARCHITECTURE behavior OF tb_shifting IS
    constant ADDR_WIDTH : integer := 8;
    constant DATA_WIDTH : integer := 32;

    --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal processor_enable : std_logic := '0';
   signal imem_data_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal dmem_data_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

     --multiplexed memory outputs
   signal imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
   signal dmem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
   signal dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal dmem_write_enable : std_logic_vector(0 downto 0) := (others => '0');

    -- driven only from processor
    signal proc_imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal proc_dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal proc_dmem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
    signal proc_dmem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

    -- driven only from testbench
    signal imem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal imem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
    signal tb_imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal tb_dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal tb_dmem_write_enable : std_logic_vector(0 downto 0) := (others => '0');
    signal tb_dmem_address : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

   -- Clock period definitions
   constant clock_period : time := 10 ns;
BEGIN
-- Instantiate the processor
Processor: entity work.MIPSProcessor(Behavioral) port map (
                        clock => clock,    reset => reset,
                        processor_enable => processor_enable,
                        imem_data_in => imem_data_in,
                        imem_address => proc_imem_address,
                        dmem_data_in => dmem_data_in,
                        dmem_address => proc_dmem_address,
                        dmem_data_out => proc_dmem_data_out,
                        dmem_write_enable => proc_dmem_write_enable(0)
                    );

-- instantiate the instruction memory
InstrMem:        entity work.DualPortMem port map (
                        clka => clock, clkb => clock,
                        wea => imem_write_enable, 
                        dina => imem_data_out,
                        addra => imem_address, douta => imem_data_in,
                        -- plug unused memory port
                        web => "0", dinb => x"00", addrb => "0000000000"
                    );
 
 -- instantiate the data memory
DataMem:            entity work.DualPortMem port map (
                        clka => clock, clkb => clock,
                        wea => dmem_write_enable, dina => dmem_data_out,
                        addra => dmem_address, douta => dmem_data_in,
                        -- plug unused memory port
                        web => "0", dinb => x"00", addrb => "0000000000"
                    );

   -- Clock process definitions
   clock_process :process
   begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
   end process;

    imem_address <= proc_imem_address when processor_enable = '1' else tb_imem_address;
    dmem_address <= proc_dmem_address when processor_enable = '1' else tb_dmem_address;
    dmem_data_out <= proc_dmem_data_out when processor_enable = '1' else tb_dmem_data_out;
    dmem_write_enable <= proc_dmem_write_enable when processor_enable = '1' else tb_dmem_write_enable;

   -- Stimulus process
   stim_proc: process
        -- helper procedures for filling instruction memory
         procedure WriteInstructionWord(
            instruction : in std_logic_vector(DATA_WIDTH-1 downto 0);
            address : in unsigned(ADDR_WIDTH-1 downto 0)) is
        begin
            tb_imem_address <= std_logic_vector(address);
            imem_data_out <= instruction;
            imem_write_enable <= "1";
            wait until rising_edge(clock);
            imem_write_enable <= "0";
        end WriteInstructionWord;

        procedure FillInstructionMemory is
            constant TEST_INSTRS : integer := 12;
            type InstrData is array (0 to TEST_INSTRS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
            variable TestInstrData : InstrData := (
                X"8C010001", -- lw $1, 1($0)
                X"8C020002", -- lw $2, 2($0)
                ALU_OP_OPCODE & "00000" & "00001" & "00011" & "00001" & SLL_FUNCT, -- sll $3, $1, 1
                ALU_OP_OPCODE & "00000" & "00001" & "00100" & "00001" & SRL_FUNCT, -- srl $4, $1, 1
                ALU_OP_OPCODE & "00000" & "00001" & "00101" & "00001" & SRA_FUNCT, -- sra $5, $1, 1
                ALU_OP_OPCODE & "00000" & "00010" & "00110" & "00001" & SRL_FUNCT, -- srl $6, $2, 1
                ALU_OP_OPCODE & "00000" & "00010" & "00111" & "00001" & SRA_FUNCT, -- sra $7, $2, 1
                X"AC030003", -- sw $3, 3($0)
                X"AC040004", -- sw $4, 4($0)
                X"AC050005", -- sw $5, 5($0)
                X"AC060006", -- sw $6, 6($0)
                X"AC070007"  -- sw $7, 7($0)
            );
        begin
            for i in 0 to TEST_INSTRS-1 loop
                WriteInstructionWord(TestInstrData(i), to_unsigned(i, ADDR_WIDTH));
            end loop;
        end FillInstructionMemory;

        -- helper procedures for filling data memory
         procedure WriteDataWord(
            data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            address : in integer) is
        begin
            tb_dmem_address <= std_logic_vector(to_unsigned(address, ADDR_WIDTH));
            tb_dmem_data_out <= data;
            tb_dmem_write_enable <= "1";
            wait until rising_edge(clock);
            tb_dmem_write_enable <= "0";
        end WriteDataWord;

        procedure FillDataMemory is
        begin
            WriteDataWord(x"00000002", 1);
            WriteDataWord(x"80000000", 2);
        end FillDataMemory;

        -- helper procedures for checking the contents of data memory after
        -- the processor has finished executing the tests
        procedure CheckDataWord(
            data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            address : in integer) is
        begin

            tb_dmem_address <= std_logic_vector(to_unsigned(address, ADDR_WIDTH));
            tb_dmem_write_enable <= "0";
            wait until rising_edge(clock);
            wait for 0.5 * clock_period;
            assert data = dmem_data_in report "Expected data not found at datamem addr "
                                                    & integer'image(address) & " found = "
                                                    & integer'image(to_integer(unsigned(dmem_data_in)))
                                                    & " expected "
                                                    & integer'image(to_integer(unsigned(data)))
                                                    severity note;
            assert data /= dmem_data_in report "Expected data found at datamem addr " & integer'image(address) severity note;
        end CheckDataWord;

        procedure CheckDataMemory is
        begin
            wait until processor_enable = '0';
            -- expected data memory contents, derived from program behavior
            CheckDataWord(x"0000000" & "0100", 3);
            CheckDataWord(x"0000000" & "0001", 4);
            CheckDataWord(x"0000000" & "0001", 5);
            CheckDataWord("0100" & x"0000000", 6);
            CheckDataWord("1100" & x"0000000", 7);
        end CheckDataMemory;

   begin
      -- hold reset state for 100 ns
        reset <= '1';
      wait for 100 ns;
        reset <= '0';

        processor_enable <= '0';
        -- fill instruction and data mems with test data
        FillInstructionMemory;
        FillDataMemory;

      wait for clock_period*10;

      -- enable the processor
        processor_enable <= '1';
        -- execute for 200 cycles and stop
        wait for clock_period*200;

        processor_enable <= '0';

        -- check the results
        CheckDataMemory;

      wait;
   end process;

END;
