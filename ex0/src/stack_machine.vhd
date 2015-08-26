library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity stack_machine is

  generic (
    size : natural := 1024);

  port (
    clk : in std_logic;
    rst : in std_logic;

    instruction : in  instruction_t;
    empty       : in  std_logic;
    read        : out std_logic;

    result : out operand_t);

end entity stack_machine;

architecture behavioural of stack_machine is

-- Stack signals
  signal stack_in  : operand_t;
  signal stack_top : operand_t;

-- Control signals
  signal push      : std_logic;
  signal pop       : std_logic;
  signal operand   : operand_t;
  signal stack_src : stack_input_select_t;
  signal a_wen     : std_logic;
  signal b_wen     : std_logic;
  signal alu_op    : alu_operation_t;

-- Operand registers
  signal a : signed(7 downto 0);
  signal b : signed(7 downto 0);

-- Intermediate alu result signal
  signal alu_result : signed(7 downto 0);

begin  -- architecture behavioural

  result <= stack_top;

  with stack_src select
    stack_in <=
    operand                      when STACK_INPUT_OPERAND,
    std_logic_vector(alu_result) when others;

  with alu_op select
    alu_result <=
    a + b when ALU_ADD,
    a - b when others;

  operand_regs : process (clk, rst) is
  begin  -- process operand_regs
    if rst = '1' then                   -- asynchronous reset
      a <= (others => '0');
      b <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if a_wen = '1' then
        a <= signed(stack_top);
      end if;
      if b_wen = '1' then
        b <= signed(stack_top);
      end if;
    end if;
  end process operand_regs;

  control : entity work.control
    port map (
      clk         => clk,
      rst         => rst,
      instruction => instruction,
      empty       => empty,
      read        => read,
      push        => push,
      pop         => pop,
      stack_src   => stack_src,
      operand     => operand,
      a_wen       => a_wen,
      b_wen       => b_wen,
      alu_sel     => alu_op);

  stack : entity work.stack
    generic map (
      size => size)
    port map (
      clk      => clk,
      rst      => rst,
      value_in => stack_in,
      push     => push,
      pop      => pop,
      top      => stack_top);

end architecture behavioural;

