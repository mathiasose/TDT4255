library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity control is
    port(
        clk : in std_logic;
        reset : in std_logic;
        instruction : in instruction_t;
        ALUOp : out alu_operation_t;
        ALUSrc : out std_logic;
        Branch : out std_logic;
        Jump : out std_logic;
        --MemRead : out std_logic;
        MemtoReg : out std_logic;
        MemWrite : out std_logic;
        RegDst : out std_logic;
        RegWrite : out std_logic
    );
end control;

architecture Behavioral of control is
    signal opcode : opcode_t;
    signal funct : std_logic_vector(5 downto 0);
    --signal rs, rt, rd : register_address_t;
    --signal immediate_value : std_logic_vector(15 downto 0);
    signal state, next_state: state_t;
begin
    opcode <= instruction(31 downto 26);
    funct <= instruction(5 downto 0);
    --rs <= instruction(25 downto 21);
    --rt <= instruction(20 downto 16);
    --rd <= instruction(15 downto 11);
    --immediate_value <= instruction(15 downto 0);

    DrivingOutputs : process(clk, state, opcode) is
    begin
        -- Setting defaults to avoid latches
        RegDst <= '0';
        Branch <= '0';
        Jump <= '0';
        --MemRead <= '0';
        MemtoReg <= '0';
        AluOp <= NO_OP;
        MemWrite <= '0';
        AluSrc <= '0';
        RegWrite <= '0';

        -- Non default outputs
        case state is
            when STALL =>
                next_state <= FETCH;
                case opcode is
                    when ALU_OP_OPCODE =>
                        --
                    when JUMP_OPCODE =>
                        --
                    when BEQ_OPCODE =>
                        --
                    when LW_OPCODE =>
                        MemtoReg <= '1';
                    when SW_OPCODE =>
                        --
                    when LUI_OPCODE =>
                        --
                    when others =>
                        --
                end case;
            when FETCH =>
                next_state <= EXECUTE;
                case opcode is
                    when ALU_OP_OPCODE =>
                        --
                    when JUMP_OPCODE =>
                        --
                    when BEQ_OPCODE =>
                        AluSrc <= '1';
                    when LW_OPCODE =>
                        AluSrc <= '1';
                    when SW_OPCODE =>
                        AluSrc <= '1';
                    when LUI_OPCODE =>
                        ALUSrc <= '1';
                    when others =>
                        --
                end case;
            when EXECUTE =>
                case opcode is
                    when ALU_OP_OPCODE =>
                        next_state <= FETCH;
                        RegWrite <= '1';
                        RegDst <= '1';
                        case funct is
                            when "100000" =>
                                AluOp <= ADD;
                            when "100010" =>
                                AluOp <= SUB;
                            when "100100" =>
                                AluOp <= ALU_AND;
                            when "100101" =>
                                AluOp <= ALU_OR;
                            when "101010" =>
                                AluOp <= SLT;
                            when others =>
                                AluOp <= NO_OP;
                        end case;
                    when JUMP_OPCODE =>
                        next_state <= FETCH;
                        Jump <= '1';
                    when BEQ_OPCODE =>
                        next_state <= FETCH;
                        Branch <= '1';
                    when LW_OPCODE =>
                        next_state <= STALL;
                    when SW_OPCODE =>
                        MemWrite <= '1';
                        next_state <= STALL;
                    when LUI_OPCODE =>
                        next_state <= FETCH;
                    when others =>
                        next_state <= FETCH;
                end case;
            when others =>
                --
        end case;
    end process DrivingOutputs;

    process (clk, reset) is
    begin
        if reset = '1' then
            state <= STALL;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
end Behavioral;

