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
        pc_write : out std_logic;
        immediate_value_transform: out immediate_value_transformation_t
    );
end control;

architecture Behavioral of control is
    signal opcode : opcode_t;
    signal funct : funct_t;

    constant INIT_STATE : state_t := STALL;
    constant INIT_NEXT_STATE : state_t := FETCH;
    signal state : state_t := INIT_STATE;
    signal next_state: state_t := INIT_NEXT_STATE;
begin
    opcode <= instruction(31 downto 26);
    funct <= instruction(5 downto 0);

    DrivingOutputs : process(state, funct, opcode, processor_enable) is
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
        immediate_value_transform <= SIGN_EXTEND;
        next_state <= INIT_NEXT_STATE;

        if processor_enable = '1' then
            -- Non default outputs
            case state is
                when FETCH =>
                    next_state <= EXECUTE;
                when EXECUTE =>
                    case opcode is
                        when ALU_OP_OPCODE =>
                            next_state <= FETCH;

                            pc_write <= '1';
                            reg_write <= '1';
                            reg_dst <= '1';
                            case funct is
                                when ADD_FUNCT =>
                                    alu_op <= ADD;
                                when SUB_FUNCT =>
                                    alu_op <= SUB;
                                when AND_FUNCT =>
                                    alu_op <= ALU_AND;
                                when OR_FUNCT =>
                                    alu_op <= ALU_OR;
                                when SLT_FUNCT =>
                                    alu_op <= SLT;
                                when NOR_FUNCT =>
                                    alu_op <= ALU_NOR;
                                when XOR_FUNCT =>
                                    alu_op <= ALU_XOR;
                                when SLL_FUNCT =>
                                    alu_op <= ALU_SLL;
                                when SRL_FUNCT =>
                                    alu_op <= ALU_SRL;
                                when SRA_FUNCT =>
                                    alu_op <= ALU_SRA;
                                when others =>
                                    alu_op <= NO_OP;
                            end case;
                        when jump_OPCODE =>
                            next_state <= FETCH;

                            pc_write <= '1';
                            jump <= '1';
                        when BEQ_OPCODE =>
                            next_state <= FETCH;

                            alu_op <= SUB;
                            pc_write <= '1';
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
                            next_state <= FETCH;

                            alu_src <= '1';
                            pc_write <= '1';
                            reg_write <= '1';
                            immediate_value_transform <= SHIFT_LEFT;
                        when ADDI_OPCODE =>
                            next_state <= FETCH;

                            alu_op <= ADD;
                            alu_src <= '1';
                            pc_write <= '1';
                            reg_write <= '1';
                        when ANDI_OPCODE =>
                            next_state <= FETCH;

                            alu_op <= ALU_AND;
                            alu_src <= '1';
                            pc_write <= '1';
                            reg_write <= '1';
                        when ORI_OPCODE =>
                            next_state <= FETCH;

                            alu_op <= ALU_OR;
                            alu_src <= '1';
                            pc_write <= '1';
                            reg_write <= '1';
                        when XORI_OPCODE =>
                            next_state <= FETCH;

                            alu_op <= ALU_XOR;
                            alu_src <= '1';
                            pc_write <= '1';
                            reg_write <= '1';
                        when SLTI_OPCODE =>
                            next_state <= FETCH;

                            alu_op <= SLT;
                            alu_src <= '1';
                            pc_write <= '1';
                            reg_write <= '1';
                        when others =>
                            next_state <= FETCH;
                    end case;
                when STALL =>
                    next_state <= FETCH;
                    pc_write <= '1';
                    case opcode is
                        when LW_OPCODE =>
                            alu_src <= '1';
                            alu_op <= ADD;
                            mem_to_reg <= '1';
                            reg_write <= '1';
                        when SW_OPCODE =>
                            alu_src <= '1';
                            alu_op <= ADD;
                            mem_write <= '1';
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

