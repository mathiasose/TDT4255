library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity control is
    generic (
        ADDR_WIDTH : integer := 8;
        DATA_WIDTH : integer := 32
    );
    port(
        clock : in std_logic;
        reset : in std_logic;
        processor_enable : in std_logic := '0';
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
end control;

architecture Behavioral of control is
    signal opcode : opcode_t;
    signal funct : std_logic_vector(5 downto 0);

    constant INIT_STATE : state_t := STALL;
    signal state : state_t := INIT_STATE;
    signal next_state: state_t;
begin
    opcode <= instruction(31 downto 26);
    funct <= instruction(5 downto 0);
    --rs <= instruction(25 downto 21);
    --rt <= instruction(20 downto 16);
    --rd <= instruction(15 downto 11);
    --immediate_value <= instruction(15 downto 0);

    DrivingOutputs : process(state, opcode, processor_enable) is
    begin
        -- Setting defaults to avoid latches
        reg_dst <= '0';
        branch <= '0';
        jump <= '0';
        --mem_read <= '0';
        mem_to_reg <= '0';
        alu_op <= NO_OP;
        mem_write <= '0';
        alu_src <= '0';
        reg_write <= '0';
        pc_write <= '0';

        if processor_enable = '1' then
            -- Non default outputs
            case state is
                when FETCH =>
                    next_state <= EXECUTE;
                    pc_write <= '1';

                    case opcode is
                        when ALU_OP_OPCODE =>
                            --
                        when jump_OPCODE =>
                            --
                        when BEQ_OPCODE =>
                            --
                        when LW_OPCODE =>
                            --
                        when SW_OPCODE =>
                            --
                        when LUI_OPCODE =>
                            --
                        when others =>
                            --
                    end case;
                when EXECUTE =>
                    case opcode is
                        when ALU_OP_OPCODE =>
                            next_state <= FETCH;

                            reg_write <= '1';
                            reg_dst <= '1';
                            case funct is
                                when "100000" =>
                                    alu_op <= ADD;
                                when "100010" =>
                                    alu_op <= SUB;
                                when "100100" =>
                                    alu_op <= ALU_AND;
                                when "100101" =>
                                    alu_op <= ALU_OR;
                                when "101010" =>
                                    alu_op <= SLT;
                                when others =>
                                    alu_op <= NO_OP;
                            end case;
                        when jump_OPCODE =>
                            next_state <= FETCH;

                            jump <= '1';
                        when BEQ_OPCODE =>
                            next_state <= FETCH;

                            alu_src <= '1';
                            branch <= '1';
                        when LW_OPCODE =>
                            next_state <= STALL;

                            alu_src <= '1';
                            alu_op <= ADD;
                            mem_to_reg <= '1';
                            reg_write <= '1';
                        when SW_OPCODE =>
                            next_state <= STALL;

                            alu_src <= '1';
                            alu_op <= ADD;
                            mem_write <= '1';
                        when LUI_OPCODE =>
                            alu_src <= '1';
                            next_state <= FETCH;
                        when others =>
                            next_state <= FETCH;
                    end case;
                when STALL =>
                    next_state <= FETCH;
                    case opcode is
                        when ALU_OP_OPCODE =>
                            --
                        when jump_OPCODE =>
                            --
                        when BEQ_OPCODE =>
                            --
                        when LW_OPCODE =>
                            alu_src <= '1';
                            alu_op <= ADD;
                            mem_to_reg <= '1';
                            reg_write <= '1';
                        when SW_OPCODE =>
                            alu_src <= '1';
                            alu_op <= ADD;
                            mem_write <= '1';
                        when LUI_OPCODE =>
                            --
                        when others =>
                            --
                    end case;
                when others =>
                    --
            end case;
        end if;
    end process DrivingOutputs;

    process (clock, reset, processor_enable) is
    begin
        if reset = '1' then
            state <= INIT_STATE;
        elsif rising_edge(clock) and processor_enable = '1' then
            state <= next_state;
        end if;
    end process;
end Behavioral;

