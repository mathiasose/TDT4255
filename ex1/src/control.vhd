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
        MemRead : out std_logic;
        MemtoReg : out std_logic;
        MemWrite : out std_logic;
        RegDst : out std_logic;
        RegWrite : out std_logic
    );
end control;

architecture Behavioral of control is
    signal opcode : opcode_t;
    signal funct : std_logic_vector(5 downto 0);
    signal rs, rt, rd : register_address_t;
    signal immediate_value : std_logic_vector(15 downto 0);
    signal state, next_state: state_t;
begin
    opcode <= instruction(31 downto 26);
    funct <= instruction(5 downto 0);
    rs <= instruction(25 downto 21);
    rs <= instruction(20 downto 16);
    rd <= instruction(15 downto 11);
    immediate_value <= instruction(15 downto 0);

    with state select
    -- State transitions
    next_state <=
        FETCH when STALL,
        EXECUTE when FETCH,
        STALL when others;

    DrivingOutputs : process(clk, state, opcode) is
    begin
        -- Setting defaults to avoid latches
        RegDst <= '0';
        Branch <= '0';
        Jump <= '0';
        MemRead <= '0';
        MemtoReg <= '0';
        AluOp <= NO_OP;
        MemWrite <= '0';
        AluSrc <= '0';
        RegWrite <= '0';

        -- Non default outputs
        case state is
            when EXECUTE =>
                case funct is
                    when "100000" =>
                        AluOp <= ADD;
                        RegWrite <= '1';
                    when "100010" =>
                        AluOp <= SUB;
                        RegWrite <= '1';
                    when "100100" =>
                        AluOp <= ALU_AND;
                        RegWrite <= '1';
                    when "100101" =>
                        AluOp <= ALU_OR;
                        RegWrite <= '1';
                    when "101010" =>
                        AluOp <= SLT;
                        RegWrite <= '1';
                    when others =>
                        --
                end case;
            when others => AluOp <= NO_OP;
        end case;

        case opcode is
            when JUMP_OPCODE =>
                Jump <= '1';
            when BEQ_OPCODE =>
                Branch <= '1';
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

