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
        clock : in std_logic;
        reset : in std_logic;
        instruction : in instruction_t;
        alu_op : out alu_operation_t;
        alu_src : out std_logic;
        branch : out std_logic;
        jump : out std_logic;
        --mem_read : out std_logic;
        mem_to_reg : out std_logic;
        mem_write : out std_logic;
        reg_dst : out std_logic;
        reg_write : out std_logic;
        pc_write : out std_logic
    );
    END COMPONENT;

   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal instruction : std_logic_vector(31 downto 0) := (others => '0');

     --Outputs
   signal reg_dst : std_logic;
   signal branch : std_logic;
   signal jump : std_logic;
   signal mem_read : std_logic;
   signal mem_to_reg : std_logic;
   signal alu_op : alu_operation_t;
   signal mem_write : std_logic;
   signal alu_src : std_logic;
   signal reg_write : std_logic;
   signal pc_write : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: control PORT MAP (
          clock => clock,
          reset => reset,
          instruction => instruction,
          reg_dst => reg_dst,
          branch => branch,
          jump => jump,
          --mem_read => mem_read,
          mem_to_reg => mem_to_reg,
          alu_op => alu_op,
          mem_write => mem_write,
          alu_src => alu_src,
          reg_write => reg_write,
          pc_write => pc_write
        );

   -- Clock process definitions
   clock_process :process
   begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      -- resets to state STALL

      wait for clock_period; -- go to fetch
      instruction <= x"00221820"; --add $3, $1, $2
      wait for clock_period; -- go to execute
      check(alu_op = ADD, "ADD instruction sets alu_op to ADD");
      check(reg_write = '1', "ADD instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"00622022"; --sub $4, $3, $2
      wait for clock_period; -- go to execute
      check(alu_op = SUB, "SUB instruction sets alu_op to SUB");
      check(reg_write = '1', "SUB instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"00432024"; --and $4, $2, $3
      wait for clock_period; -- go to execute
      check(alu_op = ALU_AND, "AND instruction sets alu_op to AND");
      check(reg_write = '1', "AND instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"00432825"; --or $5, $2, $3
      wait for clock_period; -- go to execute
      check(alu_op = ALU_OR, "OR instruction sets alu_op to OR");
      check(reg_write = '1', "OR instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"0001982A"; --slt $19, $0, $1
      wait for clock_period; -- go to execute
      check(alu_op = SLT, "SLT instruction sets alu_op to SLT");
      check(reg_write = '1', "SLT instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"08000013"; --j 19
      wait for clock_period; -- go to execute
      check(jump = '1', "jump instructions sets jump flag high");

      wait for clock_period; -- go to fetch
      instruction <= x"10000002"; --beq $0, $0, 2
      wait for clock_period; -- go to execute
      check(jump = '0', "jump flag goes back to low");
      check(branch = '1', "branch instructions sets branch flag high");

      wait for clock_period; -- go to fetch
      instruction <= x"00000000";
      wait for clock_period; -- go to execute
      check(branch = '0', "branch flag goes back to low");

      wait for clock_period; -- go to fetch
      instruction <= x"8C010001"; --lw $1, 1($0)
      wait for clock_period; -- go to execute
      wait for clock_period; -- go to stall
      check(mem_to_reg = '1', "LW instruction sets mem_to_reg high in STALL state");

      wait for clock_period; -- go to fetch
      instruction <= x"AC030005"; --sw $3, 5($0)
      wait for clock_period; -- go to execute
      check(mem_write = '1', "SW instruction sets mem_write high in EXECUTE state");
      wait for clock_period; -- go to stall
      
      wait for clock_period; -- go to fetch
      check(pc_write = '1', "Program counter write signal should go high in fetch state");
      wait for clock_period; -- go to execute
      wait for clock_period; -- go to stall

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
