library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity control is
  
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- Communication
    instruction : in  instruction_t;
    empty       : in  std_logic;
    read        : out std_logic;

    -- Stack control
    push      : out std_logic;
    pop       : out std_logic;
    stack_src : out stack_input_select_t;
    operand   : out operand_t;

    -- ALU control
    a_wen   : out std_logic;
    b_wen   : out std_logic;
    alu_sel : out alu_operation_t);


end entity control;

architecture behavioural of control is

  -- Fill in type and signal declarations here.
  signal state: signed(2 downto 0) := (others => '0');
  
  signal opcode : opcode_t;

begin  -- architecture behavioural

  -- Fill in processes here.
  
  clk_handler : process (clk, rst) is
  begin
    if rst = '1' then
      state <= "000";
    elsif rising_edge(clk) then
      if state = "000" and empty = '0' then
        state <= "001";
      elsif state = "001" then
        state <= "010";
      elsif state = "010" then
        if opcode = "00000000" then
          state <= "111";
        else
          state <= "011";
        end if;
      elsif state = "011" then
        state <= "100";
      elsif state = "100" then
        state <= "101";
      elsif state = "101" then
        state <= "110";
      elsif state = "110" then
        state <= "000";
      elsif state = "111" then
        state <= "000";
      end if;
    end if;
  end process clk_handler;
  
  opcode <= instruction(15 downto 8);
  operand <= instruction(7 downto 0);

    read <= '1' when state = "001" else '0';
    b_wen <= '1' when state = "011" else '0';
    a_wen <= '1' when state = "100" else '0';
    pop <= '1' when (state = "011" or state = "100") else '0';
    push <= '1' when (state = "110" or state = "111") else '0';

    stack_src <= STACK_INPUT_OPERAND when state = "111" else STACK_INPUT_RESULT;
    alu_sel <= ALU_SUB when opcode = "00000010" else ALU_ADD;

end architecture behavioural;
