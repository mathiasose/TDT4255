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
  signal state: signed(2 downto 0);
  
  signal opcode : opcode_t;

begin  -- architecture behavioural

  -- Fill in processes here.
  
  rst_handler : process (rst) is
  begin
    if rst = '1' then
      state <= "000";

      read <= '0';
      b_wen <= '0';
      a_wen <= '0';
      pop <= '0';
      push <= '0';
    end if;
  end process rst_handler;
  
  clk_handler : process (clk) is
  begin
    if rising_edge(clk) then
      if state = "000" and empty = '0' then
        state <= "001";
      elsif state = "001" then
        read <= '1';
        state <= "010";
      elsif state = "010" then
        if opcode = (others => '0') then
          state <= "111";
        else
          state <= "011";
        end if;
      elsif state = "011" then
        b_wen <= '1';
        pop <= '1';
        state <= "100";
      elsif state = "100" then
        a_wen <= '1';
        pop <= '1';
        state <= "101";
      elsif state = "101" then
        alu_sel <= ALU_SUB when (opcode = (1 => '1', others => '0')) else ALU_ADD;
        state <= "110";
      elsif state = "110" then
        stack_src <= STACK_INPUT_RESULT;
        alu_sel <= ALU_SUB when (opcode = (1 => '1', others => '0')) else ALU_ADD;
        push <= '1';
        state <= "000";
      elsif state = "111" then
        stack_src <= STACK_INPUT_OPERAND;
        push <= '1';
        state <= "000";
      end if;
    end if;
  end process clk_handler;
  
  opcode <= instruction(15 downto 8);
  operand <= instruction(7 downto 0);

end architecture behavioural;
