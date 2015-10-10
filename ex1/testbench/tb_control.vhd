    LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;
use work.testutil.all;
 
ENTITY tb_control IS
END tb_control;
 
ARCHITECTURE behavior OF tb_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT control
    port(
        clk : in std_logic;
        reset : in std_logic;
        instruction : in instruction_t;
        ALUOp : out alu_operation_t;
        ALUSrc : out std_logic;
        Branch : out std_logic;
        Jump : out std_logic;
        MemRead : out std_logic;
        MemtoReg : out std_logic;
        MemWrite : out std_logic;
        RegDst : out std_logic;
        RegWrite : out std_logic
    );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal instruction : std_logic_vector(31 downto 0) := (others => '0');

     --Outputs
   signal RegDst : std_logic;
   signal Branch : std_logic;
   signal Jump : std_logic;
   signal MemRead : std_logic;
   signal MemtoReg : std_logic;
   signal ALUOp : alu_operation_t;
   signal MemWrite : std_logic;
   signal ALUSrc : std_logic;
   signal RegWrite : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: control PORT MAP (
          clk => clk,
          reset => reset,
          instruction => instruction,
          RegDst => RegDst,
          Branch => Branch,
          Jump => Jump,
          MemRead => MemRead,
          MemtoReg => MemtoReg,
          ALUOp => ALUOp,
          MemWrite => MemWrite,
          ALUSrc => ALUSrc,
          RegWrite => RegWrite
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      -- resets to state STALL

      wait for clk_period; -- go to fetch
      instruction <= x"00221820"; --add $3, $1, $2
      wait for clk_period; -- go to execute
      check(ALUOP = ADD, "ADD instruction sets ALUOp to ADD");
      check(RegWrite = '1', "ADD instruction sets RegWrite high");

      wait for clk_period; -- go to fetch
      instruction <= x"00622022"; --sub $4, $3, $2
      wait for clk_period; -- go to execute
      check(ALUOP = SUB, "SUB instruction sets ALUOp to SUB");
      check(RegWrite = '1', "SUB instruction sets RegWrite high");

      wait for clk_period; -- go to fetch
      instruction <= x"00432024"; --and $4, $2, $3
      wait for clk_period; -- go to execute
      check(ALUOP = ALU_AND, "AND instruction sets ALUOp to AND");
      check(RegWrite = '1', "AND instruction sets RegWrite high");

      wait for clk_period; -- go to fetch
      instruction <= x"00432825"; --or $5, $2, $3
      wait for clk_period; -- go to execute
      check(ALUOP = ALU_OR, "OR instruction sets ALUOp to OR");
      check(RegWrite = '1', "OR instruction sets RegWrite high");

      wait for clk_period; -- go to fetch
      instruction <= x"0001982A"; --slt $19, $0, $1
      wait for clk_period; -- go to execute
      check(ALUOP = SLT, "SLT instruction sets ALUOp to SLT");
      check(RegWrite = '1', "SLT instruction sets RegWrite high");

      wait for clk_period; -- go to fetch
      instruction <= x"08000013"; --j 19
      wait for clk_period; -- go to execute
      check(Jump = '1', "Jump instructions sets jump flag high");

      wait for clk_period; -- go to fetch
      instruction <= x"10000002"; --beq $0, $0, 2
      wait for clk_period; -- go to execute
      check(Jump = '0', "Jump flag goes back to low");
      check(Branch = '1', "Branch instructions sets branch flag high");

      wait for clk_period; -- go to fetch
      instruction <= x"00000000";
      wait for clk_period; -- go to execute
      check(Branch = '0', "Branch flag goes back to low");

      wait for clk_period; -- go to fetch
      instruction <= x"8C010001"; --lw $1, 1($0)
      wait for clk_period; -- go to execute
      wait for clk_period; -- go to stall
      check(MemtoReg = '1', "LW instruction sets MemtoReg high in STALL state");

      wait for clk_period; -- go to fetch
      instruction <= x"AC030005"; --sw $3, 5($0)
      wait for clk_period; -- go to execute
      check(MemWrite = '1', "SW instruction sets MemWrite high in EXECUTE state");
      wait for clk_period; -- go to stall

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
