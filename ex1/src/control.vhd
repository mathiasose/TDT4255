library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity control is
		port(
		clk : in std_logic;
		reset : in std_logic;	
		instruction : in instruction_t;
		RegDst : out std_logic;
		Branch : out std_logic;
		MemRead : out std_logic;
		MemtoReg : out std_logic;
		ALUOp : out alu_operation_t;
		MemWrite : out std_logic;
		ALUSrc : out std_logic;
		RegWrite : out std_logic
	);
end control;

architecture Behavioral of control is
	signal opcode : opcode_t;
	signal funct : std_logic_vector(5 downto 0);
	signal state, next_state: state_t;
begin
	opcode <= instruction(31 downto 26);
	opcode <= instruction(5 downto 0);
	
	with state select
	-- State transitions
	next_state <=
		FETCH when STALL,
		EXECUTE when FETCH;
		
	DrivingOutputs : process(state) is
	begin
		-- Setting defaults to avoid latches
		RegDst <= '0';
		Branch <= '0';
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
					when "100010" =>
						AluOp <= ALU_AND;
					when "100010" =>
						AluOp <= SUB;
					when "101010" =>
						AluOp <= SLT;
					when "100101" =>
						AluOp <= ALU_OR;
					when others => AluOp <= NO_OP;
				end case;
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

