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
        processor_enable            : in std_logic := '0';
        instruction                 : in instruction_t;

        immediate_value_transform   : out immediate_value_transformation_t;

        wb_signals                  : out wb_signals_t;
        mem_signals                 : out mem_signals_t;
        ex_signals                  : out ex_signals_t
    );
    END COMPONENT;

   --Inputs
   signal processor_enable : std_logic := '0';
   signal instruction : std_logic_vector(31 downto 0) := (others => '0');

     --Outputs

   signal immediate_value_transform : immediate_value_transformation_t;
   signal wb_signals : wb_signals_t;
   signal mem_signals : mem_signals_t;
   signal ex_signals : ex_signals_t;

   -- Clock period definitions
   constant clock_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: control PORT MAP (
          processor_enable => processor_enable,
          instruction => instruction,
          immediate_value_transform => immediate_value_transform,
          wb_signals => wb_signals,
          mem_signals => mem_signals,
          ex_signals => ex_signals
        );

   stim_proc: process
   begin
      processor_enable <= '1';
      wait for clock_period; -- go to fetch
      instruction <= x"00221820"; --add $3, $1, $2
      wait for clock_period; -- go to execute
      check(ex_signals.alu_op = ADD, "ADD instruction sets alu_op to ADD");
      check(wb_signals.reg_write = '1', "ADD instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"00622022"; --sub $4, $3, $2
      wait for clock_period; -- go to execute
      check(ex_signals.alu_op = SUB, "SUB instruction sets alu_op to SUB");
      check(wb_signals.reg_write = '1', "SUB instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"00432024"; --and $4, $2, $3
      wait for clock_period; -- go to execute
      check(ex_signals.alu_op = ALU_AND, "AND instruction sets alu_op to AND");
      check(wb_signals.reg_write = '1', "AND instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"00432825"; --or $5, $2, $3
      wait for clock_period; -- go to execute
      check(ex_signals.alu_op = ALU_OR, "OR instruction sets alu_op to OR");
      check(wb_signals.reg_write = '1', "OR instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"0001982A"; --slt $19, $0, $1
      wait for clock_period; -- go to execute
      check(ex_signals.alu_op = SLT, "SLT instruction sets alu_op to SLT");
      check(wb_signals.reg_write = '1', "SLT instruction sets reg_write high");

      wait for clock_period; -- go to fetch
      instruction <= x"08000013"; --j 19
      wait for clock_period; -- go to execute
      check(mem_signals.jump = '1', "jump instructions sets jump flag high");

      wait for clock_period; -- go to fetch
      instruction <= x"10000002"; --beq $0, $0, 2
      wait for clock_period; -- go to execute
      check(mem_signals.jump = '0', "jump flag goes back to low");
      check(mem_signals.branch = '1', "branch instructions sets branch flag high");

      wait for clock_period; -- go to fetch
      instruction <= x"00000000";
      wait for clock_period; -- go to execute
      check(mem_signals.branch = '0', "branch flag goes back to low");

      wait for clock_period; -- go to fetch
      instruction <= x"8C010001"; --lw $1, 1($0)
      wait for clock_period; -- go to execute
      wait for clock_period; -- go to stall
      check(wb_signals.mem_to_reg = '1', "LW instruction sets mem_to_reg high in STALL state");

      wait for clock_period; -- go to fetch
      instruction <= x"AC030005"; --sw $3, 5($0)
      wait for clock_period; -- go to execute
      check(mem_signals.mem_write = '1', "SW instruction sets mem_write high in EXECUTE state");
      wait for clock_period; -- go to stall

      wait for clock_period; -- go to fetch
      instruction <= x"3C030006"; --lui $3, 6
      wait for clock_period; -- go to execute
      check(wb_signals.reg_write = '1', "LUI sets reg_write");
      check(immediate_value_transform = SHIFT_LEFT, "LUI sets transform to SHIFT_LEFT");
      wait for clock_period; -- go to stall

      report "ALL TESTS SUCCESSFUL";
      wait;
   end process;

END;
