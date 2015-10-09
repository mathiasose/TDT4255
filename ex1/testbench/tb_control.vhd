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
      wait for clk_period;

      instruction <= x"00221820"; --add $3, $1, $2
      wait for clk_period;
      check(ALUOP = ADD, "Add instruction sets ALUOp to ADD");
      check(RegWrite = '1', "Add instruction sets RegWrite high");

      report "ALL TESTS SUCCESSFUL";

      wait;
   end process;

END;
